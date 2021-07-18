[BITS 16]
[ORG 0x0000]

  mov   ax, 0x50
  mov   ds, ax
  mov   ss, ax
  mov   sp, 0x200

  push  reply
  call  Print
  cli
  cld
  hlt

Print:
  push  bp
  mov   bp, sp
  pusha

  mov   ah, 0x0e

.loop:  
  mov   al, [si]
  or    al, al
  jz    .end
  int   0x10
  inc   si
  jmp   .loop

.end:
  popa
  mov   sp, bp
  pop   bp
  ret

reply   db "aye aye sir... stand by, we are loading the kernel", 0xA, 0xD, 0x0
