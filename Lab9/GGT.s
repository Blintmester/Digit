DEF LD  0x80                ; LED adatregiszter          (írható/olvasható)
DEF SW  0x81                ; DIP kapcsoló adatregiszter (csak olvasható)

code
mov r0, SW
mov r1, SW
and r0, #0b11110000
and r1, #0b00001111
swp r0
add r0,r1
mov LD, r0