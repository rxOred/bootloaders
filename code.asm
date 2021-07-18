[BITS 16]
[ORG 0x7C00]

Start:
  jmp     Load

Load:
  xor     ax, ax
  mov     ds, ax                  ;data segment reg
  mov     ss, ax                  ;stack segment reg
  mov     sp, 0x9C00              ;stack

  call    ClearScreen

  mov      dh, 0
  mov      dl, 0
  call    MoveCursor

  ;push    msg
  ;call    Print

  ;now its time to load second part of our bootloader.

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
  mov     si, [bp + 4]
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
  ;push    bp
  ;mov     bp, sp
  ;pusha
  ;we do not really need to save anything on stack because we simply jump to another code in this function

  .reset:
    mov     ah, 0x0
    mov     dl, 0
    int     0x13
    jc      .reset


    ;es:bx represents buffer we want to read disk data
.read:
  xor     ax, ax
  mov     es, ax
  mov     bx, 0x100

  mov     ah, 0x02
  mov     al, 1                 ;number of sectors to read
  mov     ch, 0                 ;cylinder 
  mov     cl, 2                 ;sector
  mov     dh, 0                 ;head
  mov     dl, 0                 ;drive, hard disk == 0x80 floppy == 0x00

  int     0x13                   ;read sector interrupt

  jc      .err                  ;if carry flag set, error occured
  cmp     al, 5
  jne     .err                  ;if al != 5, error occured
  ;popa
  ;mov     sp, bp
  ;pop     bp
  ;ret

  ;jmp     0x100:0x0             ;else we start executing new code at address 0x500 :)

.err:
  push    errmsg
  call    Print
  jmp     $

msg     db  "metal 0-1 do you read me?. repeat do you read me?", 0xA, 0xD, 0x0
errmsg  db  "something is wrong i can feel it", 0xA, 0xD, 0x0
testmsg db  "hola", 0xA, 0xD, 0x0
times   510-($-$$) db 0
dw      0xAA55

; from this point, first sector is finished and second sector begins...

times 512 db 0
;calltest:
;  push    testmsg
;  call    Print
