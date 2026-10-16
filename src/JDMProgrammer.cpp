#include "JDMProgrammer.hpp"
#include <cstring>
#include <thread>
#include <chrono>

namespace icprog {

struct JDMProgrammer::Impl {
    SerialPort serial;
    bool initialized = false;
    uint8_t lastout = 0;
    int iodelay = 1;
    int rdzerodel = 5;
    int readdelay = 1;
    int pulsedelay = 5;
    int progdelay = 10;
    int eradelay = 20;
    uint8_t din_val = 0;
};

JDMProgrammer::JDMProgrammer() : impl_(new Impl()) {}
JDMProgrammer::~JDMProgrammer() { shutdown(); }

bool JDMProgrammer::initialize(const std::string& device, int baudrate) {
    SerialConfig config;
    config.device = device;
    config.baudrate = baudrate;
    config.type = PortType::AUTO;

    if (!impl_->serial.open(config)) return false;
    impl_->initialized = true;
    return hardwareCheck();
}

void JDMProgrammer::shutdown() {
    if (impl_->initialized) {
        impl_->serial.close();
        impl_->initialized = false;
    }
}

void JDMProgrammer::waitdelay(int ms) {
    std::this_thread::sleep_for(std::chrono::milliseconds(ms));
}

void JDMProgrammer::mclr() {
    // Reset PIC via MCLR line
    // Send break signal for 350ms, then toggle
    impl_->serial.purge();
    waitdelay(350);
    for (int i = 0; i < 3; i++) {
        uint8_t zero = 0;
        impl_->serial.write(&zero, 1);
        impl_->serial.flush();
    }
}

void JDMProgrammer::dout(uint8_t val) {
    uint8_t buf = val | 2; // Set clock high
    impl_->serial.write(&buf, 1);
    impl_->serial.flush();
    buf = val & impl_->din_val; // Clock low
    impl_->serial.write(&buf, 1);
    impl_->serial.flush();
}

uint8_t JDMProgrammer::din() {
    uint8_t buf;
    impl_->serial.read(&buf, 1);
    return (buf >> 4) & 1;
}

void JDMProgrammer::begincmd() {
    // Begin command - disable interrupts equivalent
}

void JDMProgrammer::endcmd() {
    // End command - enable interrupts equivalent
}

void JDMProgrammer::loadConfig(uint16_t data) {
    // Load configuration word
    uint16_t cmd = 0x1600;
    for (int i = 0; i < 16; i++) {
        uint8_t bit = (cmd >> i) & 1;
        dout(bit);
    }
}

void JDMProgrammer::loadProgram(uint16_t data) {
    uint16_t cmd = 0x1602;
    for (int i = 0; i < 16; i++) {
        dout((cmd >> i) & 1);
    }
}

uint16_t JDMProgrammer::readProgram() {
    uint16_t cmd = 0x1604;
    uint16_t result = 0;
    for (int i = 0; i < 16; i++) {
        dout((cmd >> i) & 1);
        result |= (din() << i);
    }
    return result;
}

void JDMProgrammer::loadEEPROM(uint16_t data) {
    uint16_t cmd = 0x1603;
    for (int i = 0; i < 16; i++) {
        dout((cmd >> i) & 1);
    }
}

uint16_t JDMProgrammer::readEEPROM() {
    uint16_t cmd = 0x1605;
    uint16_t result = 0;
    for (int i = 0; i < 16; i++) {
        dout((cmd >> i) & 1);
        result |= (din() << i);
    }
    return result;
}

void JDMProgrammer::incrementAddress() {
    uint16_t cmd = 0x0606;
    for (int i = 0; i < 16; i++) {
        dout((cmd >> i) & 1);
    }
}

void JDMProgrammer::beginProgramming() {
    uint16_t cmd = 0x0608;
    for (int i = 0; i < 16; i++) {
        dout((cmd >> i) & 1);
    }
}

void JDMProgrammer::endProgramming() {
    uint16_t cmd = 0x060E;
    for (int i = 0; i < 16; i++) {
        dout((cmd >> i) & 1);
    }
}

void JDMProgrammer::eraseAll() {
    uint16_t cmd1 = 0x0601;
    uint16_t cmd2 = 0x0607;
    for (int i = 0; i < 16; i++) dout((cmd1 >> i) & 1);
    for (int i = 0; i < 16; i++) dout((cmd2 >> i) & 1);
}

bool JDMProgrammer::hardwareCheck() {
    if (!impl_->initialized) return false;
    // Toggle DTR/RTS to check programmer presence
    impl_->serial.purge();
    waitdelay(1);
    return true;
}

bool JDMProgrammer::readChip(PICBuffer& buffer) {
    if (!impl_->initialized) return false;
    mclr();

    // Read program memory
    for (uint16_t addr = 0; addr < buffer.flash.size(); addr++) {
        buffer.flash[addr] = readProgram();
        incrementAddress();
    }
    return true;
}

bool JDMProgrammer::programChip(const PICBuffer& buffer) {
    if (!impl_->initialized) return false;
    mclr();

    // Program each word
    for (uint16_t addr = 0; addr < buffer.flash.size(); addr++) {
        if (buffer.flash[addr] != 0x3FFF) {
            loadProgram(buffer.flash[addr]);
            beginProgramming();
            waitdelay(impl_->progdelay);
            endProgramming();
        }
        incrementAddress();
    }
    return true;
}

bool JDMProgrammer::eraseChip() {
    if (!impl_->initialized) return false;
    mclr();
    eraseAll();
    beginProgramming();
    waitdelay(impl_->eradelay);
    return true;
}

bool JDMProgrammer::verifyChip(const PICBuffer& buffer) {
    PICBuffer read_buffer;
    if (!readChip(read_buffer)) return false;
    return buffer.flash == read_buffer.flash;
}

} // namespace icprog