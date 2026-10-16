#ifndef BUFFERMANAGER_HPP
#define BUFFERMANAGER_HPP

#include "PICDevice.hpp"
#include <vector>
#include <string>

namespace icprog {

class BufferManager {
public:
    BufferManager();
    ~BufferManager();

    void setDevice(const std::string& deviceName);
    void loadFile(int bufferIndex, const std::string& filename);
    void saveFile(int bufferIndex, const std::string& filename) const;
    void clearBuffer(int bufferIndex);
    bool compareBuffers(int indexA, int indexB, std::vector<std::string>& diffs) const;
    void copyBuffer(int from, int to);

    PICBuffer& getBuffer(int index);
    const PICBuffer& getBuffer(int index) const;
    const PICConfig& getDeviceConfig() const;

    static const int NUM_BUFFERS = 5;

private:
    PICConfig config_;
    std::vector<PICBuffer> buffers_;
};

} // namespace icprog

#endif