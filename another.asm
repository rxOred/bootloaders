[BITS 16]
[ORG 0x7C00]                      ;assume code loaded at address 0x7C00

Start:
  jmp     Load

Load:
  xor     ax, ax
  mov     ds, ax                  ;setting up data segment register = 0x0000
  mov     ss, ax                  ;setting up stack segment register = 0x0000
  mov     sp, 0x2000              ;setting stack pointer to offset of 0x0000:0x7000 => 0x7000

  call    ClearScreen

  mov     dh, 0
  mov     dl, 0
  call    MoveCursor

  mov     si, msg
  call    Print

  call    ReadFloppy

  cli
  cld
  hlt

ClearScreen:
  push    bp
  mov     bp, sp
  pusha

  mov     ah, 0x07                ;task
  mov     al, 0x00                ;clear screen
  mov     bh, 0x07                ;color, black and whatever represnt by 4
  mov     cx, 0x0000              ;row and col of upper right
  mov     dh, 0x18                ;rows 24
  mov     dl, 0x4f                ;cols 79
  int     0x10                    ;interrupt

  popa
  mov     sp, bp
  pop     bp
  ret

MoveCursor:
  push    bp
  mov     bp, sp
  pusha

  mov     ah, 0x02                ;task
  mov     bh, 0x00                ;page 0
  int     0x10

  popa
  mov     sp, bp
  pop     bp
  ret

Print:
  push    bp
  mov     bp, sp
  pusha

  mov     ah, 0x0E                ;task
  mov     bl, 0x00                ;background color

.loop:
  mov     al, [si]
  or      al, al
  jz      .end
  int     0x10                    ;interrupt
  inc     si
  jmp     .loop

.end:
  popa
  mov     sp, bp
  pop     bp
  ret

ReadFloppy:
  push    bp
  mov     bp, sp
  pusha
  ;we do not really need to save anything on stack because we simply jump to another code in this function

  .reset:
    mov     ah, 0x0
    mov     dl, 0
    int     0x13
    jc      .reset

.read:
  xor     ax, ax
  mov     es, ax
  mov     bx, 0x7000            ;initialize a buffer

  mov     ah, 0x02
  mov     al, 1                 ;sectors to read = 1
  mov     ch, 0                 ;cylinder        = 0
  mov     cl, 1                 ;sector          = 1
  mov     dh, 0                 ;head            = 0
  mov     dl, 0                 ;drive, hard disk == 0x80 floppy == 0x00
  int     0x13

  jc      .err                  ;if carry flag set, error occured
  cmp     al, 1
  jnz     .err

  call    calltest

  mov     si, msg
  call    Print
  
  popa
  mov     sp, bp
  pop     bp
  ret

  ;jmp     0x100:0x0             ;else we start executing new code at address 0x500 :)

.err:
  mov    si, errmsg
  call    Print
  jmp     $

msg     db  "metal 0-1 do you read me?. repeat do you read me?", 0xA, 0xD, 0x0
errmsg  db  "something is wrong i can feel it", 0xA, 0xD, 0x0
testmsg db  "hola", 0xA, 0xD, 0x0
times   510-($-$$) db 0
dw      0xAA55

calltest:
  mov     si, testmsg
  call    Print

times 512 db 0
