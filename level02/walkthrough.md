# Walkthrough - level02

The program has SUID permissions from the user `level03`, which will allow us to obtain their flag.

# Dissassembly

- Le main stocke le contenu de `/home/users/level03/.pass` dans la variable `ptr`
- Le username et le mot de passe sont lus via des `fgets` de `100` octets
- Lorsqu'on rentre un mauvais mot de passe, le username est affiche via un printf non securise

# Exploit

The arguments of variadic functions (such as `printf`) are passed through the stack and not through registers. This allows us to dump our stack. Note that we are working on a 64bits architecture so we need to use the format `%p` to display everything correctly.

```bash
(python -c 'print("%p" * 30)'; python -c 'print("A" * 2)') | ./level02
```

Il faut maintenant trouver la variable `ptr` dans ce que nous avons affiche de la stack. Les 2 `A` nous permettent de trouver le debut de s2 ou est stocke le mot de passe. On sait ensuite qu'il faut chercher `96 + 8 = 104` octets plus loin pour tomber sur le debut de ptr ou est stocke le mot de passe. Sachant aue le format `%p` dump la stack par 8 octets, il faut donc chercher `104 / 8 = 13` apres l'affichage des `A`.

On obtient le resultat suivant :

```bash
0x756e5052343768480x45414a35617339510x377a7143574e67580x354a35686e4758730x48336750664b394d
```

Il faut alors convertir ce mot de passe en char sans oublier que `%p` a inverse les groupes de 8 octets car le systeme est en little endian puis interpreter les vaeurs en ASCII pour obtenir le mot de passe.