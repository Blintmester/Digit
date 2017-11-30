DEF DIG0 0x90                ; Kijelzo DIG0 adatregiszter          (írható/olvasható)
DEF DIG1 0x91                ; Kijelzo DIG1 adatregiszter          (írható/olvasható)
DEF DIG2 0x92                ; Kijelzo DIG2 adatregiszter          (írható/olvasható)
DEF DIG3 0x93                ; Kijelzo DIG3 adatregiszter          (írható/olvasható)
DEF COL0 0x94                ; Kijelzo COL0 adatregiszter          (írható/olvasható)
DEF COL1 0x95                ; Kijelzo COL1 adatregiszter          (írható/olvasható)
DEF COL2 0x96                ; Kijelzo COL2 adatregiszter          (írható/olvasható)
DEF COL3 0x97                ; Kijelzo COL3 adatregiszter          (írható/olvasható)
DEF COL4 0x98                ; Kijelzo COL4 adatregiszter          (írható/olvasható)
DEF ADO  0xA0                ; GPIO A kimeneti adatregiszter       (írható/olvasható)
DEF ADI  0xA1                ; GPIO A adat az I/O lábakon          (írható/olvasható)
DEF ADR  0xA2                ; GPIO A irányregister (0: be, 1: ki) (írható/olvasható)


DATA
    
  SEG_TAB:
    DB  0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07 
    DB  0x7f, 0x6f, 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71

CODE

    mov     r0, #0x01       ; GPIO A port konfigurálása:
    mov     ADO, r0         ; - A[0]: kimenet és 1 -> TMP121 CSn
    mov     r0, #0x03       ; - A[1]: kimenet és 0 -> TMP121 SCK
    mov     ADR, r0         ; - A[2]: bemenet és 0 -> TMP121 MISO
    
    mov     r5, #0          ; 24 bites szoftveres idõzítés
    mov     r6, #0          ; A TM121 min. 640 ms periódust kíván
    mov     r7, #0
    
    
wait:
    add     r7, #16         ; Az idõzítési idõ: 4* 187,5 ns * 2^24 /16 =  
    adc     r6, #0          ; = 0,786432 s azaz > 640ms, ami a minimális 
    adc     r5, #0          ; periodikus konverziós ideje a TMP121-nek
    jnc     wait    
     
    jsr     tmp121_rd       ; Hõmérséklet szenzor beolvasása {r9:r8}-ba
                            ; 16 bit, az alsó 3 bit érvénytelen 0 Z Z
    asr     r9              ; 3x létetünk aritmetikalig, 16 biten jobbra
    rrc     r8              ; Elõjeles osztás 8-cal
    asr     r9              ; Eredmény: 4 digites érték: 
    rrc     r8              ; 3 egészrész digit és 1 törtrész digit 
    asr     r9
    rrc     r8
    
    mov     r0, r9          ; Felsõ bájt felsõ digit kijelzése
    and     r0, #0xf0       ; Elsõ digit maszkolása
    swp     r0              ; Hexa érték alsó 4 biten
    mov     r1, #SEG_TAB    ; Szegmens tábla báziscím
    add     r1, r0          ; Hexa digit szegmenskép indexe
    mov     r0, (r1)        ; Szegmenskód beolvasása indirekt címzéssel
    mov     DIG3, r0        ; Érték kiírása DIG3-ra

    mov     r0, r9          ; Felsõ bájt alsó digit kijelzése
    and     r0, #0x0f       ; Második digit maszkolása
    mov     r1, #SEG_TAB    ; Szegmens tábla báziscím
    add     r1, r0          ; Hexa digit szegmenskép indexe
    mov     r0, (r1)        ; Szegmenskód beolvasása indirekt címzéssel
    mov     DIG2, r0        ; Érték kiírása DIG2-ra

    mov     r0, r8          ; Alsó bájt felsõ digit kijelzése
    and     r0, #0xf0       ; Elsõ digit maszkolása
    swp     r0              ; Hexa érték alsó 4 biten
    mov     r1, #SEG_TAB    ; Szegmens tábla báziscím
    add     r1, r0          ; Hexa digit szegmenskép indexe
    mov     r0, (r1)        ; Szegmenskód beolvasása indirekt címzéssel
    or      r0, #0x80       ; Törtrész jelzõ hexadecimális pont
    mov     DIG1, r0        ; Érték kiírása DIG1-ra

    mov     r0, r8          ; Alsó bájt alsó digit kijelzése
    and     r0, #0x0f       ; Második digit maszkolása
    mov     r1, #SEG_TAB    ; Szegmens tábla báziscím
    add     r1, r0          ; Hexa digit szegmenskép indexe
    mov     r0, (r1)        ; Szegmenskód beolvasása indirekt címzéssel
    mov     DIG0, r0        ; Érték kiírása DIG0-ra
    
    jmp     wait


;*******************************************************************************
;* A 16 bites hõmérséklet érték beolvasása a TMP121 hõmérõrõl.                 *
;* Visszatérési érték:                                                         *
;*   r8: A 16 bites hõmérséklet érték alsó 8 bitje (LSB).                      *
;*   r9: A 16 bites hõmérséklet érték felsõ 8 bitje (MSB).                     *
;*******************************************************************************
tmp121_rd:
    mov     r0, #0x00       ; A CSn vonal alacsony szintre állítása.
    mov     ADO, r0
    mov     r1, #16         ; 16 bitet olvasunk be a hõmérõrõl. 
tmp121_loop:
    mov     r0, #0x02       ; Az SCK órajel magas szintre állítása.
    mov     ADO, r0
    mov     r0, ADI         ; Beolvassuk a GPIO lábak állapotát.
    and     r0, #0x04       ; Csak a MOSI vonal értéke érdekes.
    add     r0, #0xff       ; A MOSI értékét a C flagba írjuk és ezt
    rlc     r8              ; beléptetjük az r9:r8 regiszterpárba.
    rlc     r9
    mov     r0, #0x00       ; Az SCK órajel alacsony szintre állítása, a lefutó
    mov     ADO, r0         ; élre lépteti ki a TMP121 a következõ adatbitet.
    sub     r1, #1          ; Csökkentjük a beolvasandó bitek számát.
    jnz     tmp121_loop     ; Ugrás, ha még van beolvasandó bit.
    mov     r0, #0x01       ; A CSn vonal magas szintre állítása.
    mov     ADO, r0
    rts                     ; Visszatérés a hívóhoz.
    