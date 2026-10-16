# Linux Port Guide - IC-Prog

## Overview

This document describes the Linux port of IC-Prog, a PIC microcontroller programmer.

## Building

### Prerequisites
- C++17 compiler (g++ 7.0+ or clang 5.0+)
- libftdi1 development library
- libusb-1.0 development library
- CMake or Make

### Building with Make
```bash
make
```

### Building with CMake
```bash
mkdir build && cd build
cmake ..
make
```

### Build Output
- Object files: `obj/`
- Binary: `bin/icprog`

## Installation

### System-wide Installation
```bash
sudo make install
```

Or manually copy the binary:
```bash
sudo cp bin/icprog /usr/local/bin/
```

## Configuration

### Serial Port
The program supports both RS-232 serial ports and FTDI USB-serial adapters.

Common Linux serial port devices:
- `/dev/ttyS0` - First serial port
- `/dev/ttyUSB0` - First USB-serial adapter
- `/dev/ttyACM0` - First ACM adapter

### FTDI Support
The program automatically detects FTDI devices (VID:PID 0403:6001).

## Usage

### Basic Operations

1. **Read a chip:**
   ```bash
   icprog -d PIC16F84 -p /dev/ttyUSB0 -r -o output.hex
   ```

2. **Write a chip:**
   ```bash
   icprog -d PIC16F84 -p /dev/ttyUSB0 -w -i input.hex
   ```

3. **Erase a chip:**
   ```bash
   icprog -d PIC16F84 -p /dev/ttyUSB0 -e
   ```

4. **Verify a chip:**
   ```bash
   icprog -d PIC16F84 -p /dev/ttyUSB0 -v -i input.hex
   ```

### Advanced Usage

5. **Read with custom baud rate:**
   ```bash
   icprog -d PIC16F84 -p /dev/ttyUSB0 -b 19200 -r -o output.hex
   ```

6. **Write with verbose output:**
   ```bash
   icprog -d PIC16F84 -p /dev/ttyUSB0 -w -i input.hex -V
   ```

## Troubleshooting

### Common Issues

1. **"Failed to initialize programmer"**
   - Check serial port connection
   - Verify port device name
   - Check FTDI drivers

2. **"Device not found"**
   - Verify PIC device name
   - Check supported devices list

3. **"Read failed" / "Program failed"**
   - Check chip orientation
   - Verify connections
   - Try slower baud rate

### Debugging

Enable verbose output for detailed information:
```bash
icprog -d PIC16F84 -p /dev/ttyUSB0 -w -i input.hex -V
```

## Hardware Requirements

- JDM PIC programmer
- PIC microcontroller
- RS-232 serial port or FTDI USB-serial adapter
- Connection cables

## Safety Notes

1. Always verify connections before programming
2. Do not hot-swap chips during programming
3. Use proper ESD protection
4. Ensure correct voltage levels

## License

This is a reverse-engineered implementation for educational purposes.
