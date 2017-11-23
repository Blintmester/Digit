DEF sw  0x81
DEF TM  0x82
DEF TC  0x83
DEF TS  0x83
DEF CDO 0xA4
DEF CDR 0xA6

;* r11:r10 ganze Timingsperiode     0 - 4095
;* r13:r12 aktuelle Pulsbreite      256 - 512
;* r15:r14 Arbeitsreg
jmp reset
jmp start

reset:
    mov r10, #0
    mov r11, #0
    mov r12, #127
    mov r13, #1     ;steht im Mittel Zustand
    
    mov r0, #0x00
    mov CDO, r0
    mov r0, #0x02
    mov CDR, r0     ;enable
    
asd:
    mov r0, #63     ;64-1
    mov TM, r0
    mov r0, #0x83
    mov TC, r0
    mov r0, TS
    sti             ;Brechnung - Freigabe

start:
    mov r13, #1
    mov r12, sw     ;get SW
    mov r14, r10
    mov r15, r11
    
komparator:
    sub r14, r12
    sbc r15, r13
    
    mov r14, #0
    rlc r14
    sl0 r14         ;nach dem Sub prüfen wir C-Flag
    mov CDO, r14    ;set enable

timer:
    add r10, #1
    adc r11, #0
    tst r11, #0x10  ;falls Zähler 4096, Z-Flag = 1
    jz irq_end
    
    mov r10, #0
    mov r11, #0     ;löschen die Zähler
    jmp start
    
irq_end:
    mov r14, TS     ;löschen die Statusreg
    rti
    