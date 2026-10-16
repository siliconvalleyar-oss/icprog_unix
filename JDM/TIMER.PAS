unit timer;             { Timer routnine for Turbo Pascal 6.0 - Ver 1.3 }
interface               { Copyright (c), 1997-1999, Jens Dyekj‘r Madsen }

{ To allow multitasking, is the timer only programmed if it is mode 3.  }

var
  mode3: boolean;                               { True if mode3 at entry}
  ticks: longint absolute 0:$46c;               { Timer ticks           }

procedure timersync;                            { Sync. LSB, MSB reading}

function time: word;                            { Returns with .ticks   }
inline(
  $9C/          {       PUSHF                   ; Save inerrupt flag    }
  $FA/          {       CLI                     ; Disable interrupt     }
  $E4/$40/      {       IN      AL,[40]         ; Read timer 0          }
  $88/$C4/      {       MOV     AH,AL           ; Store LSB in AH       }
  $E4/$40/      {       IN      AL,[40]         ; Read MSB to AL        }
  $9D/          {       POPF                    ; Restore interrupt flag}
  $86/$C4/      {       XCHG    AL,AH           ; Order high, low byte  }
  $F7/$D8       {       NEG     AX              ; Complement value      }
);

implementation

procedure cli;  inline($fa);                    { Enables interrupts    }
procedure sti;  inline($fb);                    { Disable interrupts    }

procedure timersync; assembler;                 { Sync. LSB, MSB reading}
asm
        pushf                                   { Store interrupt flag  }
        cli                                     { No interrupts         }
@1:     in      al,40h                          { Synchronize reading   }
        in      al,40h                          { Read LSB              }
        mov     bl,al                           { Save to BL            }
        in      al,40h                          { Read MSB              }
        mov     bh,al                           { Save to BH            }
        in      al,40h                          { Read LSB              }
        sub     bl,al                           { Calculate LSB counts  }
        in      al,40h                          { Read MSB              }
        sub     bh,al                           { Calculate MSB counts  }
        cmp     bh,bl                           { LSB counts>MSB counts?}
        jnc     @1                              { Else retry            }
        popf                                    { Restore interrupt flag}
end;

var
  exitsave: pointer;                            { Saves old exitproc    }

procedure newexit; far;                         { Restore timer0 at exit}
begin
  if mode3 then                                 { Check if mode3 entry  }
  begin
    cli;                                        { Disables interrupt    }
    port[$43]:=$36;                             { Restore mode 3        }
    port[$40]:=0; port[$40]:=0;                 { Start timer           }
    sti;                                        { Enables interrupt     }
  end;
  exitproc:=exitsave;                           { Continue with old exit}
end;

var
  i: byte;                                      { Counter               }

begin
  timersync;                                    { Synchronize LSB, MSB  }
  mode3:=true;                                  { Check mode 3          }
  for i:=1 to 255 do if lo(time) and 1<>0 then mode3:=false;
  if mode3 then                                 { If mode 3:            }
  begin
    cli;                                        { Disables interrupt    }
    port[$43]:=$34;                             { Reprogram to mode 2   }
    port[$40]:=0; port[$40]:=0;                 { Start timers          }
    sti;                                        { Enables interrupt     }
  end;
  exitsave:=exitproc;                           { Save exitproc         }
  exitproc:=@newexit;                           { Setup new exitproc    }
end.
