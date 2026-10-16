#include "CommandLine.hpp"
#include <cstring>
#include <iostream>

namespace icprog {

CommandLine::CommandLine(int argc, char* argv[]) : argc_(argc), argv_(argv) {}

CommandLine::~CommandLine() {}

bool CommandLine::parse() {
    for (int i = 1; i < argc_; i++) {
        std::string arg = argv_[i];

        if (arg == "-h" || arg == "--help") {
            args_.help = true;
            return true;
        } else if (arg == "-r" || arg == "--read") {
            args_.action = "read";
        } else if (arg == "-w" || arg == "--write") {
            args_.action = "write";
        } else if (arg == "-e" || arg == "--erase") {
            args_.action = "erase";
        } else if (arg == "-v" || arg == "--verify") {
            args_.action = "verify";
        } else if (arg == "-d" || arg == "--device") {
            if (i + 1 < argc_) args_.device = argv_[++i];
        } else if (arg == "-p" || arg == "--port") {
            if (i + 1 < argc_) args_.port = argv_[++i];
        } else if (arg == "-i" || arg == "--input") {
            if (i + 1 < argc_) args_.inputFile = argv_[++i];
        } else if (arg == "-o" || arg == "--output") {
            if (i + 1 < argc_) args_.outputFile = argv_[++i];
        } else if (arg == "-b" || arg == "--baud") {
            if (i + 1 < argc_) args_.baudrate = std::stoi(argv_[++i]);
        } else if (arg == "-V" || arg == "--verbose") {
            args_.verbose = true;
        }
    }
    return true;
}

void CommandLine::printHelp() const {
    std::cout << "IC-Prog Linux Port - PIC Microcontroller Programmer\n\n";
    std::cout << "Usage: icprog [OPTIONS]\n\n";
    std::cout << "Actions:\n";
    std::cout << "  -r, --read       Read chip to output file\n";
    std::cout << "  -w, --write      Write input file to chip\n";
    std::cout << "  -e, --erase      Erase chip\n";
    std::cout << "  -v, --verify     Verify chip against buffer\n\n";
    std::cout << "Options:\n";
    std::cout << "  -d, --device     PIC device name (e.g., PIC16F84)\n";
    std::cout << "  -p, --port       Serial port device (e.g., /dev/ttyUSB0)\n";
    std::cout << "  -i, --input      Input HEX file\n";
    std::cout << "  -o, --output     Output HEX file\n";
    std::cout << "  -b, --baud       Baud rate (default: 9600)\n";
    std::cout << "  -V, --verbose    Verbose output\n";
    std::cout << "  -h, --help       Show this help\n\n";
    std::cout << "Supported devices: PIC16F84, PIC16F84A, PIC16F876, PIC16F873, etc.\n";
}

} // namespace icprog