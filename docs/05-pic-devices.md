# PIC Devices - Supported Microcontrollers

## Overview

IC-Prog supports a wide range of PIC microcontrollers from Microchip. The following devices are supported based on the reverse engineering analysis.

## PIC16F84 / PIC16F84A

### Memory Map
- Program Memory: 1024 words (14-bit)
- Data Memory (EEPROM): 64 bytes
- Configuration Word: Address 2007
- ID Registers: Address 2007

### Configuration Word Bits
- Bit 0: Code Protect (CP)
- Bit 1: Watchdog Timer (WDT) enable
- Bit 2: Power-on Reset (PWRT) enable
- Bit 3: Oscillator type
- Bit 4-5: Not used
- Bit 6-7: Not used

### Erased State
- Program memory: 0x3FFF
- Data memory: 0xFF
- Configuration word: 0x3FFF

## PIC16F876

### Memory Map
- Program Memory: 4096 words (14-bit)
- Data Memory (EEPROM): 256 bytes
- Configuration Word: Address 8191
- ID Registers: Address 8191

## PIC16F873

### Memory Map
- Program Memory: 4096 words (14-bit)
- Data Memory (EEPROM): 128 bytes
- Configuration Word: Address 8191
- ID Registers: Address 8191

## PIC12C50x Series

### Memory Map
- Program Memory: 1024 words (12-bit)
- Data Memory: None
- Configuration Word: Address 2047

### Supported Devices
- PIC12C508
- PIC12C509
- PIC12C508A
- PIC12C509A

### Special Considerations
- 12-bit architecture (not 14-bit)
- Oscillator calibration value at address 200
- Code protect mask handling

## Configuration Word

The configuration word controls various PIC features:

| Bit | PIC16F84 | PIC16F876 | Description |
|-----|----------|-----------|-------------|
| 0 | CP | CP | Code Protect |
| 1 | WDT | WDT | Watchdog Timer |
| 2 | PWRT | PWRT | Power-on Reset |
| 3 | OSC | OSC | Oscillator type |
| 4-5 | - | - | Reserved |
| 6-7 | - | - | Reserved |

## Code Protect Behavior

When code protect is enabled:
- Reading the chip returns 0x0000 for all program memory
- Programming is disabled
- To reprogram, the chip must be erased first

## Blank/Erased State

A blank (erased) PIC returns:
- Program memory: 0x3FFF (all 1s)
- Data memory: 0xFF (all 1s)
- Configuration word: 0x3FFF

## Oscillator Calibration

Some PIC devices have an oscillator calibration value:
- Located at a specific address (e.g., address 200 for PIC12C50x)
- Value is typically 0xFF when erased
- Can be modified for precise frequency calibration

## ID Registers

ID registers can be used to identify the chip:
- 4 bytes at a specific address
- Can be programmed for tracking purposes
- Read-only after programming

## Programming Notes

1. Always erase before programming if code protect is enabled
2. Configuration word must be programmed last
3. Verify after programming for reliability
4. Use proper delays for reliable programming
