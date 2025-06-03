On ne peut pas utiliser de shellcode car le fork ne nous donne pas la main sur la stdin.

Donc on utilise un return-to-libc

https://www.ired.team/offensive-security/code-injection-process-injection/binary-exploitation/return-to-libc-ret2libc#finding-system