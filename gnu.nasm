;reset floppy disk controller, args = ah=0, interrupt = int 0x13
    xor     ax,     ax
    int     0x13
    inc     si
    mov     cl,     si

;check if number of sectors is 0, if yes, exit
    test    cl,     cl
    jnz     .continue

    mov     si,     nosec
    call    print
    hlt

.continue:
    

nosec   db "no sectors available", 0xa, 0x0
