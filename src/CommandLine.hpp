#ifndef COMMANDLINE_HPP
#define COMMANDLINE_HPP

#include <string>
#include <vector>

namespace icprog {

struct CommandLineArgs {
    std::string action;       // read, write, erase, verify
    std::string device;       // PIC device name
    std::string port;         // Serial port device
    std::string inputFile;    // Input HEX file
    std::string outputFile;   // Output HEX file
    int baudrate = 9600;
    int bufferIndex = 0;
    bool verbose = false;
    bool help = false;
};

class CommandLine {
public:
    CommandLine(int argc, char* argv[]);
    ~CommandLine();

    bool parse();
    const CommandLineArgs& args() const { return args_; }
    void printHelp() const;

private:
    int argc_;
    char** argv_;
    CommandLineArgs args_;
};

} // namespace icprog

#endif