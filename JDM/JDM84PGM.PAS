unit jdm84pgm;          { PIC routines for Turbo Pascal 6.0 - Ver 1.6   }
interface               { Copyright (c) 1997-1999, Jens Dyekj‘r Madsen  }

const
  readdelay: integer = 1;               { Delay between reads           }
  pulsedelay: integer = 5;              { Delay between programm pulses }
  progdelay: integer = 10;              { Programming delay for 16C8x   }
  eradelay: integer = 20;               { Used erase delays             }

var
  data: word;                           { Return data from pgm          }

const                                   { Define Commands               }
  LoadCfg  = $1600;                     { Load Configuration            }
  LoadPgm  = $1602;                     { Load Data for Program Memory  }
  ReadPgm  = $1604;                     { Read Data from Program Memory }
  IncAdr   = $0606;                     { Increment Address             }
  Begpgm   = $0608;                     { Begin Programming             }
  Endpgm   = $060e;                     { End Programming               }
  LoadData = $1603;                     { Load Data for Data Memory     }
  ReadData = $1605;                     { Read Data from Data Memory    }
  ErasePgm = $0609;                     { Bulk Erase Program Memory     }
  EraseData= $060b;                     { Bulk Erase Data Memory        }
  EraseAll1= $0601;                     { EraseAll, first               }
  EraseAll2= $0607;                     { EraseAll, next                }
  LoadCfg16= $1800;                     { Load Configuration - 16 bit   }
  LoadPgm16= $1802;                     { Load Data - 16 bit            }
  ReadPgm16= $1804;                     { Read Data - 16 bit            }
  Null     = $0000;                     { No Command                    }

procedure pgm(cmd, d: integer);         { Read/write commands serial    }
procedure rdmem(VAR memory; initcmd,cmd,count:integer); { Read to memory}
procedure progmem(VAR memory; initcmd,rdcmd,ldcmd,count:integer);
procedure progmemp(VAR memory; initcmd,a,b,m,count:integer);
procedure erase;                        { Erase code                    }

implementation
uses jdm84io;                           { Use delay and I/O             }

procedure pgm(cmd, d: integer);         { Read/write commands serial    }
var
  c: longint;                           { Shift variable                }
  i: integer;                           { Count variable                }
begin
  if d=-1 then waitdelay(readdelay);    { Wait 1ms in case of read      }
  c:=lo(cmd)+longint(d) shl 7;          { Setup bits                    }
  data:=0;                              { Clear input bits              }
  begincmd;                             { Begin command (cli,init timer)}
  for i:=1 to hi(cmd) do                { Shift bits                    }
  begin
    data:=data shr 1 + din shl (hi(cmd)-9);     { Read data             }
    dout(c and 1);                              { Write data            }
    c:=c shr 1;                                 { Next bit              }
  end;
  endcmd;                               { End command (close timer, sti)}
end;

procedure rdmem(VAR memory; initcmd,cmd,count:integer); { Read to memory}
var
  mem: array[0..$3fff] of word absolute memory; { Memory                }
  adr: integer;                                 { Adress counter        }
begin
  mclr;                                         { Start, Reset          }
  pgm(initcmd,0);                               { Config area           }
  for adr:=0 to pred(count) do                  { Adress 0..count-1     }
  begin
    pgm(cmd,-1);                                { Read                  }
    mem[adr]:=data;                             { Store data            }
    pgm(incadr,0);                              { Next adress           }
  end;
end;

procedure progmem(VAR memory; initcmd,rdcmd,ldcmd,count:integer);
var
  mem: array[0..$3fff] of word absolute memory;
  adr: integer;                                 { Adress counter        }
  d: word;                                      { Memory data           }
begin
  mclr;                                         { Start, Reset          }
  pgm(initcmd,0);                               { Config area           }
  for adr:=0 to pred(count) do                  { Adress 0..count       }
  begin
    d:=mem[adr];                                { Setup memory data     }
    if d<=$3fff then                            { If valid data do:     }
    begin
      pgm(rdcmd,-1);                            { Read                  }
      if data<>d then                           { Need to be programmed?}
      begin
        pgm(ldcmd,d);                           { Load                  }
        pgm(begpgm,0);                          { Begin programming     }
        waitdelay(progdelay);                   { Delay 10ms            }
      end;
    end;
    pgm(incadr,0);                              { Next adress           }
  end;
end;

procedure progmemp(VAR memory; initcmd,a,b,m,count:integer);
var
  mem: array[0..$3fff] of word absolute memory; { Access as word        }
  adr: integer;                                 { Adress counter        }
  n: integer;                                   { Number of pulses      }
  i: integer;                                   { OverProg pulse counter}
  d: word;                                      { Memory data           }
procedure pgmcycle;                             { Programming cycle     }
begin
  pgm(loadpgm,d);                               { Load address program  }
  begincmd;                                     { Do not desturb timing }
  pgm(begpgm,0);                                { Begin Programming     }
  delay100us;                                   { Delay 100æs           }
  pgm(endpgm,0);                                { End Programming       }
  endcmd;                                       { Desturb timing ok     }
  waitdelay(pulsedelay);                        { Delay 1 ms after pulse}
end;
begin
  mclr;                                         { Start, Reset          }
  pgm(initcmd,0);                               { Config area           }
  for adr:=0 to pred(count) do                  { Adress 0..count-1     }
  begin
    d:=mem[adr];                                { Setup memory data     }
    if d<>$ffff then                            { If need to program do:}
    begin
      pgm(readpgm,-1);                          { Read command          }
      n:=0;                                     { Reset number of pulses}
      while ((not d) and data<>0) and (n<m) do  { Verify data and n<m   }
      begin
        inc(n);                                 { Count number of pulses}
        pgmcycle;                               { Run Program Cycle     }
        pgm(readpgm,-1);                        { Read next data        }
      end;
      for i:=1 to a*n+b do pgmcycle;            { Over Prog-Pulses      }
    end;
    pgm(incadr,0);                              { Next adress           }
  end;
end;

procedure erase;                                { Erase code and data   }
var
  i: integer;                                   { Adress counter        }
begin
  mclr;                                         { Start, Reset          }
  pgm(loadcfg,$3fff);                           { Setup config word     }
  for i:=1 to 7 do pgm(incadr,0);               { Adress at config word }
  pgm(EraseAll1,0);                             { Erase part 1          }
  pgm(EraseAll2,0);                             { Erase part 2          }
  pgm(begpgm,0);                                { Start programming     }
  waitdelay(eradelay);                          { Delay 20ms            }
  pgm(loaddata,$3fff);                          { Setup data word       }
  pgm(begpgm,0);                                { Start programming     }
  waitdelay(eradelay);                          { Delay 20ms            }
  pgm(EraseAll1,0);                             { End erase part 1      }
  pgm(EraseAll2,0);                             { End erase part 2      }
end;

end.
