DEF LD  0x80                ; LED adatregiszter          (�rhat�/olvashat�)
;DEF SW  0x81                ; DIP kapcsol� adatregiszter (csak olvashat�)

code
    mov r0, #0
    mov r1, #0x01
    mov r3, #0
    mov r4, #0


loop:
wait:
    add r0, #12 ;1 mp alatt fut le
    adc r3, #0
    adc r4, #0
    jnc wait
    
    ROL r1
    mov LD, r1
    
    jmp loop
