cmake_minimum_required(VERSION 3.20)

project(risc_v_team7 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)

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
    set(PROGRAM_HEX "${CMAKE_SOURCE_DIR}/rtl/program.hex")
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
    file(GLOB RTL_SOURCES CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/rtl/*.sv")
    file(GLOB TEST_SOURCES CONFIGURE_DEPENDS "${TESTBENCH_DIR}/tests/*_tb.cpp")

    function(add_verilator_test source)
        get_filename_component(source_name "${source}" NAME_WE)
        string(REGEX REPLACE "_tb$" "" module "${source_name}")
        set(test_name "${module}_test")
        set(mdir "${TEST_BUILD_DIR}/${test_name}")
        set(executable "${mdir}/Vdut")

        add_custom_command(
            OUTPUT "${executable}"
            COMMAND "${CMAKE_COMMAND}" -E make_directory "${mdir}"
            COMMAND "${VERILATOR_EXECUTABLE}"
                --cc --trace --Wall -Wno-fatal -Wno-EOFNEWLINE
                --exe "${source}"
                ${RTL_SOURCES}
                --Mdir "${mdir}"
                --prefix Vdut
                --top-module "${module}"
                --build
                -o Vdut
                -CFLAGS "-std=c++20 -I$<JOIN:$<TARGET_PROPERTY:GTest::gtest,INTERFACE_INCLUDE_DIRECTORIES>, -I>"
                -LDFLAGS "$<TARGET_FILE:GTest::gtest_main>"
                -LDFLAGS "$<TARGET_FILE:GTest::gtest>"
                -LDFLAGS -pthread
            DEPENDS
                "${source}"
                "${CMAKE_SOURCE_DIR}/testbench/tests/test_bench.hpp"
                ${RTL_SOURCES}
            VERBATIM
            COMMENT "Building Verilator test ${test_name}")

        add_custom_target("${test_name}" DEPENDS "${executable}")
        set(TEST_TARGETS "${TEST_TARGETS};${test_name}" PARENT_SCOPE)
        add_test(
            NAME "${test_name}"
            COMMAND "${executable}"
            WORKING_DIRECTORY "${TESTBENCH_DIR}")
    endfunction()

    foreach(test_source IN LISTS TEST_SOURCES)
        add_verilator_test("${test_source}")
    endforeach()
    add_custom_target(tests DEPENDS ${TEST_TARGETS})
endif()
