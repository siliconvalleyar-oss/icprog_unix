# Hardware Interface - JDM PIC Programmer

## Overview

The JDM (Jens Dyekjaer Madsen) programmer is a simple serial-port-based PIC programmer that uses the RS-232 handshake lines (RTS and DTR) to control the programming signals.

## Pinout

The JDM programmer typically uses a DB9 serial connector with the following connections:

| Pin | Signal | Direction | Purpose |
|-----|--------|-----------|---------|
| 1 | CD | Input | Carrier detect (unused) |
| 2 | RX | Input | Serial receive |
| 3 | TX | Output | Serial transmit |
| 4 | DTR | Input | Data terminal ready (VCC control) |
| 5 | GND | - | Ground |
| 6 | DSR | Input | Data set ready (unused) |
| 7 | RTS | Input | Request to send (MCLR control) |
| 8 | CTS | Input | Clear to send (unused) |
| 9 | RI | Input | Ring indicator (unused) |

## Signal Mapping

### RTS (Request to Send) - Pin 7
- Controls MCLR (Master Clear) line
- When RTS is high, MCLR is high (reset inactive)
- When RTS is low, MCLR is low (reset active)
- Used for reset and programming mode entry

### DTR (Data Terminal Ready) - Pin 4
- Controls VCC power to the PIC
- When DTR is high, VCC is applied
- When DTR is low, VCC is removed
- Used for power control during programming

## Hardware Check Algorithm

The hardware check verifies that the JDM programmer is properly connected:

1. Set both RTS and DTR low
2. Wait 1ms for signals to stabilize
3. Check if a modem is connected (read status register bit 4)
4. If modem detected, return error
5. Toggle DTR/RTS 20 times with 100us delays
6. Check programmer response by toggling RTS 40 times
7. Measure I/O delay to detect cable length
8. If I/O delay >= 40, cable is too long

## VCC Control for JDM

The JDM programmer can control VCC through the DTR line:
- Enable VCC control for JDM in settings
- DTR high = VCC applied to PIC
- DTR low = VCC removed from PIC
- Required for proper programming sequence

## MCLR/VPP Control

The MCLR line serves dual purpose:
- Normal operation: MCLR is an input (reset)
- Programming mode: MCLR becomes VPP (programming voltage)
- RTS controls the MCLR/VPP line

## I2C EEPROM Interface

For serial EEPROM programming, the JDM interface also provides:
- SDA (Serial Data) - controlled via DTR bit 0
- SCL (Serial Clock) - controlled via DTR bit 1

```pascal
procedure sda(val: byte);
begin
  lastout:=(lastout and $fe) or val;  // Update lastout
  send(lastout);                       // Output lastout
end;

procedure scl(val: byte);
begin
  lastout:=(lastout and $fd) or 2*val;  // Update lastout
  send(lastout);                         // Output lastout
end;

function rda: byte;
begin
  rda:=(port[base6] shr 4) and 1;  // Read SDA
end;
```

## Cable Length Detection

The hardware check measures the time it takes for a signal to propagate through the cable:
- If the I/O delay is >= 40 units, the cable is too long
- Typical maximum cable length: 15 feet (5 meters)
- Longer cables may require slower clock speeds

## Delay Calibration

The I/O delay can be calibrated:
- Default: `ioplusdel = 1`
- Range: 0-255
- Higher values = slower communication = more reliable
- Lower values = faster communication = less reliable

## Connection Diagram

```
Computer (RS-232)          JDM Programmer           PIC Microcontroller
---------                  -------------            -----------------
  RTS (pin 7)  --------->  MCLR/VPP control         MCLR/VPP (pin 1)
  DTR (pin 4)  --------->  VCC control               VCC (pin 1)
  TX  (pin 3)  --------->  Serial data               ICSP data
  RX  (pin 2)  <---------  Serial data               ICSP clock
  GND (pin 5)  --------->  Ground                    Ground
```

## Power Requirements

- PIC VCC: 5V (controlled by DTR)
- Programming VPP: typically 13V for PIC16F84
- Current: < 100mA
- Power source: Computer USB or external supply
