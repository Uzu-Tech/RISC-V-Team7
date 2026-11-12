# RISC-V-Team7

## Build

`build.py` automatically installs missing dependencies on Debian/Ubuntu using
`apt-get` or on macOS using Homebrew. It may ask for administrator
authentication. Use `--no-install` to disable this behavior. Other systems
must provide CMake, Python 3, Verilator, a RISC-V GNU toolchain
(`riscv64-unknown-elf-*`), and GoogleTest themselves.

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
output and test waveform output (`waveform.vcd`), which are written to
`testbench/`. The RISC-V conversion is implemented in the
cross-platform standard-library helper
`cmake/compile_riscv.py`. The older Bash wrapper remains available for direct
use on Unix-like systems with
`bash testbench/compile.sh testbench/asm/program.S`.