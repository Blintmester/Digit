DEF UC  0x88                ; USRT kontroll regiszter     (csak �rhat�)
DEF US  0x89                ; USRT FIFO st�tusz regiszter (csak olvashat�)
DEF UIE 0x8A                ; USRT megszak�t�s eng. reg.  (�rhat�/olvashat�)
DEF UD  0x8B                ; USRT adatregiszter          (�rhat�/olvashat�)

DATA

   NEPTUN:
    DB "LOOONG\r\n", 0
CODE
    mov r1, #0x0D
    mov UC, r1
    mov r0, #NEPTUN
    
send_loop:
    mov r1, (r0)
    cmp r1, #0
    jz done

;wait:
 ;   mov r2, US
  ;  tst r2, #0x02
   ; jz wait
    
    mov UD, r1
    add r0, #1
    jmp send_loop
done:
 jmp done   