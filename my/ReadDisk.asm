;--------------------------------------------------------------------------------------------
;read sectors from floppy disk drive  al = number of sectors to read, cl = starting sector
;--------------------------------------------------------------------------------------------

ReadDisk:
  pusha
  push      ax

  .reset:
    mov       ah, 0x0
    mov       dl, 0x0
    int       0x13
    jc        .reset

.read:
  mov       ah, 0x02
  mov       ch, 0
  mov       dh, 0
  mov       dl, 0
  int       0x13

  ret
