#ifndef HEXFILE_HPP
#define HEXFILE_HPP

#include <string>
#include <vector>
#include <cstdint>

namespace icprog {

struct HexRecord {
    uint16_t address;
    uint16_t data;
};

class HexFile {
public:
    HexFile();
    ~HexFile();

    bool load(const std::string& filename);
    bool save(const std::string& filename) const;
    bool saveEndOfFile(const std::string& filename) const;

    const std::vector<HexRecord>& records() const { return records_; }
    void addRecord(uint16_t address, uint16_t data);

private:
    std::vector<HexRecord> records_;
};

} // namespace icprog

#endif