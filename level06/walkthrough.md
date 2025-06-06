# Walkthrough - level06

The program has SUID permissions from the user `level07`, which will allow us to obtain their flag.

# Dissassembly

- Le main execute un shell si auth retourne false
- La fonction auth qui prend en argument le login et le numero de serie et retourne un booleen
- Le login entre doit faire au minimum 5 caracteres et doivent etre plus grand que la valeur de l'espace en ASCII
- La fonction auth execute un certain nombre d'operation sur le login et le compare ua numero de serie

# Exploit

Ici il faut simplement executer la transformation du login faite par la fonction auth pour trouver le numero de serie correspondant. On compile donc notre propre programme qui effectue la meme transformation :
```c
#include <stdio.h>

int	main(void) {
	char s[] = "ffffffffff";
	int v5 = strnlen(s, 32);
	int v4 = (s[3] ^ 0x1337) + 6221293;
	    for ( int i = 0; i < v5; ++i )
	    {
	      if ( s[i] <= 31 )
		return 1;
	      v4 += (v4 ^ (unsigned int)s[i]) % 0x539;
	    }
	    printf("%d\n", v4);
}
```

Le resultat est donc le numero de serie correspondant au login `ffffffffff`. Il nous suffit alors de rentrer cette combinaison de login et numero de serie dans l'executable et on obtient un shell.