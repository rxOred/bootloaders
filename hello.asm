[ORG 0x7c00]
[BITS 16]

    xor     ax, ax                          ;init ax to 0
                                            ;here we init segment to 0000, because we use use ORG derective. this directive suggest which offset/address of memory the code should loaded. in this case, as our segment is 0000 and offset is set to 0x7c00, out code will be loaded, and sarts execution at 0x7c00 physical address. (segment * 16 + offset)

    mov     ds, ax                          ;set data segment register to 0                

    mov     ss, ax                          ;set stack segment register to 0
    mov     sp, 0x9c00                      ;2000 stack

    push    msg
    call    Print

    cld
    cli
    hlt

ClearScreen:


Print:
    push    bp
    mov     bp, sp
    pusha

    mov     si, [bp + 4]
    mov     ah, 0x0e
    mov     bh, 0x00
    ;mov     cl, 0
    
.loop:
    mov     al, [si]
    cmp     al, 0
    jz      .end
    int     0x10
    inc     si
    jmp     .loop

.end:
    popa
    mov     sp, bp
    pop     bp
    ret

msg     db  "hello world my badass bootloader!", 0xa, 0xd, 0x0
times   510-($-$$) db 0
dw      0xaa55
