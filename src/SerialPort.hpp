#ifndef SERIALPORT_HPP
#define SERIALPORT_HPP

#include <string>
#include <vector>
#include <cstdint>
#include <memory>

#ifdef __linux__
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>
#include <cstring>
#include <errno.h>
#include <sys/ioctl.h>
#ifdef HAVE_LIBFTDI
#include <ftdi.h>
#endif
#endif

namespace icprog {

enum class PortType {
    AUTO,    // Auto-detect (FTDI first, then serial)
    SERIAL,  // RS-232 serial port (/dev/ttyS*, /dev/ttyUSB*)
    FTDI,    // FTDI USB-serial chip
};

struct SerialConfig {
    std::string device;
    int baudrate = 9600;
    int databits = 8;
    char parity = 'N';  // N, O, E
    int stopbits = 1;
    int timeout_ms = 500;
    PortType type = PortType::AUTO;
};

class SerialPort {
public:
    SerialPort();
    ~SerialPort();

    bool open(const SerialConfig& config);
    void close();
    bool isOpen() const;

    int read(uint8_t* buf, size_t count);
    int write(const uint8_t* buf, size_t count);
    int writeRead(const uint8_t* wbuf, size_t wlen, uint8_t* rbuf, size_t rlen, int timeout_ms);
    void flush();
    void purge();

    // For JDM timing
    void delay(int milliseconds);

private:
    struct Impl;
    std::unique_ptr<Impl> impl_;
};

} // namespace icprog

#endif // SERIALPORT_HPP