#ifndef JDMPROGRAMMER_HPP
#define JDMPROGRAMMER_HPP

#include "SerialPort.hpp"
#include "PICDevice.hpp"
#include <memory>

namespace icprog {

class JDMProgrammer {
public:
    JDMProgrammer();
    ~JDMProgrammer();

    bool initialize(const std::string& device, int baudrate = 9600);
    void shutdown();

    bool hardwareCheck();
    bool readChip(PICBuffer& buffer);
    bool programChip(const PICBuffer& buffer);
    bool eraseChip();
    bool verifyChip(const PICBuffer& buffer);

    // Low-level JDM commands
    void mclr();              // Reset PIC
    void dout(uint8_t val);   // Output data bit
    uint8_t din();            // Input data bit
    void begincmd();          // Begin command
    void endcmd();            // End command
    void waitdelay(int ms);   // Delay

    // PIC commands
    void loadConfig(uint16_t data);
    void loadProgram(uint16_t data);
    uint16_t readProgram();
    void loadEEPROM(uint16_t data);
    uint16_t readEEPROM();
    void incrementAddress();
    void beginProgramming();
    void endProgramming();
    void eraseAll();

private:
    struct Impl;
    std::unique_ptr<Impl> impl_;
};

} // namespace icprog

#endif