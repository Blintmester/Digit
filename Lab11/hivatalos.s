;*******************************************************************************
;* Szervomotor vez�rl�se PWM jellel.                                           *
;* A DIP kapcsol�n be�ll�that� a kit�r�s m�rt�ke 0,5% pontoss�ggal.            *
;* Sajnos a motor ezt a felbont�st mechanikai okob�l nem tudja teljes�teni     *
;*                                                                             *
;* A szervomotor PWM jellel vez�relhet�. A PWM jel magas szintj�nek ideje      *
;* hat�rozza meg a kit�r�s ir�ny�t �s m�rt�k�t. A 0 fokos alaphelyzethez       *
;* �ltal�ban t = 1,5 ms magas szint tartozik.                                  *
;*                                                                             *
;*     |<--------------- T ------------------>|                                *
;*      ---------                              --------                        *
;*     /         \                            /        \                       *
;*  ---           ----------------------------          ------                 *
;*     |<-- t -->|                                                             *
;*                                                                             *
;* A PWM jel szok�sos peri�dusideje (T) 20 ms, de ez viszonylag t�g hat�rok    *
;* k�z�tt mozoghat a motor megfelel� m�k�d�se mellett. Mi 16,4ms-ra �ll�tjuk   *
;*                                                                             *
;* A szervo vez�rl�s�hez 1ms-2ms �rt�ket �ll�tubk be, 1,5ms k�z�p�rt�kkel      *
;* A pulzus �t�ke a k�vetkez� lesz: 1ms alapofszet + 1ms a kapcsol� �ll�sb�l   *
;* t = 1000 us -> MINIMUM   SW kapcsol�  =   0 + 256 = 256                     *
;* t = 1500 us ->   K�Z�P   SW kapcsol�  = 127 + 256 = 383                     *
;* t = 2000 us -> MAXIMUM   SW kapcsol�  = 255 + 256 = 511                     *
;*******************************************************************************
DEF SW      0x81        ; DIP kapcsol� adatregiszter      (csak olvashat�)
DEF TM      0x82        ; Id�z�t� sz�ml�l� regiszter      (�rhat�/olvashat�)
DEF TC      0x83        ; Id�z�t� parancs regiszter       (csak �rhat�)
DEF TS      0x83        ; Id�z�t� st�tusz regiszter       (csak olvashat�)
DEF CDO     0xa4        ; GPIO_C kimeneti adatregiszter   (�rhat�/olvashat�)
DEF CDR     0xa6        ; GPIO_C ir�nyregiszter           (�rhat�/olvashat�)

    CODE
    
;*******************************************************************************
;* A reset �s a megszak�t�s vektorok.                                          *
;*******************************************************************************
    jmp     start       ; Reset vektor.
    jmp     tmr_irq     ; Megszak�t�s vektor.
    
    
;*******************************************************************************
;* A program kezdete.                                                          *
;* Regiszter haszn�lat:                                                        *
;*     (r13:r12) Aktu�lis pulzussz�less�g      256 - 511   Tw= 1ms-2ms         *
;*     (r11:r10) A teljes id�z�t�si peri�dus   0 - 4095    T=16,4ms            *
;*      r0 munkaregiszter                                                      *
;*******************************************************************************
start:
    mov     r10, #0     ; A PWM sz�ml�l� (r11:r10) null�z�sa.
    mov     r11, #0     ; 16 bites, 65535 v�g�rt�kkel (csak 4095-ig haszn�ljuk)
    mov     r12, #127   ; A kit�lt�si t�nyez� be�ll�t�sa (127) a K�Z�P �ll�shoz
    mov     r13, #1     ; A kit�lt�si t�nyez� fels� b�jtja (256, 16 biten)
    
    mov     r0, #0x00   ; A GPIO port konfigur�l�sa: GPIO_C[1] bit kimenet.
    mov     CDO, r0     ; Alap�rt�k 0V
    mov     r0, #0x02
    mov     CDR, r0     ; �lland� kimenetk�nt engd�lyezve
    
;*******************************************************************************
;* Az id�z�t� felprogramoz�sa                                                  *
;* Az id�z�t� be�ll�t�sa kb. 4 us peri�dusid�re, 62,5 ns * 64 = 4000 ns = 4 us *
;* �zemm�d: Peri�dikus, nincs el�iszt�s, IRQ enged�lyez�ssel                   *
;*******************************************************************************
 
    mov     r0, #63     ; A sz�ml�l� regiszter �rt�ke 64-1 = (0x3F).
    mov     TM, r0      ; Be�r�s a TM id�z�t� regiszterbe.
    mov     r0, #0x83   ; Az id�z�t� konfigur�l�sa: IRQ, nincs el�oszt�s,
    mov     TC, r0      ; ism�tl�ses m�d, id�z�t� enged�lyezve (1000_0011).
    mov     r0, TS      ; Az id�z�t� esetleges TOUT jelz�s�nek t�rl�se.
    sti                 ; A megszak�t�s enged�lyez�se.

;*******************************************************************************
;* A f�program                                                                 *
;* jelen esetben nem csin�l semmit,                                            *
;*******************************************************************************

loop:
    mov     r12, SW     ; A DIP kapcsol�n �ll�that� be a kit�r�s 256 l�p�sben
                        ; MINIMUM �s MAXIMUM k�z�tt 
                        ; (127/128-n�l van a K�Z�P �ll�s
                        ; A MINIMUM-hoz sz�k�seges 1ms (=256) ofszet �rt�ke m�r
                        ; el�k�sz�tve az r13-ban (r13:r12)=0000_0001_xxxx_xxxx
                        
                        ; Ide tetsz�leges program �rhat�, ami motorvez�rl�s 
                        ; �llapotregisztereinek �rt�k�t nem m�dos�tja, de 
                        ; 
    jmp     loop
   
   
   
   
;*******************************************************************************
;* A megszak�t�skezel� rutin.                                                  *
;* Regiszter haszn�lat:                                                        *
;*     (r15:r14) 16 bites munkaregister                                        *
;*     (r13:r12) Aktu�lis pulzussz�less�g      256 - 512   Tw= 1ms-2ms         *
;*     (r11:r10) A teljes id�z�t�si peri�dus   0 - 4095    T=16,4ms            *
;*******************************************************************************
tmr_irq:   

    mov     r14, r10    ; �sszehasonl�tjuk a PWM sz�ml�l�t (r11:r10) a kit�lt�si
    mov     r15, r11    ; t�nyez�vel (r13:r12). PWM = 0-4095, Tw = 256 - 511 
    sub     r14, r12    ; Am�g a PWM sz�ml�l� kisebb, mint akit�lt�si t�nyez�, 
    sbc     r15, r13    ; addig a kivon�s ut�n a C flag �rt�ke 1 lesz, egy�bk�nt 0
    mov     r14, #0     ; Null�zzuk r14-et, a C flag fogad�s�ra
    rlc     r14         ; A C flag-et r14-be l�ptetj�k rot�l�ssal, 
    sl0     r14         ; majd egy poz�ci�val m�g balra shiftelj�k, az 1. bitre
    mov     CDO, r14    ; Ezut�n ki�rjuk a kapott �rt�ket a GPIO_C port [1] bitre
    
    add     r10, #1     ; Megn�velj�k a PWM sz�ml�l� �rt�k�t �s �sszehasonl�tjuk
    adc     r11, #0     ; a peri�dusid�vel, melyet 4095-nek v�lasztottunk az
    tst     r11, #0x10  ; egyszer�s�g kedv��rt (2^12 -> bit 12 tesztel�se).
    jz      irq_end     ; Ugr�s, ha nem vagyunk a peri�dus v�g�n.

    mov     r10, #0     ; A peri�dus v�g�n t�r�lj�k a PWM sz�ml�l�t �s friss�tj�k
    mov     r11, #0     ; a kit�lt�si t�nyez�t. 
    
irq_end:
    mov     r14, TS     ; A megszak�t�s jelz�s t�rl�se.
    rti                 ; Visszat�r�s a megszak�t�sb�l.


