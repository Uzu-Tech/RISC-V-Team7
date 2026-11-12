#!/usr/bin/env python3
"""Portable command-line interface for the RISC-V-Team7 build."""

from __future__ import annotations

import argparse
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
