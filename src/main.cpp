#include <iostream>
#include <fstream>
#include <cstring>
#include <cstdlib>
#include <string>
#include <memory>
#include "CommandLine.hpp"
#include "BufferManager.hpp"
#include "JDMProgrammer.hpp"
#include "PICDevice.hpp"
#include "Menu.hpp"

using namespace icprog;

void printSupportedDevices() {
    auto devices = PICDevice::getSupportedDevices();
    std::cout << "Supported PIC devices:\n";
    for (const auto& dev : devices) {
        std::cout << "  " << dev << "\n";
    }
}

void showMenu(BufferManager& bufferMgr, JDMProgrammer& prog) {
    Menu& menu = Menu::instance();
    menu.run();
}

int main(int argc, char* argv[]) {
    CommandLine cmdLine(argc, argv);
    
    if (!cmdLine.parse() || cmdLine.args().help) {
        cmdLine.printHelp();
        return 0;
    }

    const auto& args = cmdLine.args();
    
    if (args.device.empty() && args.action.empty() && args.port.empty()) {
        BufferManager bufferMgr;
        JDMProgrammer prog;
        showMenu(bufferMgr, prog);
        return 0;
    }

    if (args.device.empty()) {
        std::cout << "IC-Prog Linux Port\n";
        std::cout << "Usage: icprog -d <device> -p <port> [action] [options]\n";
        std::cout << "Use -h for help.\n\n";
        printSupportedDevices();
        return 1;
    }

    BufferManager bufferMgr;
    try {
        bufferMgr.setDevice(args.device);
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << "\n";
        return 1;
    }

    if (!args.inputFile.empty()) {
        bufferMgr.loadFile(0, args.inputFile);
    }

    JDMProgrammer prog;
    std::string port = args.port.empty() ? "/dev/ttyUSB0" : args.port;

    if (args.action == "erase") {
        if (!prog.initialize(port, args.baudrate)) {
            std::cerr << "Failed to initialize programmer on " << port << "\n";
            return 1;
        }
        std::cout << "Erasing chip...\n";
        if (prog.eraseChip()) {
            std::cout << "Erase complete.\n";
        } else {
            std::cerr << "Erase failed.\n";
            return 1;
        }
        prog.shutdown();
        return 0;
    }

    if (args.action == "read") {
        if (!prog.initialize(port, args.baudrate)) {
            std::cerr << "Failed to initialize programmer on " << port << "\n";
            return 1;
        }
        std::cout << "Reading chip...\n";
        auto& buffer = bufferMgr.getBuffer(0);
        if (prog.readChip(buffer)) {
            std::cout << "Read complete.\n";
            if (!args.outputFile.empty()) {
                bufferMgr.saveFile(0, args.outputFile);
            }
        } else {
            std::cerr << "Read failed.\n";
            return 1;
        }
        prog.shutdown();
        return 0;
    }

    if (args.action == "write") {
        if (!prog.initialize(port, args.baudrate)) {
            std::cerr << "Failed to initialize programmer on " << port << "\n";
            return 1;
        }
        std::cout << "Programming chip...\n";
        auto& buffer = bufferMgr.getBuffer(0);
        if (prog.programChip(buffer)) {
            std::cout << "Program complete.\n";
            if (args.verbose) {
                std::cout << "Verifying...\n";
                if (prog.verifyChip(buffer)) {
                    std::cout << "Verify OK.\n";
                } else {
                    std::cerr << "Verify failed.\n";
                    return 1;
                }
            }
        } else {
            std::cerr << "Program failed.\n";
            return 1;
        }
        prog.shutdown();
        return 0;
    }

    if (args.action == "verify") {
        if (!prog.initialize(port, args.baudrate)) {
            std::cerr << "Failed to initialize programmer on " << port << "\n";
            return 1;
        }
        std::cout << "Verifying chip...\n";
        auto& buffer = bufferMgr.getBuffer(0);
        if (prog.verifyChip(buffer)) {
            std::cout << "Verify OK.\n";
        } else {
            std::cerr << "Verify failed.\n";
            return 1;
        }
        prog.shutdown();
        return 0;
    }

    cmdLine.printHelp();
    return 0;
}
