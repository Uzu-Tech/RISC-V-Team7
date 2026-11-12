# RISC-V-Team7

## Build

Install CMake, Python 3, Verilator, a RISC-V GNU toolchain
(`riscv64-unknown-elf-*`), and GoogleTest using your operating system's
package manager. CMake cannot install the simulator or cross-compiler
automatically, so the interface reports a clear error if one is missing.

The recommended interface is `build.py`. It works from macOS, Linux, and
Windows WSL because it uses Python to call CMake:

```sh
python3 build.py
```

The default action is `all`: compile the default program and run every test.
Other useful commands are:

```text
python3 build.py compile
python3 build.py test
python3 build.py test --test mux
python3 build.py test --test cpu
python3 build.py all --test mux
python3 build.py compile --program testbench/c/return_5.c
python3 build.py clean
```

Use `py build.py` instead of `python3 build.py` on Windows if that is how
Python is registered on your machine. Every action also accepts
`--build-dir path/to/build`.

The default program is `testbench/asm/program.S`. Use `--program` to compile
any `.c`, `.s`, or `.S` file. The lower-level CMake interface remains
available when needed:

```sh
cmake -S . -B build -DBUILD_PROGRAM=ON -DBUILD_TESTING=ON
cmake --build build --target program mux_test
ctest --test-dir build --output-on-failure -R mux_test
```

Generated program files are placed in `build/`, except for the disassembly
output, which is written to the repository root. Test waveform output
(`waveform.vcd`) is also written to the repository root. The RISC-V conversion
is implemented in the
cross-platform standard-library helper
`cmake/compile_riscv.py`. The older Bash wrapper remains available for direct
use on Unix-like systems with
`bash testbench/compile.sh testbench/asm/program.S`.