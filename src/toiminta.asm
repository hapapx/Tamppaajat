!src "src/tiedostonlataus.asm"

!src "src/teelunta.asm"

!src "src/jalanjaljet.asm"

jmp spriteliiketestiAlustus ; Ohita alla olevat funktiot

spriteliiketestiAlustus

    ; Lumitestaus
    jmp luntaKentalle

ikuinenLuuppi
    jmp ikuinenLuuppi

spriteliiketestiAlku
    lda #$00    ; Animaation vaihe nollaksi
    sta $9000
    lda #$0f    ; Edellinen joystickin arvo
    sta $9001

spriteliiketesti
; Ajankulutuslooppi    
    ldx #$00
spriteliiketestisub1
    lda #$00
    clc
spriteliiketestisub2
    adc #$01
    bcc spriteliiketestisub2
    inx
    cpx #$0A
    bcc spriteliiketestisub1

    ; --- Jos joystickin arvo muuttunut, nollaa jalat
    ldy $DC00   ; Lataa nykyinen arvo
    tya
    and #$0f
    tay
    cmp $9001
    beq jtest0  ; Sama kuin ennen, ei nollata

    lda #$00
    sta $9000
    lda $d002   ; Jalat, sinne missä kroppa on
    sta $d006
    sta $d008
    lda $d003
    sta $d007
    sta $d009

    ; Joystick oikealle?
jtest0
    ; Tallenna nykyinen arvo
    sty $9001
    tya
    cmp #$07
    bne jtest1
    ; Onko jo liian oikealla?
    lda $d002
    cmp #$e0
    bcs jtest1
; --- Oikealle liikkuminen ---
    ; Aseta oikeat spriten pointterit
    lda #$03    ; Kasvot
    sta $5FF8
    lda #$01    ; Pipa
    sta $5FF9
    lda #$00    ; Takki
    sta $5FFA
    lda #$02    ; Vasen jalka
    sta $5FFB
    lda #$05    ; Oikea jalka
    sta $5FFC

    inc $9000
    lda $9000
    and #$03
    cmp #$01
    bne liikuOikealle1
    clc ; Oikea jalka
    lda $d008
    adc #$04
    sta $d008
    jmp liiku
liikuOikealle1
    cmp #$02
    bne liikuOikealle2
    clc
    lda $d002 ; Kroppa
    adc #$02
    sta $d002
    sta $d004
    sta $d000
liikuOikealle2
    cmp #$03
    bne liikuOikealle3
    clc
    lda $d006 ; Vasen jalka
    adc #$04
    sta $d006
liikuOikealle3
    cmp #$00
    bne liikuOikealleLoppu
    clc
    lda $d002 ; Kroppa
    adc #$02
    sta $d002
    sta $d004
    sta $d000
liikuOikealleLoppu
    jmp liiku

jtest1
    ; Joystick vasemmalle?
    tya
    and #$0f
    cmp #$0b
    bne jtest2
    ; Onko jo liian vasemmalla?
    lda $d002
    cmp #$20
    bcc jtest2
; --- Vasemmalle liikkuminen ---
    ; Aseta oikeat spriten pointterit
    lda #$04    ; Kasvot
    sta $5FF8
    lda #$01    ; Pipa
    sta $5FF9
    lda #$00    ; Takki
    sta $5FFA
    lda #$02    ; Vasen jalka
    sta $5FFB
    lda #$05    ; Oikea jalka
    sta $5FFC
    
    inc $9000
    lda $9000
    and #$03
    cmp #$01
    bne liikuVasemmalle1
    sec ; Oikea jalka
    lda $d006
    sbc #$04
    sta $d006
    jmp liiku
liikuVasemmalle1
    cmp #$02
    bne liikuVasemmalle2
    sec
    lda $d002 ; Kroppa
    sbc #$02
    sta $d002
    sta $d004
    sta $d000
liikuVasemmalle2
    cmp #$03
    bne liikuVasemmalle3
    sec
    lda $d008 ; Vasen jalka
    sbc #$04
    sta $d008
liikuVasemmalle3
    cmp #$00
    bne liikuVasemmalleLoppu
    sec
    lda $d002 ; Kroppa
    sbc #$02
    sta $d002
    sta $d004
    sta $d000
liikuVasemmalleLoppu
    jmp liiku

jtest2
   ; Joystick alas?
    tya
    and #$0f
    cmp #$0d
    bne jtest3
; Onko jo liian alhaalla?
    lda $d003
    cmp #$dc
    bcs jtest3
; --- Alas liikkuminen ---
    ; Aseta oikeat spriten pointterit
    lda #$09    ; Kasvot
    sta $5FF8
    lda #$01    ; Pipa
    sta $5FF9
    lda #$06    ; Takki
    sta $5FFA
    lda #$07    ; Vasen jalka
    sta $5FFB
    lda #$0A    ; Oikea jalka
    sta $5FFC
    
    inc $9000
    lda $9000
    and #$03
    cmp #$01
    bne liikuAlas1
    clc ; Oikea jalka
    lda $d009
    adc #$04
    sta $d009
    jmp liiku
liikuAlas1
    cmp #$02
    bne liikuAlas2
    clc
    lda $d003 ; Kroppa
    adc #$02
    sta $d003
    sta $d005
    sta $d001
liikuAlas2
    cmp #$03
    bne liikuAlas3
    clc
    lda $d007 ; Vasen jalka
    adc #$04
    sta $d007
liikuAlas3
    cmp #$00
    bne liikuAlasLoppu
    clc
    lda $d003 ; Kroppa
    adc #$02
    sta $d003
    sta $d005
    sta $d001
liikuAlasLoppu
    jmp liiku

jtest3
   ; Joystick ylös?
    tya
    and #$0f
    cmp #$0e
    bne jtest4
; Onko jo liian ylhäällä?
    lda $d003
    cmp #$40
    bcc jtest4
; --- Ylös liikkuminen ---
    ; Aseta oikeat spriten pointterit
    lda #$08    ; Kasvot
    sta $5FF8
    lda #$01    ; Pipa
    sta $5FF9
    lda #$06    ; Takki
    sta $5FFA
    lda #$07    ; Vasen jalka
    sta $5FFB
    lda #$0A    ; Oikea jalka
    sta $5FFC
    
    inc $9000
    lda $9000
    and #$03
    cmp #$01
    bne liikuYlös1
    sec ; Oikea jalka
    lda $d007
    sbc #$04
    sta $d007
    jmp liiku
liikuYlös1
    cmp #$02
    bne liikuYlös2
    sec
    lda $d003 ; Kroppa
    sbc #$02
    sta $d003
    sta $d005
    sta $d001
liikuYlös2
    cmp #$03
    bne liikuYlös3
    sec
    lda $d009 ; Vasen jalka
    sbc #$04
    sta $d009
liikuYlös3
    cmp #$00
    bne liikuYlösLoppu
    sec
    lda $d003 ; Kroppa
    sbc #$02
    sta $d003
    sta $d005
    sta $d001
liikuYlösLoppu
    jmp liiku

jtest4
   ; Joystick koilliseen?
    tya
    and #$0f
    cmp #$06
    beq liikuKoilliseen0
    jmp jtest5
; --- Koilliseen liikkuminen ---
liikuKoilliseen0
    ; Onko jo liian ylhäällä?
    lda $d003
    cmp #$40
    bcs liikuKoilliseen0a
    jmp jtest5
liikuKoilliseen0a
    ; Onko jo liian oikealla?
    lda $d002
    cmp #$e0
    bcc liikuKoilliseen0b
    jmp jtest5
liikuKoilliseen0b
    ; Aseta oikeat spriten pointterit
    lda #$0E    ; Kasvot
    sta $5FF8
    lda #$01    ; Pipa
    sta $5FF9
    lda #$0B    ; Takki
    sta $5FFA
    lda #$0C    ; Vasen jalka
    sta $5FFB
    lda #$0F    ; Oikea jalka
    sta $5FFC    
    inc $9000
    lda $9000
    and #$03
    cmp #$01
    bne liikuKoilliseen1
    sec ; Oikea jalka
    lda $d009
    sbc #$03
    sta $d009
    clc
    lda $d008
    adc #$03
    sta $d008
    jmp liiku
liikuKoilliseen1
    cmp #$02
    bne liikuKoilliseen2
    sec
    lda $d003 ; Kroppa
    sbc #$01
    sta $d003
    sta $d005
    sta $d001
    clc
    lda $d002
    adc #$01
    sta $d002
    sta $d004
    sta $d000    
liikuKoilliseen2
    cmp #$03
    bne liikuKoilliseen3
    sec
    lda $d007 ; Vasen jalka
    sbc #$03
    sta $d007
    clc
    lda $d006 ; Vasen jalka
    adc #$03
    sta $d006
liikuKoilliseen3
    cmp #$00
    bne liikuKoilliseenLoppu
    sec
    lda $d003 ; Kroppa
    sbc #$02
    sta $d003
    sta $d005
    sta $d001
    clc
    lda $d002 ; Kroppa
    adc #$02
    sta $d002
    sta $d004
    sta $d000
liikuKoilliseenLoppu
    jmp liiku

jtest5
   ; Joystick lounaaseen?
    tya
    and #$0f
    cmp #$09
    beq liikuLounaaseen0
    jmp jtest6

; --- Lounaaseen liikkuminen ---
liikuLounaaseen0
; Onko jo liian alhaalla?
    lda $d003
    cmp #$dc
    bcc liikuLounaaseen0a
    jmp jtest6
liikuLounaaseen0a
    ; Onko jo liian vasemmalla?
    lda $d002
    cmp #$20
    bcs liikuLounaaseen0b
    jmp jtest6
liikuLounaaseen0b
    ; Aseta oikeat spriten pointterit
    lda #$0D    ; Kasvot
    sta $5FF8
    lda #$01    ; Pipa
    sta $5FF9
    lda #$0B    ; Takki
    sta $5FFA
    lda #$0C    ; Vasen jalka
    sta $5FFB
    lda #$0F    ; Oikea jalka
    sta $5FFC    
    inc $9000
    lda $9000
    and #$03
    cmp #$01
    bne liikuLounaaseen1
    clc ; Oikea jalka
    lda $d007
    adc #$03
    sta $d007
    sec
    lda $d006
    sbc #$03
    sta $d006
    jmp liiku
liikuLounaaseen1
    cmp #$02
    bne liikuLounaaseen2
    clc
    lda $d003 ; Kroppa
    adc #$01
    sta $d003
    sta $d005
    sta $d001
    sec
    lda $d002
    sbc #$01
    sta $d002
    sta $d004
    sta $d000    
liikuLounaaseen2
    cmp #$03
    bne liikuLounaaseen3
    clc
    lda $d009 ; Vasen jalka
    adc #$03
    sta $d009
    sec
    lda $d008 ; Vasen jalka
    sbc #$03
    sta $d008
liikuLounaaseen3
    cmp #$00
    bne liikuLounaaseenLoppu
    clc
    lda $d003 ; Kroppa
    adc #$02
    sta $d003
    sta $d005
    sta $d001
    sec
    lda $d002 ; Kroppa
    sbc #$02
    sta $d002
    sta $d004
    sta $d000
liikuLounaaseenLoppu
    jmp liiku

jtest6
   ; Joystick kaakkoon?
    tya
    and #$0f
    cmp #$05
    beq liikuKaakkoon0
    jmp jtest7

; --- Kaakkoon liikkuminen ---
liikuKaakkoon0
    ; Onko jo liian alhaalla?
    lda $d003
    cmp #$dc
    bcc liikuKaakkoon0a
    jmp jtest7
liikuKaakkoon0a
    ; Onko jo liian oikealla?
    lda $d002
    cmp #$e0
    bcc liikuKaakkoon0b
    jmp jtest7
liikuKaakkoon0b
    ; Aseta oikeat spriten pointterit
    lda #$12    ; Kasvot
    sta $5FF8
    lda #$01    ; Pipa
    sta $5FF9
    lda #$10    ; Takki
    sta $5FFA
    lda #$11    ; Vasen jalka
    sta $5FFB
    lda #$14    ; Oikea jalka
    sta $5FFC    
    inc $9000
    lda $9000
    and #$03
    cmp #$01
    bne liikuKaakkoon1
    clc ; Oikea jalka
    lda $d007
    adc #$03
    sta $d007
    clc
    lda $d006
    adc #$03
    sta $d006
    jmp liiku
liikuKaakkoon1
    cmp #$02
    bne liikuKaakkoon2
    clc
    lda $d003 ; Kroppa
    adc #$01
    sta $d003
    sta $d005
    sta $d001
    clc
    lda $d002
    adc #$01
    sta $d002
    sta $d004
    sta $d000    
liikuKaakkoon2
    cmp #$03
    bne liikuKaakkoon3
    clc
    lda $d009 ; Vasen jalka
    adc #$03
    sta $d009
    clc
    lda $d008 ; Vasen jalka
    adc #$03
    sta $d008
liikuKaakkoon3
    cmp #$00
    bne liikuKaakkoonLoppu
    clc
    lda $d003 ; Kroppa
    adc #$02
    sta $d003
    sta $d005
    sta $d001
    clc
    lda $d002 ; Kroppa
    adc #$02
    sta $d002
    sta $d004
    sta $d000
liikuKaakkoonLoppu
    jmp liiku

jtest7
   ; Joystick luoteeseen?
    tya
    and #$0f
    cmp #$0A
    beq liikuLuoteeseen0
    jmp liiku

; --- Luoteeseen liikkuminen ---
liikuLuoteeseen0
    ; Onko jo liian vasemmalla?
    lda $d002
    cmp #$20
    bcs liikuLuoteeseen0a
    jmp liiku
liikuLuoteeseen0a
    ; Onko jo liian ylhäällä?
    lda $d003
    cmp #$40
    bcs liikuLuoteeseen0b
    jmp liiku
liikuLuoteeseen0b
    ; Aseta oikeat spriten pointterit
    lda #$13    ; Kasvot
    sta $5FF8
    lda #$01    ; Pipa
    sta $5FF9
    lda #$10    ; Takki
    sta $5FFA
    lda #$11    ; Vasen jalka
    sta $5FFB
    lda #$14    ; Oikea jalka
    sta $5FFC    
    inc $9000
    lda $9000
    and #$03
    cmp #$01
    bne liikuLuoteeseen1
    sec ; Oikea jalka
    lda $d009
    sbc #$03
    sta $d009
    sec
    lda $d008
    sbc #$03
    sta $d008
    jmp liiku
liikuLuoteeseen1
    cmp #$02
    bne liikuLuoteeseen2
    sec
    lda $d003 ; Kroppa
    sbc #$01
    sta $d003
    sta $d005
    sta $d001
    sec
    lda $d002
    sbc #$01
    sta $d002
    sta $d004
    sta $d000    
liikuLuoteeseen2
    cmp #$03
    bne liikuLuoteeseen3
    sec
    lda $d007 ; Vasen jalka
    sbc #$03
    sta $d007
    sec
    lda $d006 ; Vasen jalka
    sbc #$03
    sta $d006
liikuLuoteeseen3
    cmp #$00
    bne liikuLuoteeseenLoppu
    sec
    lda $d003 ; Kroppa
    sbc #$02
    sta $d003
    sta $d005
    sta $d001
    sec
    lda $d002 ; Kroppa
    sbc #$02
    sta $d002
    sta $d004
    sta $d000
liikuLuoteeseenLoppu
    jmp liiku

liiku

    jmp jalanjaljet