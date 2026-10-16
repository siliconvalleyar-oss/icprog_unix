program picread;                                        {Read into inhx file}
uses errmsg60,jdm84io,jdm84pgm,picunit,inthex;          {Uses picunit}
type
  hilo =                                                {To convert byte (word)}
  record
    lo,hi: byte;
  end;
var
  f: text;
  i: word;                                                       {Count}
  err: byte;
  fn: string;
  pcount: byte;                         { Parameter counter             }

begin
  pcount:=paramcount;                   { Store number of parameters    }
  if pcount<2 then                      { Help if too few or no parameters}
  begin                                                         {Else help}
    writeln('Use:');
    writeln('   picread filename.hex comport  [iodel(1) rd0del(5) rddel(1)]');
    writeln;
    writeln('Numbers in () indicate default delays.');
    halt;
  end;
  val(paramstr(2),com,i);                               { Get comport   }
  if pcount>=3 then val(paramstr(3),ioplusdel,i);       { Default 1     }
  if pcount>=4 then val(paramstr(4),rdzerodel,i);       { Default 5     }
  if pcount>=5 then val(paramstr(5),readdelay,i);       { Default 1ms   }

  fn:=paramstr(1);
  writeln('Reading PIC16C84 at COM',com,' to ''',fn,'''');      {Info}

  err:=hwerror;                                 { HW-check              }
  if err<>0 then
  begin
    writeln('- ',errtxt[err]);
    halt;
  end;

  readcfg;                                      { Read config           }
  if cfgmem[7] and 16 = 0 then                  { Codeprotect?          }
  begin
    writeln('Code Protected!');
    halt;
  end;
  fnameptr:=@fn;                                { Set filename pointer  }
  assign(f,fn);                                 { Open file             }
  rewrite(f);                                   { Write mode            }

  readall;                                      { Read PIC16C84         }
  for i:=0 to $3f do hilo(datmem[i]).hi:=0;     { Clr high data         }

  ihxwrite(f, pgmmem, $0000, $800);             { Write pgmmem, 0, $400 }
  ihxwrite(f, cfgmem[0],$4000,8);               { Write id's, $2000, 4  }
  ihxwrite(f, cfgmem[7], $400E,2);              { Write cfgword, $2007  }
  ihxwrite(f, datmem, $4200, $80);              { Write data $2100, $40 }
  ihxendwrite(f);                               { Write en of record    }
  close(f);                                     { Close file            }
end.
