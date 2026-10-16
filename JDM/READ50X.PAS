program read50x;        { PIC12C50x read for Turbo Pascal 6.0 - Ver 1.5 }
                        { Copyright (c) 1997-1999, Jens Dyekj‘r Madsen  }

uses errmsg60,jdm84io,jdm84pgm,inthex;          { Used units            }
var
  size1: 1..$1000;                              { Total Size            }
  cfgword: word;                                { Configuration word    }
  userpgm: array[0..$fff] of word;              { Program mem incl. id. }
  f: text;                                      { IHX test file         }
  com: byte;                                    { Communication port    }
  i: word;                                      { Store code from val   }
  fn: string;                                   { IHX8 filename         }
  oscadr: 0..$fff;                              { Oscillator Cal. Addr  }
  oscdat: word;                                 { Oscillator Cal. data  }
  pcount: byte;                                 { Parameter counter     }

begin
  pcount:=paramcount;                   { Store number of parameters    }
  if pcount<4 then                      { Help if to few parameters     }
  begin
    writeln('Use:');
    writeln('   read50x totalsize oscadr+1 filename.hex comport');
    writeln('           [iodel(1) rd0del(5) rddel(1)]');
    writeln;
    writeln('Numbers in () indicate default delays.');
    halt;
  end;
  if pcount>=5 then val(paramstr(5),ioplusdel,i);       { Default 1     }
  if pcount>=6 then val(paramstr(6),rdzerodel,i);       { Default 5     }
  if pcount>=7 then val(paramstr(7),readdelay,i);       { Default 1ms   }

{$r+}
  val(paramstr(1), size1, i);                   { Read total size       }
  val(paramstr(2), oscadr, i);
{$r-}
  val(paramstr(4), com, i);
  setcom(com);                                  { Set com port          }
  if err<>0 then                                { Check if any error    }
  begin
    writeln(errtxt[err]);                       { Write error message   }
    halt;                                       { Stop execution if err }
  end;

  fn:=paramstr(3);                              { Filename from paramstr}
  writeln('Reading PIC12C50X at COM',com,' to ''',fn,'''');     { Info  }

  fnameptr:=@fn;                                { Set filename pointer  }
  assign(f,fn);                                 { Open file             }
  rewrite(f);                                   { Write mode            }

  rdmem(userpgm, incadr, readpgm, size1);       { Read code memory + id }
  rdmem(cfgword, null, readpgm, 1);             { Read configuration    }
  releasepg;                                    { End of programming    }

  if oscadr<>0 then                             { Check if oscadr valid }
  begin
    oscdat:=userpgm[pred(oscadr)];              { Get osc-value data    }
    write('--- Notice: Oscillator calibration value: '); { Output text }
    if hi(oscdat)<>$0c then write('(',hi(oscdat),') '); { Print value   }
    writeln(lo(oscdat),' ---');
  end;

  ihxwrite(f, userpgm, $0000, 2*size1);         { Write userpgm, 0, $204}
  ihxwrite(f, cfgword, $1ffe, 2);               { Write id's, $FFF, 1   }
  ihxendwrite(f);                               { Write end of record   }
  close(f);                                     { Close file            }
  fnameptr:=NIL;                                { End of using filename }
end.
