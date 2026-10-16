program prog50x;        { PIC12C50x prog for Turbo Pascal 6.0 - Ver 1.5 }
                        { Copyright (c) 1997-1999, Jens Dyekj‘r Madsen  }

uses errmsg60,jdm84io,jdm84pgm,inthex;          { Used units            }
var
  cfgword, cfgword2, cfgword3: word;            { Configuration word    }
  userpgm, userpgm2: array[0..$fff] of word;    { Program mem incl. id. }
  size1: 1..$1000;                              { Total Size            }
  size2: 0..$1000;                              { Osc Address + 1       }
  cp: word;                                     { Code Protect Mask     }
  com: 1..4;                                    { Communication port    }
  eq: boolean;                                  { True if equal         }
  f: text;                                      { IHX test file         }
  ch: char;                                     { Character for Y/N     }
  i: integer;                                   { Store code from val   }
  fn: string;                                   { IHX8 filename         }
  cnt, tot: word;                               { IHX8 count, total cnt }
  oscadr: word;                                 { Oscillator Cal. Addr  }
  oscdat: word;                                 { Oscillator Cal. data  }
  pcount: byte;                                 { Parameter counter     }

begin
  pcount:=paramcount;                   { Store number of parameters    }
  if pcount<5 then                      { Help if to few parameters     }
  begin
    writeln('Use:');
    writeln('   prog50x totalsize oscadr+1 cpmask filename.hex comport');
    writeln('           iodel(1) rd0del(5) rddel(1) pgmdel(5) [oscval]');
    writeln;
    writeln('Numbers in () indicate default delays.');
    halt;
  end;
  if pcount>=6 then val(paramstr(6),ioplusdel,i);       { Default 1     }
  if pcount>=7 then val(paramstr(7),rdzerodel,i);       { Default 5     }
  if pcount>=8 then val(paramstr(8),readdelay,i);       { Default 1ms   }
  if pcount>=9 then val(paramstr(9),pulsedelay,i);      { Default 5ms   }

  {$r+}                                         { Range check inputs    }
  val(paramstr(1), size1, i);                   { Get Total Size of mem }
  val(paramstr(2), size2, i);                   { Oscaddr + 1           }
  {$r-}                                         { Range check end       }
  val(paramstr(3), cp,i);                       { Get Code Protect Bits }

  val(paramstr(5), com, i);                     { Get comport           }
  setcom(com);                                  { Set com port          }
  if err<>0 then                                { Check if any error    }
  begin
    writeln(errtxt[err]);                       { Write error message   }
    halt;                                       { Stop execution if err }
  end;

  writeln('Reading 12C50X from COM ',com);      { Info about reading    }

  rdmem(userpgm, incadr, readpgm, size1);       { Read code memory + id }
  rdmem(cfgword, null, readpgm, 1);             { Read configuration    }
  releasepg;                                    { Release programmer    }

  cfgword2:=cfgword;                            { Verification copy     }
  userpgm2:=userpgm;

  fn:=paramstr(4);                              { Filename from paramstr}
  writeln('Reading file ''',fn,'''');           { Info                  }
  fnameptr:=@fn;                                { Set filename pointer  }
  assign(f,fn);                                 { Open file             }
  reset(f);                                     { Read mode             }
  cnt:=0;                                       { Reset IHX counts      }

  ihxread(f, cfgword, $1ffe, 2, cnt, tot);      { Read cfgword from file}
  i:=cnt;                                       { Number of config bytes}
  ihxread(f, userpgm, $0000, size1*2, cnt, tot);{ Read userpgm, 0, size1}
  close(f);                                     { End read file         }
  fnameptr:=NIL;                                { End of using filename }

  if i=0 then                                   { Config in hex file?   }
    writeln('--- Notice: No configuration word in hex-file ---');
                                                { Unused data in file?  }
  if cnt<>tot then writeln('--- Notice: Unused data in hex-file ---');

  if size2<>0 then                              { OscVal Address valid? }
  begin
    oscadr:=pred(size2);                        { Set adr. of osc.calibr}
    oscdat:=userpgm2[oscadr];                   { Get oscillator value  }
    if (hi(oscdat)<>$0f) and (hi(oscdat)<>$0c) then
      writeln('Invalid oscvalue, not able to modify')
    else
    if pcount=10 then                           { Modify oscval?        }
    begin
      if lo(oscdat)<>255 then
        writeln('Oscvalue not blank, not allowed to modify')
      else
      begin
        val(paramstr(10),oscdat,i);             { Manual set oscval     }
        oscdat:=oscdat+$c00;
      end;
    end;
    write('Oscillator calibration value: ');    { Output text           }
    if hi(oscdat)<>$0c then write('(',hi(oscdat),') '); { Print value   }
    writeln(lo(oscdat));
    userpgm[oscadr]:=oscdat;                    { Store oscval          }
  end;

  { Calculate mask between eprom and data }
  for i:=0 to pred(size1) do userpgm2[i]:=userpgm2[i] and userpgm[i];
  cfgword3:=cfgword2 and cfgword;

  eq:=true;                                     { Userpgm programmable? }
  for i:=0 to pred(size1) do if userpgm2[i]<>userpgm[i] then eq:=false;

  if (not eq) or (cfgword3<>cfgword) then       { Else ask user to cont.}
  begin
    write('- Not able to program contens into eprom. Countinue (Y/N)? ');
    repeat                                      { Check Y/N result      }
      readln(ch);                               { Get character Y/N     }
      if upcase(ch)='N' then halt;              { Exit if not continue  }
    until upcase(ch)='Y';                       { Only continue if yes  }
  end;

  writeln('Programming ...');                   { Begin programming     }
  cfgword:=cfgword or cp;                       { Remove codeprotect    }
  cfgword2:=cfgword2 and cfgword;               { Checkword for no cp.  }

  progmemp(userpgm, incadr, 11, 0, 8, size1);   { Prog code memory + id }
  rdmem(userpgm, incadr, readpgm, size1);       { Read code memory + id }
  progmemp(cfgword, null, 0, 100, 0, 1);        { Program configuration }
  rdmem(cfgword, null, readpgm, 1);             { Read configuration    }
  releasepg;                                    { End of programming    }

  eq:=true;                                     { Verify eprom data     }
  for i:=0 to pred(size1) do if userpgm2[i]<>userpgm[i] then eq:=false;
  writeln('Verify ',eq and (cfgword2=cfgword));

  if cfgword2<>cfgword3 then                    { Else ask user to drop }
  begin
    write('- Codeprotect none codeprotected device? (Y/N)? ');
    repeat                                      { Check Y/N result      }
      readln(ch);                               { Get character Y/N     }
      if upcase(ch)='N' then halt;              { Exit if not continue  }
    until upcase(ch)='Y';                       { Only continue if yes  }
  end;

  cfgword:=cfgword3;                            { Load cfgword with cp  }

  progmemp(cfgword, null, 0, 100, 0, 1);        { Program configuration }
  rdmem(cfgword, null, readpgm, 1);             { Read configuration    }
  releasepg;                                    { End of programming    }

  writeln('Verify ',(not cfgword3) and cfgword=0);  { Verify codeprotect}
end.
