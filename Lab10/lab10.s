code

mov r0, #ptr    ; a #-el az elso adatb�jt c�m�t teszem bele adresse von ptr wird gespeichert
mov r1, #10     ; Anzahl von Elementen

MAXMIN:
    mov r2, r0  ; r2: MAX-Adresse //az r2-ben van az aktu�lis adatunk c�me
    mov r3, (r0); r3: Max_Wert    //() az r0 tartalma
    mov r4, r0  ; r4: MIN-Adresse
    mov r5, (r0); r5: MIN-Wert
    sub r1, #1
    
loop:
    add r0, #1
    mov r6, (r0)
    cmp r3, r6  ;a komper utas�t�s kivonja egym�sb�l a k�t sz�mot, flag jelzi az eredm�nyt, ha negat�v 
    jnc nomax
    mov r3, r6
    mov r2, r0
      
  
nomax:
    cmp r6, r5
    jnc nomin
    mov r5, r6
    mov r4, r0
nomin:
    sub r1, #1
    jnz loop
ready:
    jmp ready


data
ptr:            ;az ut�na k�vetkezo utas�t�s(ok) c�m�t tartalmazza
db 0x21, 0x25, 0x11, 0xF2, 0xEB
db 0x12, 0x34, 0x77, 0xAF, 0xFF