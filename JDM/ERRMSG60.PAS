unit errmsg60;          { Error messages for Turbo Pascal 6.0 - Ver 1.2 }
interface               { Copyright (c) 1997-1998, Jens Dyekj‘r Madsen  }

var
  fnameptr: ^string;                            { Pointer to filename   }

implementation

{ Turbo Pascal errormessages }
const
  erroridx: string[35] =                        { Define error numbers  }
    #1#2#3#4#5#6#12#15#16#17#100#101#102#103#104#105#106+
    #150#151#152#153#154#155#156#157#158#159#160#161#162+
    #200#201#202#203#204;

  errormsg: array[0..35] of string[34] = (      { Define error messages }
    'Unknown error',
    'Invalid function number',
    'File not found',
    'Path not found',
    'Too many open files',
    'File access denied',
    'Invalid file handle',
    'Invalid file access code',
    'Invalid drive number',
    'Cannot remove current directory',
    'Cannot rename across drives',
    'Disk read error',
    'Disk write error',
    'File not assigned',
    'File not open',
    'File not open for input',
    'File not open for output',
    'Invalid numeric format',
    'Disk is write-protected',
    'Unknown unit',
    'Drive not ready',
    'Unknown command',
    'CRC error in data',
    'Bad drive request structure length',
    'Disk seek error',
    'Unknown media type',
    'Sector not found',
    'Printer out of paper',
    'Device write fault',
    'Device read fault',
    'Hardware failure',
    'Division by zero',
    'Range check error',
    'Stack overflow error',
    'Not enough memory',
    'Invalid pointer operation');

var
  exitsave: pointer;                            { Saves exitproc        }

procedure newexit; far;                         { Handle errors         }
begin
  if erroraddr<>NIL then                        { If error then:        }
  begin
    if (fnameptr<>NIL) and (exitcode<200) then  { Errortype = file?     }
      write('Filename: ''',fnameptr^,'''. ') else write('Internal error: ');
    writeln(errormsg[pos(chr(exitcode),erroridx)],'.'); { Write errortyp}
    erroraddr:=NIL;                             { Reset error           }
  end;
  exitproc:=exitsave;                           { Saved exitproc        }
end;

begin
  fnameptr:=NIL;                                { Clear errortext       }
  exitsave:=exitproc;                           { Saves exitproc        }
  exitproc:=@newexit;                           { Setup new exitproc    }
end.
