#include "PICDevice.hpp"
#include "HexFile.hpp"
#include <fstream>
#include <algorithm>
#include <stdexcept>
#include <cstring>

namespace icprog {

PICDevice::PICDevice(const PICConfig& config) : config_(config) {
    resetBuffer();
}

PICDevice::~PICDevice() {}

const PICConfig& PICDevice::getConfig() const { return config_; }
PICBuffer& PICDevice::getBuffer() { return buffer_; }
const PICBuffer& PICDevice::getBuffer() const { return buffer_; }

void PICDevice::resetBuffer() {
    buffer_.flash.assign(config_.flash_size, 0x3FFF);  // Erased state
    buffer_.eeprom.assign(config_.eeprom_size, 0xFF);
    buffer_.config_word = 0x3FFF;
    buffer_.config_valid = false;
    buffer_.id_valid = false;
    memset(buffer_.id_bytes, 0xFF, 4);
}

bool PICDevice::loadHexFile(const std::string& filename) {
    HexFile hex;
    if (!hex.load(filename)) return false;

    resetBuffer();

    for (const auto& rec : hex.records()) {
        if (rec.address < config_.flash_size) {
            buffer_.flash[rec.address] = rec.data;
        }
    }
    return true;
}

bool PICDevice::saveHexFile(const std::string& filename) {
    HexFile hex;
    for (uint16_t addr = 0; addr < config_.flash_size; addr++) {
        if (buffer_.flash[addr] != 0x3FFF) {
            hex.addRecord(addr, buffer_.flash[addr]);
        }
    }
    return hex.save(filename);
}

bool PICDevice::loadBinaryFile(const std::string& filename, uint16_t start_addr) {
    std::ifstream file(filename, std::ios::binary);
    if (!file) return false;

    resetBuffer();
    uint16_t addr = start_addr;
    uint8_t byte;
    while (file.read(reinterpret_cast<char*>(&byte), 1) && addr < config_.flash_size) {
        buffer_.flash[addr++] = byte;
    }
    return true;
}

bool PICDevice::compareBuffers(const PICBuffer& a, const PICBuffer& b, std::vector<std::string>& diffs) const {
    diffs.clear();
    bool equal = true;

    for (size_t i = 0; i < a.flash.size() && i < b.flash.size(); i++) {
        if (a.flash[i] != b.flash[i]) {
            diffs.push_back("Flash[" + std::to_string(i) + "]: " +
                          std::to_string(a.flash[i]) + " != " + std::to_string(b.flash[i]));
            equal = false;
        }
    }

    for (size_t i = 0; i < a.eeprom.size() && i < b.eeprom.size(); i++) {
        if (a.eeprom[i] != b.eeprom[i]) {
            diffs.push_back("EERP[" + std::to_string(i) + "]: " +
                          std::to_string(a.eeprom[i]) + " != " + std::to_string(b.eeprom[i]));
            equal = false;
        }
    }

    if (a.config_word != b.config_word) {
        diffs.push_back("Config: " + std::to_string(a.config_word) + " != " +
                       std::to_string(b.config_word));
        equal = false;
    }

    return equal;
}

PICConfig PICDevice::findDevice(const std::string& name) {
    auto devices = getSupportedDevices();
    for (const auto& dev_name : devices) {
        if (dev_name == name) {
            PICConfig cfg;
            cfg.name = dev_name;

            // Define known PIC devices
            if (name == "PIC16F84" || name == "PIC16F84A") {
                cfg.flash_size = 1024;
                cfg.eeprom_size = 64;
                cfg.config_addr = 2007;
                cfg.id_addr = 2007;
                cfg.has_eeprom = true;
                cfg.is_14bit = true;
            } else if (name == "PIC16F876") {
                cfg.flash_size = 4096;
                cfg.eeprom_size = 256;
                cfg.config_addr = 8191;
                cfg.id_addr = 8191;
                cfg.has_eeprom = true;
                cfg.is_14bit = true;
            } else if (name == "PIC16F873") {
                cfg.flash_size = 4096;
                cfg.eeprom_size = 128;
                cfg.config_addr = 8191;
                cfg.id_addr = 8191;
                cfg.has_eeprom = true;
                cfg.is_14bit = true;
            } else if (name == "PIC16F628A" || name == "PIC16F628") {
                cfg.flash_size = 2048;
                cfg.eeprom_size = 128;
                cfg.config_addr = 4095;
                cfg.id_addr = 4095;
                cfg.has_eeprom = true;
                cfg.is_14bit = true;
            } else if (name == "PIC12F675") {
                cfg.flash_size = 1024;
                cfg.eeprom_size = 0;
                cfg.config_addr = 1023;
                cfg.id_addr = 1023;
                cfg.has_eeprom = false;
                cfg.is_14bit = true;
            } else {
                cfg.flash_size = 1024;
                cfg.eeprom_size = 64;
                cfg.config_addr = 2007;
                cfg.has_eeprom = true;
                cfg.is_14bit = true;
            }
            return cfg;
        }
    }
    throw std::runtime_error("Unknown PIC device: " + name);
}

} // namespace icprog