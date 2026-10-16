#include "BufferManager.hpp"
#include "HexFile.hpp"
#include <stdexcept>
#include <fstream>

namespace icprog {

BufferManager::BufferManager() {
    // Initialize with default PIC16F84 config
    config_ = PICDevice::findDevice("PIC16F84");
    buffers_.resize(NUM_BUFFERS);
    for (auto& buf : buffers_) {
        buf.flash.assign(config_.flash_size, 0x3FFF);
        buf.eeprom.assign(config_.eeprom_size, 0xFF);
    }
}

BufferManager::~BufferManager() {}

void BufferManager::setDevice(const std::string& deviceName) {
    config_ = PICDevice::findDevice(deviceName);
    for (auto& buf : buffers_) {
        buf.flash.assign(config_.flash_size, 0x3FFF);
        buf.eeprom.assign(config_.eeprom_size, 0xFF);
    }
}

void BufferManager::loadFile(int bufferIndex, const std::string& filename) {
    if (bufferIndex < 0 || bufferIndex >= NUM_BUFFERS) return;

    HexFile hex;
    if (!hex.load(filename)) return;

    auto& buf = buffers_[bufferIndex];
    buf.flash.assign(config_.flash_size, 0x3FFF);
    buf.eeprom.assign(config_.eeprom_size, 0xFF);

    for (const auto& rec : hex.records()) {
        if (rec.address < config_.flash_size) {
            buf.flash[rec.address] = rec.data;
        }
    }
}

void BufferManager::saveFile(int bufferIndex, const std::string& filename) const {
    if (bufferIndex < 0 || bufferIndex >= NUM_BUFFERS) return;

    HexFile hex;
    const auto& buf = buffers_[bufferIndex];
    for (uint16_t addr = 0; addr < config_.flash_size; addr++) {
        if (buf.flash[addr] != 0x3FFF) {
            hex.addRecord(addr, buf.flash[addr]);
        }
    }
    hex.save(filename);
}

void BufferManager::clearBuffer(int bufferIndex) {
    if (bufferIndex < 0 || bufferIndex >= NUM_BUFFERS) return;
    auto& buf = buffers_[bufferIndex];
    buf.flash.assign(config_.flash_size, 0x3FFF);
    buf.eeprom.assign(config_.eeprom_size, 0xFF);
}

bool BufferManager::compareBuffers(int indexA, int indexB, std::vector<std::string>& diffs) const {
    PICDevice device(config_);
    return device.compareBuffers(buffers_[indexA], buffers_[indexB], diffs);
}

void BufferManager::copyBuffer(int from, int to) {
    if (from < 0 || from >= NUM_BUFFERS || to < 0 || to >= NUM_BUFFERS) return;
    buffers_[to] = buffers_[from];
}

PICBuffer& BufferManager::getBuffer(int index) {
    return buffers_[index];
}

const PICBuffer& BufferManager::getBuffer(int index) const {
    return buffers_[index];
}

const PICConfig& BufferManager::getDeviceConfig() const {
    return config_;
}

} // namespace icprog