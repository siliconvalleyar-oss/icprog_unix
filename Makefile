# Makefile for IC-Prog Linux Port
# Compiles to obj/ directory, binary to bin/ directory

CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -O2 -Isrc
LDFLAGS = $(shell pkg-config --libs libftdi1) -lncursesw -lpthread

# Source files
SRCS = src/main.cpp \
       src/SerialPort.cpp \
       src/PICDevice.cpp \
       src/HexFile.cpp \
       src/JDMProgrammer.cpp \
       src/BufferManager.cpp \
       src/CommandLine.cpp \
       src/Menu.cpp

# Object files (in obj/)
OBJS = $(SRCS:src/%.cpp=obj/%.o)

# Target binary
TARGET = bin/icprog

# Default target
all: $(TARGET)

# Create directories
$(shell mkdir -p obj bin)

# Link binary
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)

# Compile source files
obj/%.o: src/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

# Clean
clean:
	rm -rf obj bin

# Run
run: $(TARGET)
	./$(TARGET)

.PHONY: all clean run