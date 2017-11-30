DEF DIG0 0x90                ; Kijelzo DIG0 adatregiszter          (�rhat�/olvashat�)
DEF DIG1 0x91                ; Kijelzo DIG1 adatregiszter          (�rhat�/olvashat�)
DEF DIG2 0x92                ; Kijelzo DIG2 adatregiszter          (�rhat�/olvashat�)
DEF DIG3 0x93                ; Kijelzo DIG3 adatregiszter          (�rhat�/olvashat�)
DEF COL0 0x94                ; Kijelzo COL0 adatregiszter          (�rhat�/olvashat�)
DEF COL1 0x95                ; Kijelzo COL1 adatregiszter          (�rhat�/olvashat�)
DEF COL2 0x96                ; Kijelzo COL2 adatregiszter          (�rhat�/olvashat�)
DEF COL3 0x97                ; Kijelzo COL3 adatregiszter          (�rhat�/olvashat�)
DEF COL4 0x98                ; Kijelzo COL4 adatregiszter          (�rhat�/olvashat�)
DEF ADO  0xA0                ; GPIO A kimeneti adatregiszter       (�rhat�/olvashat�)
DEF ADI  0xA1                ; GPIO A adat az I/O l�bakon          (�rhat�/olvashat�)
DEF ADR  0xA2                ; GPIO A ir�nyregister (0: be, 1: ki) (�rhat�/olvashat�)


DATA
    
  SEG_TAB:
    DB  0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07 
    DB  0x7f, 0x6f, 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71

CODE

    mov     r0, #0x01       ; GPIO A port konfigur�l�sa:
    mov     ADO, r0         ; - A[0]: kimenet �s 1 -> TMP121 CSn
    mov     r0, #0x03       ; - A[1]: kimenet �s 0 -> TMP121 SCK
    mov     ADR, r0         ; - A[2]: bemenet �s 0 -> TMP121 MISO
    
    mov     r5, #0          ; 24 bites szoftveres id�z�t�s
    mov     r6, #0          ; A TM121 min. 640 ms peri�dust k�v�n
    mov     r7, #0
    
    
wait:
    add     r7, #16         ; Az id�z�t�si id�: 4* 187,5 ns * 2^24 /16 =  
    adc     r6, #0          ; = 0,786432 s azaz > 640ms, ami a minim�lis 
    adc     r5, #0          ; periodikus konverzi�s ideje a TMP121-nek
    jnc     wait    
     
    jsr     tmp121_rd       ; H�m�rs�klet szenzor beolvas�sa {r9:r8}-ba
                            ; 16 bit, az als� 3 bit �rv�nytelen 0 Z Z
    asr     r9              ; 3x l�tet�nk aritmetikalig, 16 biten jobbra
    rrc     r8              ; El�jeles oszt�s 8-cal
    asr     r9              ; Eredm�ny: 4 digites �rt�k: 
    rrc     r8              ; 3 eg�szr�sz digit �s 1 t�rtr�sz digit 
    asr     r9
    rrc     r8
    
    mov     r0, r9          ; Fels� b�jt fels� digit kijelz�se
    and     r0, #0xf0       ; Els� digit maszkol�sa
    swp     r0              ; Hexa �rt�k als� 4 biten
    mov     r1, #SEG_TAB    ; Szegmens t�bla b�zisc�m
    add     r1, r0          ; Hexa digit szegmensk�p indexe
    mov     r0, (r1)        ; Szegmensk�d beolvas�sa indirekt c�mz�ssel
    mov     DIG3, r0        ; �rt�k ki�r�sa DIG3-ra

    mov     r0, r9          ; Fels� b�jt als� digit kijelz�se
    and     r0, #0x0f       ; M�sodik digit maszkol�sa
    mov     r1, #SEG_TAB    ; Szegmens t�bla b�zisc�m
    add     r1, r0          ; Hexa digit szegmensk�p indexe
    mov     r0, (r1)        ; Szegmensk�d beolvas�sa indirekt c�mz�ssel
    mov     DIG2, r0        ; �rt�k ki�r�sa DIG2-ra

    mov     r0, r8          ; Als� b�jt fels� digit kijelz�se
    and     r0, #0xf0       ; Els� digit maszkol�sa
    swp     r0              ; Hexa �rt�k als� 4 biten
    mov     r1, #SEG_TAB    ; Szegmens t�bla b�zisc�m
    add     r1, r0          ; Hexa digit szegmensk�p indexe
    mov     r0, (r1)        ; Szegmensk�d beolvas�sa indirekt c�mz�ssel
    or      r0, #0x80       ; T�rtr�sz jelz� hexadecim�lis pont
    mov     DIG1, r0        ; �rt�k ki�r�sa DIG1-ra

    mov     r0, r8          ; Als� b�jt als� digit kijelz�se
    and     r0, #0x0f       ; M�sodik digit maszkol�sa
    mov     r1, #SEG_TAB    ; Szegmens t�bla b�zisc�m
    add     r1, r0          ; Hexa digit szegmensk�p indexe
    mov     r0, (r1)        ; Szegmensk�d beolvas�sa indirekt c�mz�ssel
    mov     DIG0, r0        ; �rt�k ki�r�sa DIG0-ra
    
    jmp     wait


;*******************************************************************************
;* A 16 bites h�m�rs�klet �rt�k beolvas�sa a TMP121 h�m�r�r�l.                 *
;* Visszat�r�si �rt�k:                                                         *
;*   r8: A 16 bites h�m�rs�klet �rt�k als� 8 bitje (LSB).                      *
;*   r9: A 16 bites h�m�rs�klet �rt�k fels� 8 bitje (MSB).                     *
;*******************************************************************************
tmp121_rd:
    mov     r0, #0x00       ; A CSn vonal alacsony szintre �ll�t�sa.
    mov     ADO, r0
    mov     r1, #16         ; 16 bitet olvasunk be a h�m�r�r�l. 
tmp121_loop:
    mov     r0, #0x02       ; Az SCK �rajel magas szintre �ll�t�sa.
    mov     ADO, r0
    mov     r0, ADI         ; Beolvassuk a GPIO l�bak �llapot�t.
    and     r0, #0x04       ; Csak a MOSI vonal �rt�ke �rdekes.
    add     r0, #0xff       ; A MOSI �rt�k�t a C flagba �rjuk �s ezt
    rlc     r8              ; bel�ptetj�k az r9:r8 regiszterp�rba.
    rlc     r9
    mov     r0, #0x00       ; Az SCK �rajel alacsony szintre �ll�t�sa, a lefut�
    mov     ADO, r0         ; �lre l�pteti ki a TMP121 a k�vetkez� adatbitet.
    sub     r1, #1          ; Cs�kkentj�k a beolvasand� bitek sz�m�t.
    jnz     tmp121_loop     ; Ugr�s, ha m�g van beolvasand� bit.
    mov     r0, #0x01       ; A CSn vonal magas szintre �ll�t�sa.
    mov     ADO, r0
    rts                     ; Visszat�r�s a h�v�hoz.
    