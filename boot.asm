bits 16                          ;specifies to which architecture we want to produce code. since real mode operates in 16 bits.. target is 16bits real mode

; we dont specify an offset with ORG derective. therefore we should set the segment to a vale that would make 0x7c00 physicall address by ( segment * 16 + offset ) formula. so we let segment to be 0x07C0, with 0000 offset, it calculated to 0x7C00 physicall addr.


;real mode
  mov     ax, 0x7C0             ;setting up data segment
  mov     ds, ax                ;init ds reg

  mov     ax, 0x7E0             ;setting up stack
  mov     ss, ax                ;init ss reg

  mov     sp, 0x2000            ;stack size

  ;;;mov     ah, 0x7h             ;just playing with BIOS services
  call    init_screen

  push    0x0000
  call    move_cursor
  add     sp, 2

  ;mov     dx, msg
  push    msg
  call    print_screen
  add     sp, 2

  ;call    print_numbers
  ;add     sp, 2
  cli                           ;tells not to accept any more interrupts
  hlt                           ;we halt processing here

init_screen:
  push    bp                    ;save previous stack frame's base address
  mov     bp, sp                ;initialize a new stack frame
  pusha

  mov      ax, 0x0007            ;al = 00 && ah = 07 because little endian.
                                ;ah is the argument to pass to BIOS api call, by passing 0x07, and with interrupt 
                                ;10, it is possible to access the BIOS service which initialize screen (with scroll)
                                ;al is number to scroll down, 0x00 is to clear screen

  mov      bh, 0x07              ;bh is for colors. first nibble 0 indicates black and 7 
                                ;indicated grey

  mov     cx, 0x0000            ;ch and cl registers specify row / col of upperleft
  mov     dx, 0x4f18            ;dh and dl registers specify row / col of bottom right dh = 18h(24 rows) dl = 4f(79 cols)
  int     0x10                  ;interrupt to call BIOS

  popa
  ;mov     sp, bp                ;well, this mov is bit useless, for example if one poped everything he pushed, we are 
                                ;going to end uo at this address(address which bp points to) anyway) // try without it if you have balls
                                ;programs do this just to make sure. what if some lunatic just did not pop everything he pushed
  pop     bp
  ret

move_cursor:
  push    bp
  mov     bp, sp
  pusha

  mov     ah, 0x02              ;this is the arg which is used by interrupt
  mov     bh, 0x00              ;page 0; yet BIOS allow off the screen pages. this has something to do with doube buffering
  mov     dx, [bp+4]            ;after initializing stack frame, new base pointer is pointing to new stack frames first, lets say, pushed value.
                                ;in this case, first pushed value is address of previous stack frame's base address, which is 16bits, therefore bp+2 (+ becuase stack growns toward low address)to skip it
                                ;another 2 is for 0x0000 we pushed
  int     0x10

  popa
  mov     sp, bp
  pop     bp 
  ret

print_screen:
  push    bp
  mov     bp, sp
  pusha

  mov     si, [bp+4]                ;here we add 4 to bp. first, 2 bytes for pushed address of bp, second 2 byte is for address of our message. it pished to stack before we call this function. 
  mov     bx, 0x0000            ;00 = page number = bh && 00 = foreground color = bl, useless in text mode.
  mov     ah, 0x0e              ;BIOS service 

.loop:
  mov     al, [si]              ;get the character at address pointed by si
  inc     si                    ;increment si to next
  cmp     al, 0                 ;or instruction do bitwise or on operand. for example, 41h = 'A' or'ed by 0 = 41h. in here we or character at al with 0. if result is 0, it sets Zero flag in flag register. which means we are at end of string
  ;or     al, 0 can be used instead of 
  jz      .restore
  int     0x10                  ;else we print value by calling BIOS
  jmp     .loop                 ;and then continue loop

.restore:
  popa
  mov     sp, bp
  pop     bp
  ret

print_numbers:
  push    bp
  mov     bp, sp
  pusha

  mov     cl, 0xa
  mov     bh, 0x00
  mov     bl, 0x00
  mov     ah, 0x0e

.loop:
  cmp     cl, 0x0
  jz      .restore
  mov     al, cl
  int     0x10
  dec     cx
  jmp     .loop
  
.restore:
  popa
  mov     sp, bp
  pop     bp
  ret

msg:    db  "Booting..", 0

;boot sector
times   510-($-$$) db 0         ;boot sector should be 512 bytes. so this bin file should conists of 512 butes. so we use some wild cards fill remaining after code with 0s.
dw      0xaa55                  ;my dude, this is the boot signature
