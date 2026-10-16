# Source Code Analysis - JDM Hardware Interface

## Overview

The JDM directory contains the original Turbo Pascal source code for the JDM PIC programmer interface. This code was written by Jens Dyekjaer Madsen between 1997-1999 and serves as the reference implementation for the serial protocol used by IC-Prog.

## File Inventory

### Core Interface Unit
- **JDM84IO.PAS** - Serial I/O unit, hardware check, delay routines
- **JDM84PGM.PAS** - PIC programming commands and memory operations
- **PICUNIT.PAS** - High-level PIC operations (read, write, erase, verify)
- **INTHEX.PAS** - Intel HEX file reader/writer
- **ERRMSG60.PAS** - Error message handling
- **TIMER.PAS** - Timer synchronization for precise delays
- **SHORTDEL.PAS** - Short delay routines using 8254 timer

### Application Programs
- **PICPROG.PAS** - Program a PIC16C84 from HEX file
- **PICREAD.PAS** - Read a PIC16C84 to HEX file
- **PICTEST.PAS** - Test programmer with random data
- **PROG50X.PAS** - Program PIC12C50x devices
- **READ50X.PAS** - Read PIC12C50x devices

### Batch Files
- **PROG508.BAT** - Batch wrapper for PIC12C508
- **PROG508S.BAT** - Batch wrapper with serial
- **PROG509.BAT** - Batch wrapper for PIC12C509
- **PROG509S.BAT** - Batch wrapper with serial
- **READ508.BAT** - Read wrapper
- **READ508S.BAT** - Read wrapper with serial
- **READ509.BAT** - Read wrapper
- **READ509S.BAT** - Read wrapper with serial

### Executables
- **JDM84.EXE** - MS-DOS executable (MZ format)
- **PICPROG.EXE** - MS-DOS executable
- **PICREAD.EXE** - MS-DOS executable
- **PICTEST.EXE** - MS-DOS executable

## Architecture

The JDM interface follows a layered architecture:

```
Application Layer (PICPROG, PICREAD, PICTEST)
    |
High-Level PIC Operations (PICUNIT.PAS)
    |
Programming Commands (JDM84PGM.PAS)
    |
Serial I/O (JDM84IO.PAS)
    |
Hardware (RS-232 / JDM Programmer)
```

## Key Constants and Configuration

### Default Delays (in JDM84PGM.PAS)
- `readdelay = 1` - Delay between reads (ms)
- `pulsedelay = 5` - Delay between programming pulses (ms)
- `progdelay = 10` - Programming delay for 16C8x (ms)
- `eradelay = 20` - Erase delays (ms)

### Default I/O Delays (in JDM84IO.PAS)
- `ioplusdel = 1` - Extra I/O delay
- `rdzerodel = 5` - Extra delay reading zero

### PIC Command Constants (in JDM84PGM.PAS)
```
LoadCfg  = $1600  { Load Configuration }
LoadPgm  = $1602  { Load Data for Program Memory }
ReadPgm  = $1604  { Read Data from Program Memory }
IncAdr   = $0606  { Increment Address }
Begpgm   = $0608  { Begin Programming }
Endpgm   = $060E  { End Programming }
LoadData = $1603  { Load Data for Data Memory }
ReadData = $1605  { Read Data from Data Memory }
ErasePgm = $0609  { Bulk Erase Program Memory }
EraseData= $060B  { Bulk Erase Data Memory }
EraseAll1= $0601  { EraseAll, first }
EraseAll2= $0607  { EraseAll, next }
LoadCfg16= $1800  { Load Configuration - 16 bit }
LoadPgm16= $1802  { Load Data - 16 bit }
ReadPgm16= $1804  { Read Data - 16 bit }
Null     = $0000  { No Command }
```

## Memory Map (PIC16C84)

```
Address Range    | Size    | Content
-----------------|---------|--------------------------
$0000 - $03FF    | 1024    | Program Memory (14-bit words)
$0400 - $0407    | 8       | ID registers
$040E - $040F    | 2       | Configuration word
$4200 - $423F    | 64      | Data Memory (EEPROM)
```

Note: The Pascal code uses absolute addressing where:
- `$0000-$03FF` = program memory
- `$4000-$4007` = ID area (8 words)
- `$400E-$400F` = configuration word (2 words)
- `$4200-$423F` = data memory (64 bytes)

## Error Codes (from JDM84IO.PAS)

| Code | Message |
|------|---------|
| 0 | No Error Found |
| 1 | Comport not found |
| 2 | Modem found |
| 3 | Ilegal parameter value |
| 4 | Programmer not found |
| 5 | Cable too long |