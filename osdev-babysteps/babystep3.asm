
  mov   cx, [temp]

temp db 0x99
times   510-($-$$) db 0
db      0x55
db      0xaa
