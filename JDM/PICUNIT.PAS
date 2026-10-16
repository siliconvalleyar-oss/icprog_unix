unit picunit;                           { PIC16C84-programmer unit, v31 }
interface                               { By Jens Dyekj‘r Madsen        }
type
  pgmmemtype = array[0..$3ff] of word;  { Program memory type           }
  datmemtype = array[0..$3f] of word;   { Data memory type              }
  cfgmemtype = array[0..$7] of word;    { Config memory type            }

var
  com: byte;                            { COM port                      }
  pgmmem: pgmmemtype;                   { Program memory                }
  datmem: datmemtype;                   { Data memory                   }
  cfgmem: cfgmemtype;                   { Config memory                 }

procedure eraseall;                     { Erase codeprotect+code+data   }
procedure readcfg;                      { Read config                   }
procedure readall;                      { Read code+data                }
procedure progcfg;                      { Program config                }
procedure progall;                      { Program code+data             }
function hwerror: byte;                 { Check and return error code<>0}


implementation
uses jdm84io,jdm84pgm;                  { Use jdm84io, jdm84pgm }

function hwerror: byte;                 { Check and return error code<>0}
begin
  setcom(com);                          { Setup com-port                }
  hwerror:=err;                         { Error if not ok               }
end;

procedure eraseall;                     { Erase codeprotect+code+data   }
begin
  setcom(com);                          { Setup com-port                }
  erase;                                { Call erase                    }
  releasepg;
end;


{ PIC16C84 }
procedure readcfg;                      { Read config                   }
begin
  setcom(com);                          { Setup com-port                }
  rdmem(cfgmem,loadcfg,readpgm,8);      { Read config                   }
  releasepg;
end;

procedure readall;                      { Read code+data                }
begin
  setcom(com);                          { Setup com-port                }
  rdmem(pgmmem,null,readpgm,$400);      { Read program                  }
  rdmem(datmem,null,readdata,$40);      { Read data                     }
  releasepg;
end;

procedure progcfg;                      { Program config                }
begin
  setcom(com);                          { Setup com-port                }
  progmem(cfgmem,loadcfg,readpgm,loadpgm,8);   { PGM config            }
  releasepg;
end;

procedure progall;                      { Program code+data             }
begin
  setcom(com);                          { Setup com-port                }
  progmem(pgmmem,null,readpgm,loadpgm,$400);    { PGM program           }
  progmem(datmem,null,readdata,loaddata,$40);   { PGM data              }
  releasepg;
end;

end.
