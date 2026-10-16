# Binary Analysis - icprog.exe

## File Information

- **Filename**: icprog.exe
- **Size**: 2,967,040 bytes (2.9 MB)
- **Type**: PE32 executable (GUI) Intel 80386, for MS Windows
- **Subsystem**: Windows GUI (Subsystem ID: 2)
- **Image Base**: 0x00400000
- **Entry Point**: 0x00134858
- **Section Alignment**: 0x1000
- **Sections**: 8 sections (CODE, DATA, .idata, .tls, .rsrc, .reloc, .rdata)
- **Compiler**: Borland Delphi (Turbo Pascal runtime)
- **Date**: May 14, 2008

## PE Header Analysis

### DLL Dependencies

| DLL | Purpose |
|-----|---------|
| kernel32.dll | Core Windows API (file I/O, memory, threads, serial) |
| user32.dll | Windowing, GUI, message handling |
| advapi32.dll | Registry access, Windows services |
| oleaut32.dll | OLE Automation (Variant types) |
| version.dll | File version info |
| gdi32.dll | Graphics Device Interface |
| ole32.dll | OLE/COM support |
| comctl32.dll | Common controls (ImageList, etc.) |
| imm32.dll | Input Method Editor support |
| winspool.drv | Printing support |
| shell32.dll | Shell functions (drag-drop, execute) |
| comdlg32.dll | Common dialog (open/save) |

### Key Imported Functions

**Serial Port Communication** (from kernel32.dll):
- CreateFileA - Open COM port
- ReadFile - Read from serial
- WriteFile - Write to serial
- SetFilePointer - Seek in file
- SetCommState - Configure serial port
- SetCommTimeouts - Set read/write timeouts
- SetCommBreak - Send break signal
- PurgeComm - Purge input/output buffers
- CloseHandle - Close port
- GetCommState - Get current serial state

**Registry Access** (from advapi32.dll):
- RegOpenKeyExA - Open registry key
- RegQueryValueExA - Query registry value
- RegSetValueExA - Set registry value
- RegCloseKey - Close registry key

**DLL Loading**:
- LoadLibraryA / LoadLibraryExA - Load DLL
- GetProcAddress - Get function address

## Delphi Runtime Components

The binary contains Borland Delphi RTL (Runtime Library) components:
- TObject - Base Delphi object
- TInterfacedObject - Interface-based object
- TComponent / TComponentName - Component framework
- TThread / TThreadList - Threading support
- TReader / TWriter - Stream serialization
- TBits - Bit array
- TPicture / TBitmap - Graphics
- TComboBox / TComboBoxStrings - Combo box
- TCommonDialog - Common dialog base
- TStatusBar - Status bar
- THyperLinkLabel - Hyperlink label
- TActiveThreadArray - Active thread tracking
- TMultiReadExclusiveWriteSynchronizer - RW synchronization

## Error Messages

- "ICPROG.DLL cannot be loaded!" - DLL load failure
- "Error Loading %s module" - Generic module error
- "Checksum error on line" - HEX file checksum error
- "Clipboard copy operation failed" - Clipboard error
- "Clipboard paste operation failed." - Clipboard error
- "Internal error in Command List" - Internal state error
- "Memory Parity Error Enable" - Memory parity setting
- "Resetting card failed!" - Smart card reset failure
- "Error occured" - Generic error
- "IC-Prog error: " - Program error prefix
- "This filetype is not supported for eeprom files." - File format error
- "12 bit PIC currently not supported!" - Chip not supported
- "Only 14/12 bit PIC supported!" - Chip type error
- "Please connect your PIC programmer to the computer." - Hardware missing

## Command Line Interface

| Flag | Filetype | Extension |
|------|----------|-----------|
| -ft1 | Intel HEX 8-bit | .hex |
| -ft2 | Intel HEX 16-bit | .h16 |
| -ft3 | Binary | .bin |
| -ft5 | Motorola S | .mot / .s19 |
| -ft6 | EEPROM | .e2p / .eep |

Output files use extensions: .hex.ext, .h16.ext, .bin.ext, .mot.ext, .eep.ext

## Help File

The program references icprog.chm (compiled HTML help) and icprog.hlp (WinHelp).

## Contact Information

- Email: icprog@varicap.com
- Website: http://www.icprog.com/ (historical)
- Support: bricopic@arrakis.es
