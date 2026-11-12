#!/usr/bin/env python3
"""Portable command-line interface for the RISC-V-Team7 build."""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DEFAULT_BUILD_DIR = ROOT / "build"
TEST_TARGETS = {"cpu": "cpu_test", "mux": "mux_test"}


def run(command: list[str], cwd: Path = ROOT) -> None:
    print("$ " + " ".join(str(part) for part in command))
    subprocess.run(command, cwd=cwd, check=True)


def missing_dependencies(build_program: bool, build_testing: bool) -> list[str]:
    dependencies = ["cmake", "python3", "c++"]
    if build_program:
        dependencies.extend([
            "riscv64-unknown-elf-gcc",
            "riscv64-unknown-elf-as",
            "riscv64-unknown-elf-ld",
            "riscv64-unknown-elf-objcopy",
            "riscv64-unknown-elf-objdump",
        ])
    if build_testing:
        dependencies.extend(["verilator", "gtest"])

    def is_available(dependency: str) -> bool:
        if dependency != "gtest":
            return shutil.which(dependency) is not None
        if shutil.which("dpkg-query") is not None:
            return subprocess.run(
                ["dpkg-query", "-W", "-f=${Status}", "libgtest-dev"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            ).returncode == 0
        if shutil.which("brew") is not None:
            return subprocess.run(
                ["brew", "list", "--versions", "googletest"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            ).returncode == 0
        return False

    return [dependency for dependency in dependencies
            if not is_available(dependency)]


def install_dependencies(missing: list[str]) -> None:
    if not missing:
        return

    if shutil.which("apt-get") is not None:
        packages = {
            "cmake": "cmake",
            "python3": "python3",
            "c++": "build-essential",
            "verilator": "verilator",
            "gtest": "libgtest-dev",
            "riscv64-unknown-elf-gcc": "gcc-riscv64-unknown-elf",
            "riscv64-unknown-elf-as": "binutils-riscv64-unknown-elf",
            "riscv64-unknown-elf-ld": "binutils-riscv64-unknown-elf",
            "riscv64-unknown-elf-objcopy": "binutils-riscv64-unknown-elf",
            "riscv64-unknown-elf-objdump": "binutils-riscv64-unknown-elf",
        }
        command = ["apt-get", "install", "-y", "libgtest-dev"]
        command.extend(sorted({packages[dependency] for dependency in missing}))
        if os.geteuid() != 0:
            if shutil.which("sudo") is None:
                raise RuntimeError(
                    "Missing dependencies require root access, but sudo was not found."
                )
            command.insert(0, "sudo")
        run(["sudo", "apt-get", "update"] if os.geteuid() != 0
            else ["apt-get", "update"])
        run(command)
    elif shutil.which("brew") is not None:
        packages = {
            "cmake": "cmake",
            "python3": "python",
            "c++": None,
            "verilator": "verilator",
            "gtest": "googletest",
            "riscv64-unknown-elf-gcc": "riscv-gnu-toolchain",
            "riscv64-unknown-elf-as": "riscv-gnu-toolchain",
            "riscv64-unknown-elf-ld": "riscv-gnu-toolchain",
            "riscv64-unknown-elf-objcopy": "riscv-gnu-toolchain",
            "riscv64-unknown-elf-objdump": "riscv-gnu-toolchain",
        }
        brew_packages = sorted({
            packages[dependency] for dependency in missing
            if packages[dependency] is not None
        })
        if any(packages[dependency] is None for dependency in missing):
            raise RuntimeError(
                "A C++ compiler is missing. Install Xcode Command Line Tools with "
                "`xcode-select --install`."
            )
        run(["brew", "install", *brew_packages])
    else:
        raise RuntimeError(
            "Missing dependencies: " + ", ".join(missing) +
            ". Automatic installation supports apt-get and Homebrew only."
        )

    remaining = missing_dependencies(
        "riscv64-unknown-elf-gcc" in missing,
        "verilator" in missing or "gtest" in missing,
    )
    if remaining:
        raise RuntimeError(
            "Dependencies are still missing after installation: " +
            ", ".join(remaining)
        )


def cmake_configure(args: argparse.Namespace, build_dir: Path, build_program: bool) -> None:
    command = [
        "cmake", "-S", str(ROOT), "-B", str(build_dir),
        f"-DBUILD_PROGRAM={'ON' if build_program else 'OFF'}",
        f"-DBUILD_TESTING={'ON' if args.action in {'test', 'all'} else 'OFF'}",
    ]
    if args.program is not None:
        command.append(f"-DPROGRAM_SOURCE={args.program}")
    run(command)


def selected_tests(value: str) -> list[str]:
    if value == "all":
        return list(TEST_TARGETS.values())
    return [TEST_TARGETS[value]]


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Configure, compile, and test the RISC-V-Team7 project."
    )
    parser.add_argument(
        "action", choices=("compile", "test", "all", "clean"),
        nargs="?", default="all",
        help="operation to perform (default: all)",
    )
    parser.add_argument(
        "--program", type=Path,
        help="C or assembly program to compile instead of the default program",
    )
    parser.add_argument(
        "--test", choices=("all", "cpu", "mux"), default="all",
        help="testbench to build/run (default: all)",
    )
    parser.add_argument(
        "--build-dir", type=Path, default=DEFAULT_BUILD_DIR,
        help="build directory (default: build)",
    )
    parser.add_argument(
        "--no-install", action="store_true",
        help="do not install missing system dependencies automatically",
    )
    args = parser.parse_args()
    build_dir = args.build_dir.resolve()

    if args.program is not None:
        args.program = args.program.resolve()
        if not args.program.is_file():
            parser.error(f"program does not exist: {args.program}")

    if args.action == "clean":
        if build_dir.exists():
            shutil.rmtree(build_dir)
            print(f"Removed {build_dir}")
        return 0

    build_program = args.action in {"compile", "all"}
    build_testing = args.action in {"test", "all"}
    missing = missing_dependencies(build_program, build_testing)
    if missing:
        if args.no_install:
            raise RuntimeError(
                "Missing dependencies: " + ", ".join(missing) +
                ". Remove --no-install to install them automatically."
            )
        install_dependencies(missing)
    cmake_configure(args, build_dir, build_program)

    if build_program:
        run(["cmake", "--build", str(build_dir), "--target", "program"])

    if args.action in {"test", "all"}:
        targets = selected_tests(args.test)
        run(["cmake", "--build", str(build_dir), "--target", *targets])
        run(["ctest", "--test-dir", str(build_dir), "--output-on-failure",
             "-R", "|".join(targets)])

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.CalledProcessError as error:
        raise SystemExit(error.returncode) from error
    except RuntimeError as error:
        print(f"Error: {error}", file=sys.stderr)
        raise SystemExit(1) from error
