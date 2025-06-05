Le programme ouvre un fichier X et écrit copie ce fichier dans ./backups/X. Sauf que nous avons pas les permissions d'ecrire dans le dossier ./backups.
Pour cela, on fake un path de backups en regardant comment fonctionne la concatenation de ./backups et de X.

Le strncat copie au max 99 - strlen(dest) soit 89 caracteres.

Il faut que les 89 caracteres tombe au milieu d'un dossier dans /tmp/ pour que ca cree un nouveau fichier avec le flag.