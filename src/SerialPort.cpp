#include "SerialPort.hpp"
#include <stdexcept>
#include <cstring>
#include <thread>
#include <chrono>

#ifdef __linux__
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>
#include <cstring>
#include <errno.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <sys/time.h>
#include <poll.h>
#ifdef HAVE_LIBFTDI
#include <ftdi.h>
#endif
#endif

namespace icprog {

struct SerialPort::Impl {
    int fd = -1;
    SerialConfig config;
    bool opened = false;

#ifdef HAVE_LIBFTDI
    struct ftdi_context* ftdi = nullptr;
    bool is_ftdi = false;
#endif
};

SerialPort::SerialPort() : impl_(new Impl()) {}
SerialPort::~SerialPort() { close(); }

bool SerialPort::open(const SerialConfig& config) {
    impl_->config = config;
    impl_->fd = -1;

#ifdef __linux__
#ifdef HAVE_LIBFTDI
    if (config.type == PortType::FTDI || config.type == PortType::AUTO) {
        impl_->ftdi = ftdi_new();
        if (impl_->ftdi) {
            int ret = ftdi_usb_open(impl_->ftdi, 0x0403, 0x6001);
            if (ret == 0) {
                ftdi_set_line_property(impl_->ftdi, 8, STOPBIT_1, NONE);
                ftdi_set_baudrate(impl_->ftdi, config.baudrate);
                ftdi_set_flow_control(impl_->ftdi, FLOW_OFF);
                impl_->is_ftdi = true;
                impl_->opened = true;
                return true;
            }
            ftdi_free(impl_->ftdi);
            impl_->ftdi = nullptr;
        }
    }
#endif

    if (config.type == PortType::SERIAL || config.type == PortType::AUTO) {
        int flags = O_RDWR | O_NOCTTY | O_SYNC;
        impl_->fd = ::open(config.device.c_str(), flags);
        if (impl_->fd < 0) return false;

        struct termios tio;
        memset(&tio, 0, sizeof(tio));
        if (tcgetattr(impl_->fd, &tio) < 0) {
            ::close(impl_->fd);
            impl_->fd = -1;
            return false;
        }

        cfsetospeed(&tio, config.baudrate);
        cfsetispeed(&tio, config.baudrate);

        tio.c_cflag &= ~(CSIZE | PARENB);
        tio.c_cflag |= CS8;
        tio.c_cflag |= (CLOCAL | CREAD);
        tio.c_iflag &= ~(IXON | IXOFF | IXANY);
        tio.c_lflag &= ~(ICANON | ECHO | ISIG);
        tio.c_oflag &= ~OPOST;
        tio.c_cc[VMIN] = 0;
        tio.c_cc[VTIME] = 5;

        if (tcsetattr(impl_->fd, TCSANOW, &tio) < 0) {
            ::close(impl_->fd);
            impl_->fd = -1;
            return false;
        }
        impl_->opened = true;
        return true;
    }
#endif
    return false;
}

void SerialPort::close() {
#ifdef __linux__
#ifdef HAVE_LIBFTDI
    if (impl_->ftdi && impl_->is_ftdi) {
        ftdi_usb_close(impl_->ftdi);
        ftdi_free(impl_->ftdi);
        impl_->ftdi = nullptr;
    }
#endif
    if (impl_->fd >= 0) {
        ::close(impl_->fd);
        impl_->fd = -1;
    }
    impl_->opened = false;
#endif
}

bool SerialPort::isOpen() const { return impl_->opened; }

int SerialPort::read(uint8_t* buf, size_t count) {
#ifdef __linux__
#ifdef HAVE_LIBFTDI
    if (impl_->is_ftdi && impl_->ftdi) {
        int ret = ftdi_read_data(impl_->ftdi, buf, (int)count);
        return ret;
    }
#endif
    if (impl_->fd >= 0) {
        return (int)::read(impl_->fd, buf, count);
    }
#endif
    return 0;
}

int SerialPort::write(const uint8_t* buf, size_t count) {
#ifdef __linux__
#ifdef HAVE_LIBFTDI
    if (impl_->is_ftdi && impl_->ftdi) {
        return ftdi_write_data(impl_->ftdi, buf, (int)count);
    }
#endif
    if (impl_->fd >= 0) {
        return (int)::write(impl_->fd, buf, count);
    }
#endif
    return 0;
}

int SerialPort::writeRead(const uint8_t* wbuf, size_t wlen, uint8_t* rbuf, size_t rlen, int timeout_ms) {
    (void)timeout_ms;
    write(wbuf, wlen);
    flush();
    delay(10);
    return read(rbuf, rlen);
}

void SerialPort::flush() {
#ifdef __linux__
#ifdef HAVE_LIBFTDI
    if (impl_->is_ftdi && impl_->ftdi) {
        ftdi_usb_purge_rx_buffer(impl_->ftdi);
        return;
    }
#endif
    if (impl_->fd >= 0) {
        tcdrain(impl_->fd);
    }
#endif
}

void SerialPort::purge() {
#ifdef __linux__
#ifdef HAVE_LIBFTDI
    if (impl_->is_ftdi && impl_->ftdi) {
        ftdi_usb_purge_rx_buffer(impl_->ftdi);
        ftdi_usb_purge_tx_buffer(impl_->ftdi);
        return;
    }
#endif
    if (impl_->fd >= 0) {
        tcflush(impl_->fd, TCIOFLUSH);
    }
#endif
}

void SerialPort::delay(int milliseconds) {
    std::this_thread::sleep_for(std::chrono::milliseconds(milliseconds));
}

} // namespace icprog