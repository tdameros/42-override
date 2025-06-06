# Walkthrough - level08

The program has SUID permissions from the user `level09`, which will allow us to obtain their flag.

# Dissassembly

- Le main ouvre un fichier dans le dossier backup dans lequel il va ecrire ses logs
- Le main ouvre egalement le fichier qu'on lui donne en argument
- Il va ensuite ouvrir un dernier fichier dans lequel il va tenter d'ecrire ce qu'il a lu dans le fichier donne en argument

# Exploit

L'idee ici est de lui donner en argument le fichier `/home/users/level09/end` pour qu'il puisse le lire. on souhaite ensuite exploiter le fait qu'il ne lise que 89 caracteres de notre argument pour definir le fichier dans lequel il va ecrire pour qu'il ecrive dans un fichier dans lequel il a les droits.

On note 2 choses qui nous simplifient la vie pour le chemin qu'on va choisir.
- D'abord, `tmp///////////passwd` est interprete de la meme maniere que `tmp/passwd`
- De plus, lorsqu'on cherche a remonter avec `../` depuis la racine, il n'y a pas d'erreur, on reste simplement a la racine.

Nous avons donc 2 conditions:
- Le chemin donne en argument doit mener au fichier `/home/users/level09/end`
- Le chemin `./backup/` auquel on concatene les 89 premiers caracteres de notre argument doit mener a un fichier dans lequel on peut ecrire.

Pour cela on va commencer par creer un dossier `password` dans `/tmp` :
```bash
~$ mkdir /tmp/password
```

On peut alors faire en sorte que le 89eme caractere de notre argument tombe au milieu de `password` :
```bash
/level08 "../../../../tmp//////////////////////////////////////////////////////////////////////pass"
```

Il nous reste alors a completer ce chemin pour qu'il pointe sur `/home/users/level09/end`:
```bash
./level08 "../../../../tmp//////////////////////////////////////////////////////////////////////password/../../home/users/level09/.pass"
```

Le mot de passe se trouve alors dans le fichier `/tmp/pass`.