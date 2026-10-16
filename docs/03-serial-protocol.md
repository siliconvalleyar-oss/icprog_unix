# Serial Protocol - JDM PIC Programmer

## Overview

The JDM programmer uses a bit-serial protocol over RS-232 to communicate with PIC microcontrollers. The protocol is implemented in the JDM84PGM.PAS unit.

## Baud Rate Handling

The original Pascal code uses a unique baud rate adjustment technique:
- Default baud rate: 115200 (for timing)
- Programmable delays via baud rate divisor manipulation
- Hardware check uses 9600 baud for initial detection

## Command Encoding

Each command is encoded as a 16-bit word sent bit-by-bit over the serial line:

```
Bit 15-9: Command opcode (7 bits)
Bit 8:    Data direction (0=write, 1=read)
Bit 7-0:  Data byte (8 bits)
```

## Command Set

| Command Name | Opcode | Description |
|-------------|--------|-------------|
| LoadCfg | $1600 | Load configuration word |
| LoadPgm | $1602 | Load data for program memory |
| ReadPgm | $1604 | Read data from program memory |
| IncAdr | $0606 | Increment address |
| Begpgm | $0608 | Begin programming |
| Endpgm | $060E | End programming |
| LoadData | $1603 | Load data for data memory |
| ReadData | $1605 | Read data from data memory |
| ErasePgm | $0609 | Bulk erase program memory |
| EraseData | $060B | Bulk erase data memory |
| EraseAll1 | $0601 | EraseAll, first part |
| EraseAll2 | $0607 | EraseAll, next part |
| LoadCfg16 | $1800 | Load configuration - 16 bit |
| LoadPgm16 | $1802 | Load data - 16 bit |
| ReadPgm16 | $1804 | Read data - 16 bit |
| Null | $0000 | No command |

## Bit-Level Protocol

### Data Output (dout)

```pascal
procedure dout(val: byte);
begin
  send(val or 2);       // Output value with clock high
  send(val and din);    // Output value with clock low
  port[base4]:=0;       // RTS low, DTR low
  if din<>val then
    for i:=1 to rdzerodel do send(0);  // Extra recharge delay
end;
```

### Data Input (din)

```pascal
function din: byte;
begin
  din:=(port[base6] shr 4) and 1;  // Read data bit from status register
end;
```

## Timing Requirements

### Default Delays
- `readdelay = 1` ms - Delay between reads
- `pulsedelay = 5` ms - Delay between programming pulses
- `progdelay = 10` ms - Programming delay for 16C8x
- `eradelay = 20` ms - Erase delays
- `ioplusdel = 1` - Extra I/O delay
- `rdzerodel = 5` - Extra delay reading zero

### Hardware Check Sequence

1. Set RTS low, DTR low
2. Wait 1ms
3. Check if modem is connected (bit 4 of status register)
4. Toggle DTR/RTS 20 times with 100us delays
5. Check programmer response by toggling RTS 40 times
6. Measure I/O delay for cable length detection

## MCLR Reset Sequence

```pascal
procedure mclr;
begin
  brkstate:=port[base3];     // Save break state
  check;                      // Perform hardware check
  if brkstate and $40 = 0 then  // If TxD is low
    port[base3]:=$47;         // Enable break, MCLR on
    waitdelay(350);           // Power on delay, 350ms
  port[base3]:=7;            // Start reset, MCLR low
  for i:=1 to 3 do           // 3 pulses
    port[base]:=0;           // Output zero
    repeat until boolean(port[base5] and $20);  // Wait on empty
  port[base3]:=$47;          // Enable break, no reset
  delay100us;                // Delay 100us
end;
```

## Programming Cycle

```pascal
procedure pgmcycle;
begin
  pgm(loadpgm,d);            // Load address program
  begincmd;                  // Do not disturb timing
  pgm(begpgm,0);             // Begin programming
  delay100us;                // Delay 100us
  pgm(endpgm,0);             // End programming
  endcmd;                    // Disturb timing ok
  waitdelay(pulsedelay);     // Delay 1 ms after pulse
end;
```

## Erase Procedure

```pascal
procedure erase;
begin
  mclr;                      // Start, reset
  pgm(loadcfg,$3fff);        // Setup config word
  for i:=1 to 7 do pgm(incadr,0);  // Address at config word
  pgm(EraseAll1,0);          // Erase part 1
  pgm(EraseAll2,0);          // Erase part 2
  pgm(begpgm,0);             // Start programming
  waitdelay(eradelay);       // Delay 20ms
  pgm(loaddata,$3fff);       // Setup data word
  pgm(begpgm,0);             // Start programming
  waitdelay(eradelay);       // Delay 20ms
  pgm(EraseAll1,0);          // End erase part 1
  pgm(EraseAll2,0);          // End erase part 2
end;
```

## Error Codes

| Code | Message | Description |
|------|---------|-------------|
| 0 | No Error Found | Operation successful |
| 1 | Comport not found | Serial port not available |
| 2 | Modem found | Modem detected on port |
| 3 | Ilegal parameter value | Invalid parameter |
| 4 | Programmer not found | JDM programmer not responding |
| 5 | Cable too long | Cable length exceeds limit |
