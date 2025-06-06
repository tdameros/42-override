# Walkthrough - Level 06

The program has SUID permissions from the user `level07`, which will allow us to obtain their flag.

# Disassembly

- Main executes a shell if auth returns false
- The auth function takes login and serial number as arguments and returns a boolean
- Login input must be at least 5 characters and greater than the ASCII value of space
- The auth function performs certain operations on the login and compares it with the serial number

# Exploit

Here we simply need to execute the transformation of the login performed by the auth function to find the corresponding serial number. We compile our own program that performs the same transformation:

```c
#include <stdio.h>

int main(void) {
    char s[] = "ffffffffff";
    int v5 = strnlen(s, 32);
    int v4 = (s[3] ^ 0x1337) + 6221293;
    
    for(int i = 0; i < v5; ++i) {
        if(s[i] <= 31)
            return 1;
        v4 += (v4 ^ (unsigned int)s[i]) % 0x539;
    }
    
    printf("%d\n", v4);
}
```

```bash
~$ gcc test.c
~$ ./a.out
6233273
```

The result is thus the serial number corresponding to the login `ffffffffff`. We just need to enter this combination of login and serial number in the executable and we get a shell.

```bash
(python -c 'print("ffffffffff")'; python -c 'print("6233273")'; echo "cat /home/users/level07/.pass") | ./level06
```