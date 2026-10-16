unit inthex;            { Intel Hex unit for Turbo Pascal 6.0 - Ver 1.2 }
interface               { Copyright (c) 1997-1998, Jens Dyekj‘r Madsen  }

procedure ihxerr(errcode: word);                { Default error handler }
procedure ihxread(				{ Read Intel Hex File	}
  var f: text; var memory; adr: word; count: word; var cnt, tot: word);
procedure ihxwrite(				{ Write Intel Hex File	}
  var f: text; var memory; adr: word; count: word);
procedure ihxendwrite(var f: text);             { Write end of record   }


implementation
var
  sum: byte;                                    { Checksum              }

procedure ihxerr(errcode: word);                { Default error handler }
const                                           { May be redefined later}
  name: array[1..2] of string[17] =             { Define error messages }
    ('Error in HEX file','Checksum error');
begin                                           { Write out filename    }
  writeln(name[errcode],'.');                   { Write out errormessage}
  halt;
end;

procedure ihxread(				{ Read Intel Hex File	}
  var f: text; var memory; adr: word; count: word; var cnt, tot: word);
var
  m: array[0..32767] of byte absolute memory;   { Memory of byte / word }
  n: word;                                      { Number of data        }
  adr2: word;					{ Address of hex data	}
  hexrec: byte;                                 { Record type           }
  d: byte;					{ To read data		}
  ch: char;                                     { Character             }
function rdhex: byte;                           { Read hex from hex file}
const
  hx: string[3] = '$  ';                        { Define hex $ constant }
var
  i: integer;                                   { Char index            }
  v: byte;                                      { Value to be read      }
begin
  read(f,hx[2],hx[3]);                          { Read from file        }
  val(hx,v,i);                                  { Convert to hex        }
  if i<>0 then ihxerr(1);                       { Else return the error }
  rdhex:=v;                                     { Return with hex value }
  sum:=sum+v;                                   { Calculate sum of data }
end;
type
  hilo =                                        { To convert byte (word)}
  record
    lo,hi: byte;
  end;
begin
  reset(f);					{ Begin of file 	}
  tot:=0;					{ Total number of data	}
  repeat					{ Read hex file into m	}
    read(f,ch);                                 { Read begin character  }
    if ch=':' then                              { Start with colon      }
    begin
      sum:=0;                                   { Reset checksum        }
      n:=rdhex;                                 { Get number of bytes   }
      hilo(adr2).hi:=rdhex;			{ Get low address	}
      hilo(adr2).lo:=rdhex;			{ Get high address	}
      hexrec:=rdhex;                            { Get record type       }
      if hexrec=0 then                          { Data record:          }
      begin
	for n:=1 to n do			{ For all n data do	}
	begin
	  d:=rdhex;				{   Read data		}
	  if (adr2>=adr) and (adr2<adr+count) then	{ Check limits	}
	  begin
	    m[adr2-adr]:=d;			{ Store data		}
	    inc(cnt);				{ Count number of data	}
	  end;
	  inc(tot);				{ Number of total data	}
	  inc(adr2);				{ Next hex address	}
	end;
      end;
      d:=rdhex; 				{ Dummy read checksum	}
      if sum<>0 then ihxerr(2); 		{ Verify checksum	}
    end;
    readln(f);                                  { Next line             }
  until hexrec=1;				{ Until EOF record	}
end;

procedure ihxwrite(var f: text; var memory; adr: word; count: word);
var
  m: array[0..32767] of byte absolute memory;   { Access as byte        }
  n: word;                                      { Number of counts      }
  i: word;                                      { Index for m           }
procedure wrhex(data: byte);                    { Writes hex to file    }
const
  hx: array[0..15] of char =                    { Define hex chars      }
    ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
begin
  sum:=sum+data;                                { Update checksum       }
  write(f,hx[data shr 4],hx[data and $f]);      { Write hex             }
end;
begin
  i:=0;                                         { Reset variable index  }
  repeat
    if count<$10 then n:=count else n:=$10;     { Setup number of count }
    sum:=0;                                     { Reset checksum        }
    write(f,':');                               { Begin line            }
    wrhex(n);                                   { Number of data        }
    wrhex(hi(adr));                             { High adress           }
    wrhex(lo(adr));                             { Low adress            }
    wrhex(0);                                   { 0 = data record       }
    for n:=1 to n do				{ For all n data do	}
    begin
      wrhex(m[i]);                              {   Write hex           }
      inc(i);                                   {   Next index          }
      inc(adr);                                 {   Next address        }
      dec(count);                               {   Adjust count        }
    end;
    wrhex(-sum);                                { Checksum              }
    writeln(f);                                 { Next line             }
  until count=0;                                { Until no more counts  }
end;

procedure ihxendwrite(var f: text);             { Write end of record   }
begin
  writeln(f,':00000001FF');                     { Write end data record }
end;

end.
