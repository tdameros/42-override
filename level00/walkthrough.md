# Walkthrough - level00

The program has SUID permissions from the user `level01`, which will allow us to obtain their flag.

## Exploit

The goal is to enter the condition that executes the shell.

To do this, we must convert `0x149c` to decimal, which gives us `5276`. Then, simply execute the binary with `5276` as the argument.