# 42 - Override

The **Override** project is part of the 42 School's security curriculum and introduces students to the fundamentals of **binary exploitation**. Through a series of progressively harder challenges, you learn to analyze and manipulate binary executables using techniques such as **disassembly**, **buffer overflows**, **shellcode injection**, **return-to-libc` and **Global Offset Table (GOT) overwriting**.

## Objectives

- Understand how programs are represented at the binary level.
- Disassemble and analyze compiled code with tools like `objdump`, `gdb`, or `radare2`.
- Exploit vulnerabilities such as:
  - **Buffer overflows** to control the execution flow.
  - **Shellcode injection** to execute arbitrary code.
  - **GOT overwriting** to redirect function calls to custom payloads.
  - **Return-to-libc** to call libc functions with custom arguments.

## Prerequisites

- Proficiency in the **C programming language**.
- Understanding of memory management in low‑level programming.
- Basic knowledge of **x86/x86_64 assembly**.
- Familiarity with Linux command‑line tools and debugging utilities.

## Tools You Might Use

- `gdb` – The GNU Debugger for stepping through code and analyzing memory.
- `objdump` – For disassembling binaries.
- `radare2` – An advanced reverse‑engineering framework.
- `nm` – To list symbols from object files.
- `strace` and `ltrace` – To trace system calls and library calls.

## Project Format

You are provided with binary levels `level00`, `level01`, … up to `levelXX`.  
Each binary contains a vulnerability that must be exploited to retrieve the credentials for the next level.

Typical workflow for each level:

1. **Analyze** the binary with `gdb`, `objdump`, `radare2`, etc.
2. **Identify** the vulnerability.
3. **Craft** an exploit (via command‑line input, environment variables, or a crafted file).
4. **Execute** your exploit to retrieve the password for the next level.

## Documentation & Payloads

- Binary source code disassembled with Ghidra or Hex-Rays [Online decompiler](https://dogbolt.org/) in `levelXX/source`.
- A step‑by‑step explanation for every exercise is provided in  
  `levelXX/walkthrough.md` inside the directory of each level (replace `XX` with the level number).
- The exact exploit command you need to launch is stored in  
  `levelXX/resources/payload.sh`.  
  Run it after reviewing the walkthrough to reproduce the exploit quickly.
