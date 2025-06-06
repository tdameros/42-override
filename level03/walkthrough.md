# Walkthrough - level03

The program contains SUID permissions for the user level04, which will allow us to obtain their flag.

## Disassembly

- `scanf` to retrieve a password (integer)
- `test` function which calls a `decrypt` function
- `decrypt` function that applies xor operations on a string, compares it with `Congratulations!`, and executes a shell

## Exploit

The goal is to trigger the shell inside the `decrypt` function. To do this, the string ```Q}|u\`sfg~sf{}|a3``` must become `Congratulations!` by applying xor on each character.

In the `test` function, there's a `switch` statement that subtracts two numbers and compares the result with various values. If the subtraction result is between 1 and 21 (inclusive), it is passed directly to the `decrypt` function; otherwise, a random number is used.

So we just need to find a value between 1 and 21 (x) such that `'Q' ^ x = 'C'`. That value is `18`, which must be passed to the `decrypt` function.

Now we just need to find the first argument to the `test` function. Given that the second argument is `322424845`, the subtraction must result in `18`.

```
322424845 - x = 18
x = 322424845 - 18
x = 322424827
```

```bash
(python -c  'print("322424827")'; echo "cat /home/users/level04/.pass") | ./level03
```