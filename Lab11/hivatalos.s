;*******************************************************************************
;* Szervomotor vezérlése PWM jellel.                                           *
;* A DIP kapcsolón beállítható a kitérés mértéke 0,5% pontossággal.            *
;* Sajnos a motor ezt a felbontást mechanikai okoból nem tudja teljesíteni     *
;*                                                                             *
;* A szervomotor PWM jellel vezérelhetõ. A PWM jel magas szintjének ideje      *
;* határozza meg a kitérés irányát és mértékét. A 0 fokos alaphelyzethez       *
;* általában t = 1,5 ms magas szint tartozik.                                  *
;*                                                                             *
;*     |<--------------- T ------------------>|                                *
;*      ---------                              --------                        *
;*     /         \                            /        \                       *
;*  ---           ----------------------------          ------                 *
;*     |<-- t -->|                                                             *
;*                                                                             *
;* A PWM jel szokásos periódusideje (T) 20 ms, de ez viszonylag tág határok    *
;* között mozoghat a motor megfelelõ mûködése mellett. Mi 16,4ms-ra állítjuk   *
;*                                                                             *
;* A szervo vezérléséhez 1ms-2ms értéket állítubk be, 1,5ms középértékkel      *
;* A pulzus étéke a következõ lesz: 1ms alapofszet + 1ms a kapcsoló állásból   *
;* t = 1000 us -> MINIMUM   SW kapcsoló  =   0 + 256 = 256                     *
;* t = 1500 us ->   KÖZÉP   SW kapcsoló  = 127 + 256 = 383                     *
;* t = 2000 us -> MAXIMUM   SW kapcsoló  = 255 + 256 = 511                     *
;*******************************************************************************
DEF SW      0x81        ; DIP kapcsoló adatregiszter      (csak olvasható)
DEF TM      0x82        ; Idõzítõ számláló regiszter      (írható/olvasható)
DEF TC      0x83        ; Idõzítõ parancs regiszter       (csak írható)
DEF TS      0x83        ; Idõzítõ státusz regiszter       (csak olvasható)
DEF CDO     0xa4        ; GPIO_C kimeneti adatregiszter   (írható/olvasható)
DEF CDR     0xa6        ; GPIO_C irányregiszter           (írható/olvasható)

    CODE
    
;*******************************************************************************
;* A reset és a megszakítás vektorok.                                          *
;*******************************************************************************
    jmp     start       ; Reset vektor.
    jmp     tmr_irq     ; Megszakítás vektor.
    
    
;*******************************************************************************
;* A program kezdete.                                                          *
;* Regiszter használat:                                                        *
;*     (r13:r12) Aktuális pulzusszélesség      256 - 511   Tw= 1ms-2ms         *
;*     (r11:r10) A teljes idõzítési periódus   0 - 4095    T=16,4ms            *
;*      r0 munkaregiszter                                                      *
;*******************************************************************************
start:
    mov     r10, #0     ; A PWM számláló (r11:r10) nullázása.
    mov     r11, #0     ; 16 bites, 65535 végértékkel (csak 4095-ig használjuk)
    mov     r12, #127   ; A kitöltési tényezõ beállítása (127) a KÖZÉP álláshoz
    mov     r13, #1     ; A kitöltési tényezõ felsõ bájtja (256, 16 biten)
    
    mov     r0, #0x00   ; A GPIO port konfigurálása: GPIO_C[1] bit kimenet.
    mov     CDO, r0     ; Alapérték 0V
    mov     r0, #0x02
    mov     CDR, r0     ; Állandó kimenetként engdélyezve
    
;*******************************************************************************
;* Az idõzítõ felprogramozása                                                  *
;* Az idõzítõ beállítása kb. 4 us periódusidõre, 62,5 ns * 64 = 4000 ns = 4 us *
;* Üzemmód: Periódikus, nincs elõisztás, IRQ engedélyezéssel                   *
;*******************************************************************************
 
    mov     r0, #63     ; A számláló regiszter értéke 64-1 = (0x3F).
    mov     TM, r0      ; Beírás a TM idõzítõ regiszterbe.
    mov     r0, #0x83   ; Az idõzítõ konfigurálása: IRQ, nincs elõosztás,
    mov     TC, r0      ; ismétléses mód, idõzítõ engedélyezve (1000_0011).
    mov     r0, TS      ; Az idõzítõ esetleges TOUT jelzésének törlése.
    sti                 ; A megszakítás engedélyezése.

;*******************************************************************************
;* A fõprogram                                                                 *
;* jelen esetben nem csinál semmit,                                            *
;*******************************************************************************

loop:
    mov     r12, SW     ; A DIP kapcsolón állítható be a kitérés 256 lépésben
                        ; MINIMUM és MAXIMUM között 
                        ; (127/128-nál van a KÖZÉP állás
                        ; A MINIMUM-hoz szükéseges 1ms (=256) ofszet értéke már
                        ; elõkészítve az r13-ban (r13:r12)=0000_0001_xxxx_xxxx
                        
                        ; Ide tetszõleges program írható, ami motorvezérlés 
                        ; állapotregisztereinek értékét nem módosítja, de 
                        ; 
    jmp     loop
   
   
   
   
;*******************************************************************************
;* A megszakításkezelõ rutin.                                                  *
;* Regiszter használat:                                                        *
;*     (r15:r14) 16 bites munkaregister                                        *
;*     (r13:r12) Aktuális pulzusszélesség      256 - 512   Tw= 1ms-2ms         *
;*     (r11:r10) A teljes idõzítési periódus   0 - 4095    T=16,4ms            *
;*******************************************************************************
tmr_irq:   

    mov     r14, r10    ; Összehasonlítjuk a PWM számlálót (r11:r10) a kitöltési
    mov     r15, r11    ; tényezõvel (r13:r12). PWM = 0-4095, Tw = 256 - 511 
    sub     r14, r12    ; Amíg a PWM számláló kisebb, mint akitöltési tényezõ, 
    sbc     r15, r13    ; addig a kivonás után a C flag értéke 1 lesz, egyébként 0
    mov     r14, #0     ; Nullázzuk r14-et, a C flag fogadására
    rlc     r14         ; A C flag-et r14-be léptetjük rotálással, 
    sl0     r14         ; majd egy pozícióval még balra shifteljük, az 1. bitre
    mov     CDO, r14    ; Ezután kiírjuk a kapott értéket a GPIO_C port [1] bitre
    
    add     r10, #1     ; Megnöveljük a PWM számláló értékét és összehasonlítjuk
    adc     r11, #0     ; a periódusidõvel, melyet 4095-nek választottunk az
    tst     r11, #0x10  ; egyszerûség kedvéért (2^12 -> bit 12 tesztelése).
    jz      irq_end     ; Ugrás, ha nem vagyunk a periódus végén.

    mov     r10, #0     ; A periódus végén töröljük a PWM számlálót és frissítjük
    mov     r11, #0     ; a kitöltési tényezõt. 
    
irq_end:
    mov     r14, TS     ; A megszakítás jelzés törlése.
    rti                 ; Visszatérés a megszakításból.


