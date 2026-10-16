unit delays;            { Delay unit for Turbo Pascal 6.0 - Ver 1.2     }
interface               { Copyright (c) 1997-1998, Jens Dyekj‘r Madsen  }
const
  t2u5 =  3;                                    {  3 * 838ns =  2.51æs  }
  t5u  =  6;                                    {  6 * 838ns =  5.03æs  }
  t7u5 =  9;                                    {  9 * 838ns =  7.54æs  }
  t10u = 12;                                    { 12 * 838ns =  10.06æs }
  t100u= 120;                                   {120 * 838ns = 100.61æs }
  sdt  = t7u5;                                  { Shortdelay = 7.5æs    }

procedure shortdelay;                           { Short delay           }
inline(
  $E4/$42/      {       IN      AL,[42]         ; Read timer 2, LSB     }
  $2c/<sdt/     {       SUB     AL,sdt          ; Calculate stop time   }
  $93/          {       XCHG    AX,BX           ; store in BL           }
  $EB/$00/      {       JMP     $+2             ; I/O delay             }
  $EB/$00/      {L1:    JMP     $+2             ; I/O delay             }
  $E4/$42/      {       IN      AL,[42]         ; Read timer 2, LSB     }
  $38/$D8/      {       CMP     AL,BL           ; Compare with stoptime }
  $79/$F8);     {       JNS     L1              ; Continue until timeout}

procedure shortdelay_t(t: shortint);            { Delay/838ns, max 100us}
procedure shortdelay_on;                        { Start timer 2, cli    }
procedure shortdelay_off;                       { Stop timer 2, sti     }


implementation

procedure cli;   inline($fa);                   { Disable interrupts    }
procedure sti;   inline($fb);                   { Enable interrupts     }
procedure pushf; inline($9c);                   { Save flags on stack   }
procedure popf;  inline($9d);                   { Get flags from stack  }
procedure nop;   inline($90);                   { No operation          }

procedure shortdelay_t(t: shortint); assembler; { Delay/838ns, max 100us}
asm
        in      al,42h                          { Read timer 2 LSB      }
        sub     al,t                            { Calculate stoptime    }
        xchg    ax,bx                           { Store in BL           }
        jmp     @1                              { I/O delay             }
@1:     jmp     @0                              { I/O delay             }
@0:     in      al,42h                          { Read timer 2 LSB      }
        cmp     al,bl                           { Compare with stoptime }
        jns     @1                              { Continue until timeout}
end;

const
  count: integer = 0;                           { Count on - off's      }
var
  gsave: byte;                                  { Saves 8255, portB     }

procedure shortdelay_on;                        { Start timer           }
begin
  if count=0 then                               { If level zero:        }
  begin                                         {                       }
    repeat                                      { Wait on timer 2 free  }
      sti; nop;                                 { Allow interrupts      }
      cli;                                      { CLI when timer in use }
      gsave:=port[$61];                         { Store 8255 port B     }
    until (gsave and 3) = 0;                    { Repeat to timer 2 free}
    port[$43]:=$94;                             { R/W LSB only, mode 2  }
    port[$61]:=gsave or 1;                      { Timer 2 gate on       }
    port[$42]:=0;                               { Begin count on timer 2}
  end;
  inc(count);                                   { Increase on's         }
end;

procedure shortdelay_off;                       { Stop timer            }
begin
  dec(count);                                   { Decrease on's         }
  if count=0 then
  begin
    port[$61]:=gsave;                           { Stop timer 2          }
    sti;                                        { Interrupts on         }
  end;
end;

begin
  port[$61]:=port[$61] and $fc;                 { Turn of timer & sound }
end.
