cmake_minimum_required(VERSION 3.20)

project(risc_v_team7 LANGUAGES CXX)

include(CTest)

option(BUILD_PROGRAM "Build the RISC-V program image" ON)
option(BUILD_TESTING "Build and register Verilator testbenches" ON)

if(BUILD_PROGRAM)
    find_package(Python3 COMPONENTS Interpreter REQUIRED)
    set(PROGRAM_SOURCE
        "${CMAKE_SOURCE_DIR}/testbench/asm/program.S"
        CACHE FILEPATH "RISC-V C or assembly program to convert to program.hex")
    find_program(RISCV_GCC_EXECUTABLE riscv64-unknown-elf-gcc REQUIRED)
    find_program(RISCV_AS_EXECUTABLE riscv64-unknown-elf-as REQUIRED)
    find_program(RISCV_LD_EXECUTABLE riscv64-unknown-elf-ld REQUIRED)
    find_program(RISCV_OBJCOPY_EXECUTABLE riscv64-unknown-elf-objcopy REQUIRED)
    find_program(RISCV_OBJDUMP_EXECUTABLE riscv64-unknown-elf-objdump REQUIRED)
    if(NOT EXISTS "${PROGRAM_SOURCE}")
        message(FATAL_ERROR "PROGRAM_SOURCE does not exist: ${PROGRAM_SOURCE}")
    endif()
    get_filename_component(PROGRAM_NAME "${PROGRAM_SOURCE}" NAME_WE)
    set(PROGRAM_HEX "${CMAKE_BINARY_DIR}/program.hex")
    set(PROGRAM_DIS "${CMAKE_SOURCE_DIR}/testbench/${PROGRAM_NAME}.dis")
    add_custom_command(
        OUTPUT "${PROGRAM_HEX}" "${PROGRAM_DIS}"
        COMMAND "${Python3_EXECUTABLE}"
            "${CMAKE_SOURCE_DIR}/cmake/compile_riscv.py"
            "${PROGRAM_SOURCE}"
            "--output-dir" "${CMAKE_BINARY_DIR}"
            "--hex-output" "${PROGRAM_HEX}"
            "--dis-output" "${PROGRAM_DIS}"
        DEPENDS "${PROGRAM_SOURCE}"
            "${CMAKE_SOURCE_DIR}/cmake/compile_riscv.py"
        VERBATIM
        COMMENT "Building RISC-V program ${PROGRAM_NAME}")
    add_custom_target(program DEPENDS "${PROGRAM_HEX}" "${PROGRAM_DIS}")
endif()

if(BUILD_TESTING)
    find_program(VERILATOR_EXECUTABLE verilator REQUIRED)
    find_package(GTest REQUIRED)

    set(TESTBENCH_DIR "${CMAKE_SOURCE_DIR}/testbench")
    set(TEST_BUILD_DIR "${CMAKE_BINARY_DIR}/testbenches")

    function(add_verilator_test test_name module source)
        set(mdir "${TEST_BUILD_DIR}/${test_name}")
        set(executable "${mdir}/Vdut")

        add_custom_command(
            OUTPUT "${executable}"
            COMMAND "${CMAKE_COMMAND}" -E make_directory "${mdir}"
            COMMAND "${VERILATOR_EXECUTABLE}"
                --cc --trace --Wall -Wno-fatal
                --exe "${TESTBENCH_DIR}/tests/${source}"
                "${CMAKE_SOURCE_DIR}/rtl/${module}.sv"
                --Mdir "${mdir}"
                --prefix Vdut
                --top-module "${module}"
                --build
                -o Vdut
                -CFLAGS "-std=c++17 -I$<JOIN:$<TARGET_PROPERTY:GTest::gtest,INTERFACE_INCLUDE_DIRECTORIES>, -I>"
                -LDFLAGS "$<TARGET_FILE:GTest::gtest_main>"
                -LDFLAGS "$<TARGET_FILE:GTest::gtest>"
                -LDFLAGS -pthread
            DEPENDS
                "${TESTBENCH_DIR}/tests/${source}"
                "${CMAKE_SOURCE_DIR}/testbench/tests/ankit_test_bench.hpp"
                "${CMAKE_SOURCE_DIR}/rtl/${module}.sv"
            VERBATIM
            COMMENT "Building Verilator test ${test_name}")

        add_custom_target("${test_name}" DEPENDS "${executable}")
        add_test(
            NAME "${test_name}"
            COMMAND "${executable}"
            WORKING_DIRECTORY "${TESTBENCH_DIR}")
    endfunction()

    add_verilator_test(cpu_test top ankit_verify.cpp)
    add_verilator_test(mux_test mux mux_tb.cpp)
endif()
