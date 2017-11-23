DEF LD 0x80

start:
    mov r8, #1
    mov r7, #0
    mov r6, #0
    mov r5, #0
    
init:
    mov r8, #1

loop:
    add r7, #100

    jnc loop
    
shift_left:   
    mov LD, r8
    SL0 r8
    mov r4, r8
    xor r4, #128
    JZ shift_right
    jmp shift_left
    
shift_right:
    mov LD, r8
    SR0 r8
    mov r4, r8
    xor r4, #1
    JZ shift_left
    jmp shift_right
    

    
    
    
    