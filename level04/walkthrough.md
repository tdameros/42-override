# Walkthrough - level04

The program has SUID permissions from the user `level05`, which will allow us to obtain their flag.

## Disassembly

- Presence of a fork that executes a `gets` to store it in variable s
- No possibility of executing shellcode as the fork doesn't give us control of stdin
- Parent process waits for child and kills it in case of problems during execution

## Exploit

The idea here is to rewrite the EIP of the main function in the child to execute the `system` function from libc. To do this, we must follow the following scheme:

![Read to libc](resources/read_to_libc.png)

We found the addresses of the functions `system` and `exit` in the libc:

```bash
(gdb) b main
(gdb) run
(gdb) p system
$1 = {<text variable, no debug info>} 0xf7e6aed0 <system>
(gdb) p exit
$2 = {<text variable, no debug info>} 0xf7e5eb70 <exit>
```

We also found the offset value of `156` using the buffer overflow pattern generator.

To store the command in environment variables and retrieve its address, we must not forget to unset the `COLUMNS` and `LINES` variables in gdb. We can then retrieve the addresses:

```bash
(gdb) unset env LINES
(gdb) unset env COLUMNS
(gdb) b main
(gdb) run
(gdb) x/500s
```

We thus obtain the address of our environment variable (carefully noting that the variable name is also stored at this location, we must properly retrieve the address of the environment variable's value).

Source of ret2libc explanations: https://www.ired.team/offensive-security/code-injection-process-injection/binary-exploitation/return-to-libc-ret2libc#finding-system
