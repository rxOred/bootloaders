[ORG 0x7C00]
[BITS 16]

Start:
  jmp     Load

Load:
  xor     ax, ax
  mov     ds, ax
  mov     ss, ax
  mov     sp, 0x7000

  call    InitScreen

  mov     dx, 0x0000
  call    MoveMouse

  mov     si, msg
  call    Print
  
  mov     al, 1
  mov     cl, 2
 call    ReadDisk

  cli
  cld
  hlt

ReadDisk:
  pusha

  .reset:
    mov       ah, 0x0
    mov       dl, 0x0
    int       0x13
    jc        .reset

.read:
  xor     ax, ax
  mov     es, ax
  mov     bx, 0x1000
  
  mov     ah, 0x02
  mov     ch, 0
  mov     dh, 0
  mov     dl, 0
  int     0x13

  jc      .err

  ret
  
.err:
  mov     si, errmsg
  call    Print
  jmp     $

%include "Screen.asm"

msg       db  "booting...", 0xA, 0xD, 0x0
errmsg      db "error reading the disk", 0xD, 0xA, 0x0

times     510 - ($-$$) db 0
dw        0xAA55
