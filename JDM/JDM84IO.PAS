unit jdm84io;           { PIC-Programmer for Turbo Pascal 6.0 - Ver 3.4 }
interface               { Copyright (c) 1997-1999, Jens Dyekj‘r Madsen  }
                        { Modified for use with free-pascal's go32 unit.}
                        { Use port unit under linux. (ioperm to accept).}

const                                           { Default delays (big)  }
  ioplusdel: integer = 1;                       { Extra io delay        }
  rdzerodel: integer = 5;                       { Extra delay read zero }

const
  base: integer = 0;                            { Com-port base adress  }
  din: byte = 0;                                { Returns PIC xxx data  }
  err: byte = 1;                                { Returns error code    }
  errtxt: array[0..5] of string[22] =           { Define errortxt       }
    ('No Error Found',                          { Error code 0 text     }
     'Comport not found',                       { Error code 1 text     }
     'Modem found',                             { Error code 2 text     }
     'Ilegal parameter value',                  { Error code 3 text     }
     'Programmer not found',                    { Error code 4 text     }
     'Cable too long');                         { Error code 5 text     }

procedure setcom(n: byte);                      { Select com-port / go  }
{
  Initialize the comport and perform hadware check. Return result in err.
}

procedure releasepg;                            { End comport use / go  }
{
  Release programmer. 'Automatic go' is activated after relpgm.
}

procedure begincmd;                             { Begin command         }
{ Indicates begin of command. Should be called before each PIC-command. }

procedure endcmd;                               { End command           }
{ Indicates end of command. Should be called after each PIC-command.    }


{ PIC routines }

procedure mclr;                                 { Reset PIC xxx         }

procedure dout(val: byte);                      { In/Out PIC16C84 data  }
{
  Send a bit of the value val to PIC16C84. Recieve data to din.
  Do only call Dout, SDA and SDL between begcmd and endcmd.
}


{ EEPROM (I2C) routines }

procedure sda(val: byte);                       { Set SDA = val         }
procedure scl(val: byte);                       { Set SCL = val         }
function rda: byte;                             { Return SDA            }
{
  SDA sets the value of data. SCL sets the value of clock. 
  Do only call Dout, SDA and SDL between begcmd and endcmd.
  RDA recieves data. Do not use RDA between begcmd and endcmd
  when waiting for acknoledge.
}


{ Delay routines }

procedure waitdelay(t: integer);                { Delay / ms            }
{ Delay of t ms (minimum, may be longer). About 100æs if t=0. Max 5000ms}

procedure delay100us;                           { Short 100æs delay     }

implementation
{$ifdef go32v2} uses go32; {$endif}             { Free Pascal use GO32  }
var
  lastout: byte;                                { Saves last output     }
  base3,base4,base5,base6: integer;             { Saves base address    }
  iodelay: integer;                             { I/O delay time        }
  i: integer;                                   { Count variable        }

procedure setdlab(d: word);                     { Set Baud Rate Divisor }
var
  lcr: byte;                                    { Saves Line Control Reg}
begin
  lcr:=port[base3];                             { Store Line Control Reg}
  port[base3]:=$80 or lcr;                      { Select DLAB           }
  port[base]:=lo(d); port[succ(base)]:=hi(d);   { Set Baud rate         }
  port[base3]:=lcr;                             { Restore LCR           }
end;

procedure getdlab(var d: word);                 { Get Baud Rate Divisor }
var
  lcr: byte;                                    { Saves Line Control Reg}
begin
  lcr:=port[base3];                             { Store Line Control Reg}
  port[base3]:=$80 or lcr;                      { Select DLAB           }
  d:=port[base]; d:=port[succ(base)] shl 8 + d; { Get Baud rate         }
  port[base3]:=lcr;                             { Restore LCR           }
end;

procedure waitdelay(t: integer);                { Delay / ms            }
begin
  setdlab(succ((longint(t)*1152)div 110));      { Calculate baud rate   }
  port[base]:=0;                                { Send data             }
  repeat until port[base5]>=96;                 { Wait to data send     }
  setdlab(1);                                   { Set 100æs delay       }
end;

procedure delay100us;                           { Short 100æs delay     }
begin
  port[base]:=0;                                { Send data             }
  repeat until port[base5]>=96;                 { Wait to data send     }
end;

procedure send(n: byte);                        { Send with iodelay time}
begin
  port[base4]:=n;                               { Output value to port  }
  for i:=0 to iodelay do                        { Read multiple times to}
    din:=(port[base6] shr 4) and 1;             { do iodelay. Store din.}
end;



{ Begin and end command }

const
  level: integer = 0;                           { Stores interrupt level}

procedure begincmd;                             { Begin command         }
begin                                           { No interrupts at cmd  }
  inc(level);                                   { Increase level and    }
  asm
    cli;                                        { disable interrupts.   }
  end
end;

procedure endcmd;                               { End command           }
begin                                           { Interrupt ok after cmd}
  dec(level);                                   { Decrease level        }
  if level=0 then
  asm
    sti;                                        { Interrupts on         }
  end;
end;



{ Check routine }

procedure check;                                { Check programmer on   }
var
  i :integer;                                   { Counter               }
begin
  err:=1;                                       { Assume error 1        }
  if base=0 then exit;                          { Exit if comport error }
                                                { Setup USART port      }
  port[base+2]:=6;                              { Disable fifo          }
  port[base3]:=7;                               { 8 bit, 2 stopbit, IER }
  port[succ(base)]:=0;                          { No interrupts         }

  err:=2;                                       { Assume modem error (2)}
  port[base4]:=0;                               { RTS low, DTR low      }
  waitdelay(1);                                 { Wait 1ms              }
  if port[base6] and $10 <> 0 then exit;        { Exit if modem         }

  err:=0;                                       { Assume no error       }
  for i:=0 to 20 do                             { Clock data out, EEPROM}
  begin
    port[base4]:=succ((i and 1)shl 1);          { DTR high, Toggle RTS  }
    delay100us;                                 { Wait 100æs            }
  end;
  iodelay:=0;                                   { Setup delay           }
  for i:=1 to 40 do                             { Check if programmer ok}
  begin
    begincmd;                                   { Do not desturb timing }
    send(i and 1);                              { RTS low, Toggle DTR   }
    endcmd;                                     { Desturb ok            }
    waitdelay(1);                               { Wait 1ms              }
    if (din xor i)and 1<>0 then inc(iodelay);   { Increment iodelay     }
    if ((port[base6]shr 4)xor i)and 1<>0 then err:=4;    { Check err 4  }
  end;                                          { RTS low, DTR low      }
  if (err=0) and (iodelay>=40) then err:=5;     { Check cable too long  }
  iodelay:=iodelay+ioplusdel;                   { Add extra i/o delay   }
  port[base4]:=lastout;                         { Restore last output   }
end;


{ Initialize and release programmer }

var
  mstate: array[1..4] of byte;                  { Saves USART state     }
  dlab: word;                                   { Stores Baud Rate Div. }

procedure setcom(n: byte);                      { Setup com-port        }
var                                             { And store com-state   }
  i: integer;                                   { Counter to store state}
begin
  err:=3;                                       { Error 3 if no comport }
  if (n=0) or (n>4) then exit;                  { Check comport value   }
  base:=memw[$40:2*pred(n)];                    { Setup RS232 port      }
  err:=1;                                       { Error 1 if not found  }
  if base=0 then exit;                          { Exit if not found     }
  base3:=base+3; base4:=base+4; base5:=base+5; base6:=base+6;  { Baseofs}

  for i:=2 to 4 do mstate[i]:=port[base+i];     { Store USART state     }
  port[base3]:=7;                               { Select IER            }
  mstate[1]:=port[succ(base)];                  { Store IER             }
  getdlab(dlab);                                { Get Baud Rate Divisor }

  lastout:=0;                                   { Setup default output  }
  check;                                        { Check hardware        }
  if err<>0 then                                { If error then         }
  begin                                         { Restore USART state   }
    setdlab(dlab);                              { Set Baud Rate Divisor }
    for i:=1 to 4 do port[base+i]:=mstate[i];   { Restore USART state   }
  end;
end;

procedure releasepg;                            { End communication use }
begin
  check;                                        { Perform hardware check}
end;


{ PIC xxxx routines }

procedure mclr;                                 { Reset PIC xxx         }
var
  brkstate: byte;                               { Store break state     }
  i: byte;                                      { Used to count         }
begin
  brkstate:=port[base3];                        { Save break state      }
  check;                                        { Perform hardware check}
  if err=0 then                                 { Check to be sure that }
  begin                                         { No modem is connected }
    if brkstate and $40 = 0 then                { If TxD is low, then   }
    begin                                       { Power up denied       }
      port[base3]:=$47;                         { Enable Break, MCLR on }
      waitdelay(350);                           { Power on Delay, 350ms }
    end;                                        { Default 115Kbaud,n,8,2}
    port[base3]:=7;                             { Start reset, MCLR low }
    for i:=1 to 3 do                            { pulses                }
    begin                                       { to not start auto go  }
      port[base]:=0;                                    { Output zero   }
      repeat until boolean(port[base5] and $20);        { Wait on empty }
    end;
    port[base3]:=$47;                           { Enable break, no reset}
    delay100us;                                 { Delay 100æs           }
  end;
end;

procedure dout(val: byte);                      { Output PIC data       }
var
  i: integer;                                   { Used to count         }
begin
  send(val or 2);                               { Output value, Clk high}
  send(val and din);                            { Output value, Clk low }
  port[base4]:=0;                               { RTS low, DTR low      }
  if din<>val then                              { Extra delay reading 0 }
    for i:=1 to rdzerodel do send(0);           {   Extra rechage delay }
end;


{ EEPROM (I2C) routines }

function rda: byte;                             { Read data             }
begin
  rda:=(port[base6] shr 4) and 1;               { Setup rda value       }
end;

procedure sda(val: byte);                       { Set SDA = val         }
begin
  lastout:=(lastout and $fe) or val;            { Update lastout        }
  send(lastout);                                { Output lastout        }
end;

procedure scl(val: byte);                       { Set SCL = val         }
begin
  lastout:=(lastout and $fd) or 2*val;          { Update lastout        }
  send(lastout);                                { Output lastout        }
end;

end.
