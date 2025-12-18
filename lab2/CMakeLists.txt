cmake_minimum_required(VERSION 3.23)
set(CMAKE_CXX_STANDARD 23)

project(function_verification VERSION 0.1)

find_package(verilator REQUIRED)


list(APPEND VERILOG_SOURCES
     "${CMAKE_CURRENT_SOURCE_DIR}/double_multiplier.v"
)

list(APPEND CPP_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/double_multiplier.cpp"
)


add_executable("program")
verilate(program SOURCES ${VERILOG_SOURCES})

target_sources("program" PRIVATE ${CPP_SOURCES})
install(TARGETS "program")

