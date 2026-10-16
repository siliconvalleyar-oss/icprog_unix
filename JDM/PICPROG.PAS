program picprog;                                        {Program INHX into PIC}
uses errmsg60,jdm84io,jdm84pgm,picunit,inthex;          {Uses errmsg60, picunit}
var
  f: text;                                              {Text file}

var
  pgmm: pgmmemtype;
  datm: datmemtype;
  cfgm: cfgmemtype;
  cnt, tot: word;
  ch: char;
  ant: byte;
  x: byte;
  adr: word;
  i: word;
  ok: boolean;
  err:byte;
  fn: string;
  pcount: byte;                         { Parameter counter             }

begin
  fillchar(pgmmem,sizeof(pgmmem),255);                  {Clear buffer}
  fillchar(datmem,sizeof(datmem),255);
  fillchar(cfgmem,sizeof(cfgmem),255);

  pcount:=paramcount;                   { Store number of parameters    }
  if pcount<2 then                      { Help if too few or no parameters}
  begin                                                         {Else help}
    writeln('Use:');
    writeln('   picprog filename.hex comport  [iodel(1) rd0del(5) rddel(1) pgmdel(10)]');
    writeln;
    writeln('Numbers in () indicate default delays.');
    halt;
  end;
  val(paramstr(2),com,i);                               { Get comport   }
  if pcount>=3 then val(paramstr(3),ioplusdel,i);       { Default 1     }
  if pcount>=4 then val(paramstr(4),rdzerodel,i);       { Default 5     }
  if pcount>=5 then val(paramstr(5),readdelay,i);       { Default 1ms   }
  if pcount>=6 then val(paramstr(6),progdelay,i);       { Default 10ms  }

  fn:=paramstr(1);
  fnameptr:=@fn;
  assign(f,fn);                                         {Open file}
  reset(f);
  writeln('Reading file ''',paramstr(1),'''');

  cnt:=0;
  ihxread(f, pgmmem, $0000, $800, cnt,tot);
  ihxread(f, cfgmem[0],$4000,8,cnt,tot);
  ihxread(f, cfgmem[7],$400E,2,cnt,tot);
  ihxread(f, datmem, $4200, $80, cnt,tot);
  close(f);
  if cnt<>tot then writeln('Unused data in hex-file');
  fnameptr:=NIL;

  if cfgmem[7]=$ffff then
    writeln('--- Notice: No configuration word in hex-file ---');

  pgmm:=pgmmem;                                         {Verify copy}
  datm:=datmem;
  cfgm:=cfgmem;

  writeln('Programming PIC16C84 at COM',com);

  err:=hwerror;                                         {HW-check}
  if err<>0 then
  begin
    writeln('- ',errtxt[err]);
    halt;
  end;

  readcfg;
  if cfgmem[7] and 16 = 0 then
  begin
    write('- Code Protected. Erase (Y/N)? ');
    repeat
      readln(ch);
      if upcase(ch)='N' then halt;
    until upcase(ch)='Y';
    eraseall;
  end;

  progall;                                              {Program}
  write('Verify ');                                     {Verify}
  readall;
  ok:=true;
  for i:=0 to $3ff do if pgmmem[i]<>(pgmm[i] and $3fff) then ok:=false;
  for i:=0 to $3f do if lo(datmem[i])<>lo(datm[i]) then ok:=false;
  writeln(ok);

  writeln('Programming configuration word');
  cfgmem:=cfgm;
  progcfg;
  readcfg;
  if cfgmem[7] and 16 = 0 then
    writeln('Device code-protected')
  else
  begin
    write('Verify ');
    for i:=0 to 3 do if cfgmem[i]<>(cfgm[i] and $3fff) then ok:=false;
    if cfgmem[7]<>(cfgm[7] and $3fff) then ok:=false;
    writeln(ok);
  end;
end.
