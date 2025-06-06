# Walkthrough - level03

The program contains SUID permissions for the user level04, which will allow us to obtain their flag.

## Disassembly

- `scanf` pour récupérer un mot de passe (nombre entier)
- Fonction `test` qui appel une fonction `decrypt`
- Fonction `decrypt` qui applique des opérations xor sur une chaine de caracteres, la compare avec `Congratulations!` et execute un shell

## Exploit

L'objectif est de faire en sorte d'executer le shell qui se trouve dans la fonction `decrypt`. Pour cela, il faut que la chaine de caractères ```Q}|u\`sfg~sf{}|a3``` devienne `Congratulations!` en appliquant un xor sur chacun des caractères.

Si on regarde la fonction `test`, on voit une instruction `switch` qui soustrait les deux nombres récupérés et les compare avec différentes valeurs. Si la soustraction est comprise entre 1 et 21 (inclus), alors le résultat de la soustraction est directement passsé en argument de la fonction `decrypt`, sinon un nombre aléatoire est passé en argument.

Il nous suffit donc de trouver une valeur comprise entre 1 et 21 (x) qui `'Q' ^ x = 'C'`. Il s'agit alors de `18` que nous devons passer en parametre à la fonction `decrypt`.

Maintenant il nous reste plus qu'à trouver le premier argument de la fonction `test`. Étant donné que le deuxième argument est `322424845`, il faut que la soustraction des deux donne le résultat de `18`.

```
322424845 - x = 18
x = 322424845 - 18
x = 322424827
```

```bash
(python -c  'print("322424827")'; echo "cat /home/users/level04/.pass") | ./level03
```