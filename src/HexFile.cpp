#include "HexFile.hpp"
#include <fstream>
#include <stdexcept>
#include <sstream>
#include <iomanip>

namespace icprog {

HexFile::HexFile() {}
HexFile::~HexFile() {}

bool HexFile::load(const std::string& filename) {
    std::ifstream file(filename);
    if (!file) return false;

    records_.clear();
    std::string line;
    while (std::getline(file, line)) {
        if (line.empty() || line[0] != ':') continue;

        // Parse Intel HEX record
        // :LLAAAATTDD...CC
        if (line.length() < 11) continue;

        try {
            unsigned int byteCount = std::stoul(line.substr(1, 2), nullptr, 16);
            unsigned int address = std::stoul(line.substr(3, 4), nullptr, 16);
            unsigned int recordType = std::stoul(line.substr(7, 2), nullptr, 16);

            if (recordType == 0) { // Data record
                for (unsigned int i = 0; i < byteCount; i++) {
                    unsigned int data = std::stoul(line.substr(9 + i*2, 2), nullptr, 16);
                    records_.push_back({static_cast<uint16_t>(address + i), static_cast<uint16_t>(data)});
                }
            } else if (recordType == 1) { // EOF
                break;
            }
        } catch (...) {
            continue;
        }
    }
    return true;
}

bool HexFile::save(const std::string& filename) const {
    std::ofstream file(filename);
    if (!file) return false;

    for (const auto& rec : records_) {
        // Write 16-byte records
        for (size_t i = 0; i < records_.size(); i += 16) {
            unsigned int count = std::min(size_t(16), records_.size() - i);
            int checksum = count + (rec.address >> 8) + (rec.address & 0xFF) + 0; // record type 0
            file << ":" << std::hex << std::uppercase << std::setfill('0')
                 << std::setw(2) << count
                 << std::setw(4) << rec.address
                 << "00";
            for (unsigned int j = 0; j < count && (i + j) < records_.size(); j++) {
                file << std::setw(2) << records_[i + j].data;
                checksum += records_[i + j].data;
            }
            file << std::setw(2) << ((~checksum + 1) & 0xFF) << std::endl;
        }
    }
    return saveEndOfFile(filename);
}

bool HexFile::saveEndOfFile(const std::string& filename) const {
    std::ofstream file(filename, std::ios::app);
    if (!file) return false;
    file << ":00000001FF" << std::endl;
    return true;
}

void HexFile::addRecord(uint16_t address, uint16_t data) {
    records_.push_back({address, data});
}

} // namespace icprog