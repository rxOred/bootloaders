[BITS 16]

[ORG 0x7c00]

  mov   ax, 0
  mov   ds, ax

  mov   ss, ax
  mov   sp, 0x9c00                ;stack = 2000
  
  cld

  mov   ax, 0xb800                ;vram
  mov   es, ax
  
  mov   si, msg
  call  print_string

  mov   ax, 0xb800
  mov   gs, ax
  mov   bx, 0x0000
  mov   ax, [gs:bx]

  mov   word[reg16], ax
  call  printreg16

.hang:
  jmp   .hang

print_string:
  lodsb
  or    al, 0
  jne    .printchar
  add   byte[ypos], 1
  mov   byte[xpos], 0

.printchar:
  mov   ah, 0x07                  ;colors
  mov   cx, ax                    ;saving vga address
  movzx   ax, byte[ypos]            ;mov value at the offset of ypos to ax/ initially 0
  mov   dx, 160
  mul   dx                        ;multiply ax by dx, ax contains ypos's value
  
  movzx   bx, byte[xpos]
  shl   bx, 1

  mov   di, 0
  add   di, ax
  add   di, bx

  mov   ax, cx
  stosw
  add   byte[xpos], 1
  
  ret

printreg16:
  mov   di, outstr16
  mov   ax, [reg16]
  mov   si, hexstr16
  mov   cx, 4

.hexloop:
  rol   ax, 4
  mov   bx, ax
  mov   bx, 0x0f
  mov   bl, [si+bx]
  mov   [di], bl
  inc   di
  dec   cx
  jnz   .hexloop

  mov   si, outstr16
  call  print_string

  ret

xpos  db  0
ypos  db  0
hexstr16  db  '0123456789ABCDEF'
outstr16  db  '0000', 0
reg16 dw  0
msg   db  "hello motherfucker", 0

times  510-($-$$) db 0
dw  0xaa55
