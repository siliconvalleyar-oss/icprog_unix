# Command Reference - IC-Prog Linux Port

## Command Line Interface

The Linux port supports the following command-line interface:

### Actions
- `-r, --read` - Read chip to output file
- `-w, --write` - Write input file to chip
- `-e, --erase` - Erase chip
- `-v, --verify` - Verify chip against buffer

### Options
- `-d, --device` - PIC device name (e.g., PIC16F84)
- `-p, --port` - Serial port device (e.g., /dev/ttyUSB0)
- `-i, --input` - Input HEX file
- `-o, --output` - Output HEX file
- `-b, --baud` - Baud rate (default: 9600)
- `-V, --verbose` - Verbose output
- `-h, --help` - Show help

## Usage Examples

### Read a PIC16F84
```bash
icprog -d PIC16F84 -p /dev/ttyUSB0 -r -o output.hex
```

### Write a PIC16F84
```bash
icprog -d PIC16F84 -p /dev/ttyUSB0 -w -i input.hex
```

### Erase a PIC16F84
```bash
icprog -d PIC16F84 -p /dev/ttyUSB0 -e
```

### Verify a PIC16F84
```bash
icprog -d PIC16F84 -p /dev/ttyUSB0 -v -i input.hex
```

### Write with verbose output
```bash
icprog -d PIC16F84 -p /dev/ttyUSB0 -w -i input.hex -V
```

## Supported Devices

- PIC16F84, PIC16F84A
- PIC16F876, PIC16F876A
- PIC16F873, PIC16F873A
- PIC16F874, PIC16F874A
- PIC16F877, PIC16F877A
- PIC16F628, PIC16F628A
- PIC16F627, PIC16F630
- PIC16F648, PIC16F648A
- PIC12F675, PIC12F629
- PIC16F881, PIC16F882, PIC16F883, PIC16F884
- PIC16F886, PIC16F887
- PIC16F1827, PIC16F1829

## File Formats

### Intel HEX 8-bit (INHX8M)
```
:LLAAAATTDD...CC
```
- LL: Number of data bytes
- AAAA: Address
- TT: Record type (00=data, 01=EOF)
- DD: Data bytes
- CC: Checksum

### Intel HEX 16-bit (INHX16)
Similar to 8-bit but for 16-bit data

### Binary
Raw binary file

### Motorola S-record
Support for S19 files

### EEPROM
Support for .e2p and .eep files

## Exit Codes
- 0: Success
- 1: Error (check error message)
- 2: Invalid arguments
- 3: Hardware not found
