%macro print_screen 1
  mov     si, word %1
loop:
  lodsb
  or      al, al
  jz      finished
  mov     ah, 0x0e
  mov     bh, 0
  int     0x10
  jmp     loop
finished:
  %endmacro

[BITS 16]
[ORG 0x7c00]

  xor     ax, ax
  mov     dx, ax
  cld

  print_screen msg

hang:
  jmp     hang

msg       db "hello world", 0
times     510-($-$$)  db  0
db        0x55
db        0xaa
