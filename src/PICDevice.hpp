#ifndef PICDEVICE_HPP
#define PICDEVICE_HPP

#include <string>
#include <vector>
#include <cstdint>

namespace icprog {

struct PICConfig {
    std::string name;
    uint16_t flash_size;
    uint16_t eeprom_size;
    uint16_t config_addr;
    uint16_t id_addr;
    bool has_eeprom;
    bool is_14bit;
};

struct PICBuffer {
    std::vector<uint16_t> flash;
    std::vector<uint8_t> eeprom;
    uint16_t config_word;
    uint8_t id_bytes[4];
    bool config_valid;
    bool id_valid;
};

class PICDevice {
public:
    PICDevice(const PICConfig& config);
    ~PICDevice();

    const PICConfig& getConfig() const;
    PICBuffer& getBuffer();
    const PICBuffer& getBuffer() const;

    void resetBuffer();
    bool loadHexFile(const std::string& filename);
    bool saveHexFile(const std::string& filename);
    bool loadBinaryFile(const std::string& filename, uint16_t start_addr);
    bool compareBuffers(const PICBuffer& a, const PICBuffer& b, std::vector<std::string>& diffs) const;

    static PICConfig findDevice(const std::string& name);
    static std::vector<std::string> getSupportedDevices() {
        return {
            "PIC16F84", "PIC16F84A",
            "PIC16F876", "PIC16F873",
            "PIC16F628A", "PIC16F628",
            "PIC12F675", "PIC12F629",
            "PIC16F627", "PIC16F630",
            "PIC16F648A", "PIC16F648",
            "PIC16F877A", "PIC16F877",
            "PIC16F873A", "PIC16F873",
            "PIC16F874A", "PIC16F874",
            "PIC16F876A", "PIC16F876",
            "PIC16F881", "PIC16F882",
            "PIC16F883", "PIC16F884",
            "PIC16F886", "PIC16F887",
            "PIC16F1827", "PIC16F1829"
        };
    }

private:
    PICConfig config_;
    PICBuffer buffer_;
};

} // namespace icprog

#endif
