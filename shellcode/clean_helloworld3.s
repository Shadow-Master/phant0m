BITS 32             ; tell nasm this is 32-bit code

;db "Hello, world!", 0x0a, 0x0d  ; with newline and carriage return bytes
push byte 15;
push 0x64210a0d;
push 0x776f726c ;
push 0x6c6f2c20;
push 0x2e48656c;
push esp;

; ssize_t write(int fd, const void *buf, size_t count);
  pop ecx           ; pop the return address (string ptr) into ecx
  xor eax, eax      ; zero out full 32-bits of eax register
  mov al, 4         ; write syscall #4 to the low byte of eax
  xor ebx, ebx      ; zero out ebx
  inc ebx           ; increment ebx to 1, STDOUT file descriptor
  xor edx, edx
  mov dl, 15        ; length of the string
  int 0x80          ; do syscall: write(1, string, 14)

; void _exit(int status);
  mov al, 1        ; exit syscall #1, the top 3 bytes are still zeroed
  dec ebx          ; decrement ebx back down to 0 for status = 0   
  int 0x80         ; do syscall:  exit(0)



