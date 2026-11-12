#!/usr/bin/env python3
"""Compile a RISC-V C or assembly program into binary and hex output."""

from __future__ import annotations

import argparse
import shutil
import subprocess
from pathlib import Path


def tool_path(name: str) -> str:
    path = shutil.which(name)
    if path is None:
        raise RuntimeError(f"Required tool was not found on PATH: {name}")
    return path


def run(command: list[str]) -> None:
    subprocess.run(command, check=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--hex-output", type=Path, required=True)
    parser.add_argument("--dis-output", type=Path, required=True)
    args = parser.parse_args()

    source = args.source.resolve()
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    program_name = source.stem
    assembly_file = source

    gcc = tool_path("riscv64-unknown-elf-gcc")
    assembler = tool_path("riscv64-unknown-elf-as")
    linker = tool_path("riscv64-unknown-elf-ld")
    objcopy = tool_path("riscv64-unknown-elf-objcopy")
    objdump = tool_path("riscv64-unknown-elf-objdump")

    if source.suffix == ".c":
        assembly_file = output_dir / f"{program_name}.s"
        run([
            gcc, "-S", "-g", "-O0", "-fno-builtin", "-static",
            "-march=rv32im", "-mabi=ilp32", "-Wno-unused-result",
            "-o", str(assembly_file), str(source),
        ])
    elif source.suffix not in {".S", ".s"}:
        raise ValueError(f"Unsupported RISC-V source extension: {source.suffix}")

    object_file = output_dir / f"{program_name}.o"
    relocatable_file = output_dir / f"{program_name}.reloc"
    binary_file = output_dir / f"{program_name}.bin"

    run([
        assembler, "-R", "-march=rv32im", "-mabi=ilp32",
        "-o", str(object_file), str(assembly_file),
    ])
    run([
        linker, "-melf32lriscv", "-e", "0x00000000",
        "-Ttext", "0x00000000", "-o", str(relocatable_file),
        str(object_file),
    ])
    run([
        objcopy, "-O", "binary", "-j", ".text",
        str(relocatable_file), str(binary_file),
    ])

    with args.dis_output.open("w", encoding="utf-8") as disassembly:
        subprocess.run(
            [objdump, "-f", "-d", "--source", "-m", "riscv",
             str(relocatable_file)],
            check=True,
            stdout=disassembly,
        )

    hex_data = binary_file.read_bytes().hex(" ")
    args.hex_output.write_text(f"{hex_data}\n", encoding="ascii")


if __name__ == "__main__":
    main()
