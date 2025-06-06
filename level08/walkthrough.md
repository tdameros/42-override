# Walkthrough - Level 08

The program has SUID permissions from the user `level09`, which will allow us to obtain their flag.

# Disassembly

- Main opens a file in the backup directory to write its logs
- Main also opens the file given as an argument
- It then opens a final file where it attempts to write what it read from the argument file

# Exploit

The idea here is to give it `/home/users/level09/end` as an argument so it can read it. We want to exploit the fact that it only reads 89 characters of our argument to define the file in which it will write, so it writes to a file where it has permissions.

We note two things that make our path choice easier:
- First, `tmp///////////passwd` is interpreted the same way as `tmp/passwd`
- Additionally, when trying to go up with `../` from the root, there is no error, we simply stay at the root

We have two conditions:
- The path given as an argument must lead to `/home/users/level09/end`
- The path `./backup/` concatenated with the first 89 characters of our argument must lead to a file we can write to

To do this, we first create a `password` directory in `/tmp`:
```bash
~$ mkdir /tmp/password
```

We can then make the 89th character of our argument fall in the middle of `password`:
```bash
/level08 "../../../../tmp//////////////////////////////////////////////////////////////////////pass"
```

We then need to complete the path to have it going to `/home/users/level09/end`:
```bash
./level08 "../../../../tmp//////////////////////////////////////////////////////////////////////password/../../home/users/level09/.pass"
```

The password is now stored in `/tmp/pass`.