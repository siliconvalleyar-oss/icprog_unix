# icprog_unix

Linux port of IC-Prog - a PIC microcontroller programmer.

## Overview

This is a reverse-engineered Linux port of IC-Prog, the original Windows-based PIC microcontroller programmer developed by Varicap. The project includes:

- Full reverse engineering documentation of the original `icprog.exe` binary
- Analysis of the JDM hardware interface source code (Turbo Pascal)
- A complete C++17 implementation for Linux with ncurses terminal interface
- Support for multiple PIC devices (16F84, 16F876, 16F873, 12C50x, etc.)
- Intel HEX file parsing
- FTDI USB-serial adapter support
- Interactive menu system (ncurses)

## Features

- **Interactive Menu**: Full-screen ncurses interface similar to original
- **Device Support**: PIC16F84, PIC16F84A, PIC16F876, PIC16F873, PIC12C50x, and more
- **File Formats**: Intel HEX 8/16-bit, Motorola S-record, Binary, EEPROM
- **Hardware Interface**: JDM programmer via RS-232 or FTDI USB
- **5 Buffer System**: Multiple buffers for data comparison
- **Command Line**: Full CLI support for scripting

## Building

### Prerequisites
- C++17 compiler (g++ 7.0+ or clang 5.0+)
- libftdi1 development library
- libusb-1.0 development library
- ncurses development library

### Install dependencies (Ubuntu/Debian)
```bash
sudo apt install build-essential libftdi1-dev libusb-1.0-dev libncurses-dev
```

### Build
```bash
make
```

### Build with CMake
```bash
mkdir build && cd build
cmake ..
make
```

## Usage

### Interactive Mode
```bash
./bin/icprog
```

### Command Line Mode
```bash
# Read a PIC16F84
./bin/icprog -d PIC16F84 -p /dev/ttyUSB0 -r -o output.hex

# Write a PIC16F84
./bin/icprog -d PIC16F84 -p /dev/ttyUSB0 -w -i input.hex

# Erase a PIC16F84
./bin/icprog -d PIC16F84 -p /dev/ttyUSB0 -e

# Verify a PIC16F84
./bin/icprog -d PIC16F84 -p /dev/ttyUSB0 -v -i input.hex
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

## Documentation

- `docs/01-binary-analysis.md` - Analysis of original icprog.exe
- `docs/02-source-code-analysis.md` - Analysis of JDM Pascal source
- `docs/03-serial-protocol.md` - JDM serial protocol details
- `docs/04-hardware-interface.md` - Hardware interface specifications
- `docs/05-pic-devices.md` - PIC device documentation
- `docs/06-command-reference.md` - Command reference
- `docs/07-linux-port-guide.md` - Linux port guide
- `docs/TODO.md` - Project checklist

## License

MIT License - see [LICENSE](LICENSE) for details.

## Original Project

- Original software: IC-Prog by Varicap
- Original source: JDM PIC Programmer by Jens Dyekjær Madsen (1997-1999)
- Tutorial: TUTOICPROG.PDF by Prof. Bolaños D.
