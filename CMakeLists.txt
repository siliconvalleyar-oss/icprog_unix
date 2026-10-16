cmake_minimum_required(VERSION 3.16)
project(icprog VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Find required libraries
find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBFTDI REQUIRED libftdi1)

find_package(Threads REQUIRED)

add_executable(icprog
    src/main.cpp
    src/SerialPort.cpp
    src/SerialPort.hpp
    src/JDMProgrammer.cpp
    src/JDMProgrammer.hpp
    src/PICDevice.cpp
    src/PICDevice.hpp
    src/HexFile.cpp
    src/HexFile.hpp
    src/BufferManager.cpp
    src/BufferManager.hpp
    src/CommandLine.cpp
    src/CommandLine.hpp
)

target_include_directories(icprog PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_link_libraries(icprog PRIVATE
    ${LIBFTDI_LIBRARIES}
    Threads::Threads
)

# Install
install(TARGETS icprog DESTINATION bin)