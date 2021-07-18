mov   ah, 0x0e

mov   al, the_x
int   0x10

mov   al, '1'
int   0x10

mov   al, [the_x]
int   0x10

mov   al, '2'
int   0x10

mov   bx, the_x
add   bx, 0x7c00
mov   al, [bx]
int   0x10

mov   al, '3'
int   0x10

mov   ax, 0x07c0
mov   ds, ax
mov   ah, 0x0e
mov   al, the_x
int   0x10   

mov   al, '4'
int   0x10

jmp   $

the_x db  "x"
times 510-($-$$) db 0
dw 0xaa55
