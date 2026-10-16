program pictest;                        { TEST PIC16c84                 }
uses crt,jdm84io,jdm84pgm;              { Uses CRT, JDM84IO and JDM84PGM}
type
  pgmmemtype = array[0..$3ff] of word;  { Program memory type           }
  datmemtype = array[0..$3f] of word;   { Data memory type              }
  cfgmemtype = array[0..$7] of word;    { Config memory type            }

const
  tc = longint(55);                     { Delay between ticks           }

var
  com: byte;                            { COM port                      }
  pgmmem: pgmmemtype;                   { Program memory                }
  datmem: datmemtype;                   { Data memory                   }
  cfgmem: cfgmemtype;                   { Config memory                 }
  pgmmem1: pgmmemtype;                  { Program memory, copy          }
  datmem1: datmemtype;                  { Data memory, copy             }
  cfgmem1: cfgmemtype;                  { Config memory, copy           }
  i: word;                              { Counter etc                   }
  ok: boolean;                          { OK flag                       }
  t1: longint;                          { Store time                    }
  pcount: byte;                         { Parameter counter             }
  t: longint absolute $40:$6c;          { Timer                         }

begin
  pcount:=paramcount;                   { Store number of parameters    }
  if pcount=0 then                      { Help if no parameters         }
  begin
    writeln('Use:');
    writeln('   pictest comport  [iodel(1) rd0del(5) rddel(1) pgmdel(10)]');
    writeln;
    writeln('Numbers in () indicate default delays.');
    halt;
  end;
  val(paramstr(1),com,i);                               { Get comport   }
  if pcount>=2 then val(paramstr(2),ioplusdel,i);       { Default 1     }
  if pcount>=3 then val(paramstr(3),rdzerodel,i);       { Default 5     }
  if pcount>=4 then val(paramstr(4),readdelay,i);       { Default 1ms   }
  if pcount>=5 then val(paramstr(5),progdelay,i);       { Default 10ms  }

  writeln('Testing PIC-Programmer at COM',com);

  setcom(com);                          { Setup com-port                }
  if err<>0 then
  begin
    writeln('- ',errtxt[err]);
    halt;
  end;

  writeln('- Erase');

  erase;                                { Call erase                    }
  releasepg;                            { Release Programmer            }

  write('- Blank check ');
  t1:=t;

  rdmem(pgmmem,null,readpgm,$400);      { Read program                  }
  rdmem(datmem,null,readdata,$40);      { Read data                     }
  releasepg;                            { Release Programmer            }

  ok:=true;
  for i:=0 to $3ff do if pgmmem[i]<>$3fff then ok:=false;
  t1:=t-t1;
  writeln(ok,', ',t1*tc,'ms');

  writeln('- Generate random numbers');
  randomize;
  for i:=0 to $3ff do pgmmem[i]:=random($3fff);
  for i:=0 to $3f  do datmem[i]:=random($ff);
  pgmmem1:=pgmmem; datmem1:=datmem;

  write('- Programming random numbers, ');
  t1:=t;

  progmem(pgmmem,null,readpgm,loadpgm,$400);    { PGM program           }
  progmem(datmem,null,readdata,loaddata,$40);   { PGM data              }
  releasepg;                                    { Release Programmer    }

  t1:=t-t1;
  writeln(t1*tc,'ms');

  write('- Verify ');
  t1:=t;

  rdmem(pgmmem,null,readpgm,$400);      { Read program                  }
  rdmem(datmem,null,readdata,$40);      { Read data                     }
  releasepg;                            { Release Programmer            }

  ok:=true;
  for i:=0 to $3ff do if pgmmem[i]<>pgmmem1[i] then
  begin
    ok:=false;
    writeln(i:10, pgmmem[i]:10,pgmmem1[i]:10);
  end;
  for i:=0 to $3f do if lo(datmem[i])<>lo(datmem1[i]) then
  begin
    ok:=false;
    writeln(i:10, pgmmem[i]:10,pgmmem1[i]:10);
  end;
  t1:=t-t1;
  writeln(ok,', ',t1*tc,'ms');

  write('- Programming ZERO''s, ');
  t1:=t;
  fillchar(pgmmem,sizeof(pgmmem),0);
  fillchar(datmem,sizeof(datmem),0);

  progmem(pgmmem,null,readpgm,loadpgm,$400);    { PGM program           }
  progmem(datmem,null,readdata,loaddata,$40);   { PGM data              }

  t1:=t-t1;
  writeln(t1*tc,'ms');

  write('- Verify ');
  t1:=t;

  rdmem(pgmmem,null,readpgm,$400);      { Read program                  }
  rdmem(datmem,null,readdata,$40);      { Read data                     }

  ok:=true;
  for i:=0 to $3ff do if pgmmem[i]<>0 then
  begin
    ok:=false;
    writeln(i:10, pgmmem[i]:10,pgmmem1[i]:10);
  end;
  for i:=0 to $3f do if lo(datmem[i])<>0 then
  begin
    ok:=false;
    writeln(i:10, pgmmem[i]:10,pgmmem1[i]:10);
  end;
  t1:=t-t1;
  writeln(ok,', ',t1*tc,'ms');
end.
