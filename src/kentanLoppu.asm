; Alifunktio: Odota napin painallusta ja näytä animaatio
kentanLoppuOdotaNappia

    ; Odotellaan ensin tovi
    jsr ajanlaskentaNollaKello    
    lda #$01
kentanLoppuOdotaNappiaAlkuOdotusLoop
    cmp $a1
    bne kentanLoppuOdotaNappiaAlkuOdotusLoop

    ; Painonappi näkyviin
    lda $d015   ; Punainen ja musta näkyville
    ora #$60
    sta $d015
    lda #$98    ; Nappianimaation sijainti
    sta $d00a
    sta $d00c
    lda #$88
    sta $d00b
    sta $d00d

    ; Animoidaan painonappia, kunnes joystickin nappia painetaan
kentanLoppuOdotaNappiaAnimaatioLoop
    lda $dc00                       ; Onko joystickin nappi pohjassa
    and #$10
    beq kentanLoppuNappiaPainettu
    lda $a2                         ; Jos kelloa alemman tavun bitit 3-4 ovat 01, nappi alas. Muuten ylös.
    and #$18
    cmp #$08
    beq kentanLoppuOdotaNappiaAnimaatioNappiAlas
    lda #$15    ; Animaatio: nappi ylhäällä
    sta $5ffe
    lda #$16
    sta $5ffd
    jmp kentanLoppuOdotaNappiaAnimaatioLoop
kentanLoppuOdotaNappiaAnimaatioNappiAlas
    lda #$18    ; Animaatio: nappi alhaalla
    sta $5ffe
    lda #$17
    sta $5ffd
    jmp kentanLoppuOdotaNappiaAnimaatioLoop

kentanLoppuNappiaPainettu
    lda $d015   ; Piilota nappispritet
    and #$bf
    and #$df
    sta $d015

    ; Ikuinen loop
ikuinenLoop
    nop
;    jmp ikuinenLoop

    ; Uusi kenttä
    inc $c025
    jmp toimintaAloitaUusiKentta


; Alifunktio: kopioi 8 tavua osoitteesta ($fb) osoitteeseen ($fd) toistaen x kertaa
kentaLoppuKopioiMerkkiXKertaa
    dex     ; Eka pois, koska loopataan (x-1):stä nollaan
kentaLoppuKopioiMerkkiXKertaaLoop
    ldy #07
kentaLoppuKopioiMerkkiXKertaaLoopSisempi
    lda ($fb),Y
    sta ($fd),Y
    dey
    bpl kentaLoppuKopioiMerkkiXKertaaLoopSisempi
    dex     ; Lopetetaanko
    bmi kentaLoppuKopioiMerkkiXKertaaPoistu
    clc     ; Seuraava merkki kohdeosoitteelle
    lda $fd
    adc #$08
    sta $fd
    lda $fe
    adc #$00
    sta $fe
    jmp kentaLoppuKopioiMerkkiXKertaaLoop
kentaLoppuKopioiMerkkiXKertaaPoistu
    rts

; Alifunktio: kopioi y tavua osoiteesta ($fb) osoitteeseen ($fd)
kentanLoppuKopioiYTavua
    dey     ; Eka pois, koska loopataan (y-1):stä nollaan
kentanLoppuKopioiYTavuaLoop
    lda ($fb),Y
    sta ($fd),Y
    dey
    bpl kentanLoppuKopioiYTavuaLoop
    rts

; Alifunktio kopioi 8 tavua osoiteesta ($fb) osoitteeseen ($fd)
kentanLoppuKopioi8Tavua
    ldy #$07    
kentanLoppuKopioi8TavuaLoop
    lda ($fb),Y
    sta ($fd),Y
    dey
    bpl kentanLoppuKopioi8TavuaLoop
    rts

; Tehdään kehys
; Kohdeosoite grafiikkamuistissa oltava nollasivussa $fd-$fe
; Kehyksen leveys osoitteessa $c000 ja korkeus $c001
kentanLoppuTeeKehys
    ; Otetaan alkuperäinen kohdeosoite talteen
    lda $fd
    sta $c002
    lda $fe
    sta $c003
    ; Kopioidaan kehyksen vasen yläkulma
    lda #$d0
    sta $fb
    lda #$10
    sta $fc
    jsr kentanLoppuKopioi8Tavua
    ; Kopioidaan vasen laita (korkeus-2) kertaa
    ldx $c001
    dex
    dex
    lda #$e8    ; Kehyksen vasen reuna osoitteessa $10e8
    sta $fb
kentanLoppuTeeKehysVasenLaitaLoop    
    clc         ; Lisätään rivi kohdeosoitteeseen
    lda $fd
    adc #$40
    sta $fd
    lda $fe
    adc #01
    sta $fe
    jsr kentanLoppuKopioi8Tavua
    dex
    bne kentanLoppuTeeKehysVasenLaitaLoop
    ; Kopioidaan kehyksen vasen alakulma
    lda #$f8    ; Kehyksen vasen alakulma osoitteessa $10f8
    sta $fb
    clc         ; Seuraava kohderivi
    lda $fd
    adc #$40
    sta $fd
    lda $fe
    adc #01
    sta $fe
    jsr kentanLoppuKopioi8Tavua
    ; Kopioidaan kehyksen alalaita (leveys-2) kertaa
    lda #$00    ; Kehyksen alalaidan merkki osoitteessa $1100
    sta $fb
    lda #$11
    sta $fc
    ldx $c000   ; Laidan pituus (leveys-2)
    dex
    dex
    clc         ; Kohdesoitteen seuraava merkki
    lda $fd
    adc #$08
    sta $fd
    lda $fe
    adc #$00
    sta $fe
    jsr kentaLoppuKopioiMerkkiXKertaa
    ; Kopioidaan kehyksen oikea alakulma
    lda #$08    ; Kehyksen oikea alakulma osoitteessa $1108
    sta $fb
    clc         ; Kohdesoitteen seuraava merkki
    lda $fd
    adc #$08
    sta $fd
    lda $fe
    adc #$00
    sta $fe
    jsr kentanLoppuKopioi8Tavua
    ; Kopioidaan kehyksen ylälaita (leveys-2) kertaa
    lda #$d8    ; Kehyksen ylälaidan merkki osoitteessa $10d8
    sta $fb
    lda #$10
    sta $fc
    ldx $c000   ; (leveys-2) kertaa
    dex
    dex
    clc         ; Kohdeosoitteen alku ylälaidalle
    lda $c002
    adc #$08
    sta $fd
    lda $c003
    adc #$00
    sta $fe
    jsr kentaLoppuKopioiMerkkiXKertaa
    ; Kopioidaan kehyksen oikea yläkulma
    clc         ; Seuraava merkki
    lda $fd
    adc #$08
    sta $fd
    lda $fe
    adc #$00
    sta $fe
    lda #$e0    ; Kehyksen oikea yläkulma osoitteessa $10e0
    sta $fb
    jsr kentanLoppuKopioi8Tavua
    ; Kopioidaan oikea laita (korkeus-2) kertaa
    ldx $c001
    dex
    dex
    lda #$f0    ; Kehyksen oikea reuna osoitteessa $10f0
    sta $fb
kentanLoppuTeeKehysOikeaLaitaLoop
    clc         ; Lisätään rivi kohdeosoitteeseen
    lda $fd
    adc #$40
    sta $fd
    lda $fe
    adc #01
    sta $fe
    jsr kentanLoppuKopioi8Tavua
    dex
    bne kentanLoppuTeeKehysOikeaLaitaLoop    

    rts

kentanLoppuTampaxiValmis
    ; Tehdään kehys tekstille TAMPAXI VALMIS
    ; Kehyksen vasemman yläkulman osoite: $6a50
    lda #$50
    sta $fd
    lda #$6a
    sta $fe
    ; Kehyksen leveys ja korkeus: 9 ja 4 (teksti 7 ja 2)
    lda #$09
    sta $c000
    lda #$04
    sta $c001
    jsr kentanLoppuTeeKehys

    ; Kopioidaan teksti TAMPAXI
    lda #$10    ; Alkaen osoitteesta $1110
    sta $fb
    lda #$11
    sta $fc
    lda #$98    ; Alkaen osoitteeseen $6ba0
    sta $fd
    lda #$6b
    sta $fe
    ldy #$38
    jsr kentanLoppuKopioiYTavua

    ; Kopioidaan teksti VALMIS!
    lda #$48    ; Alkaen osoitteesta $1148
    sta $fb
    lda #$d8    ; Alkaen osoitteeseen $6cd8
    sta $fd
    lda #$6c
    sta $fe
    ldy #$38
    jsr kentanLoppuKopioiYTavua

    ; Värit tauluun
    lda #$71    ; Keltainen ja valkea
    ldy #$08
kentanLoppuTaulunVäritLoop
    sta $5d4a,y
    sta $5dc2,y
    dey
    bpl kentanLoppuTaulunVäritLoop
    sta $5d72   ; Vasen laita
    sta $5d9a
    sta $5d7a   ; Oikea laita
    sta $5da2
    ; Värit tekstiin
    lda #$01    ; Valkea ja musta
    ldy #$06
kentanLoppuTaulunVäritLoop2
    sta $5d73,y
    sta $5d9b,y
    dey
    bpl kentanLoppuTaulunVäritLoop2

    rts; Paluu

; -------------------------

kentanLoppuKokoKenttäHarmaaksi
    lda #$28    ; Näyttömuistin toinen rivi alkaa $5c28
    sta $fb
    lda #$5c
    sta $fc
    lda #$28    ; Värimuistin toinen rivi alkaa $d828
    sta $fd
    lda #$d8
    sta $fe
    ldx #$00
kentanLoppuKokoKenttäHarmaaksiLoop
    ldy #$01    
kentanLoppuKokoKenttäHarmaaksiLoopSisempi
    lda #$bb        ; Harmaa ja harmaa
    sta ($fb),y
    lda ($fd),Y
    and #$f0
    ora #$0b
    sta ($fd),y
    iny
    cpy #$1c
    bne kentanLoppuKokoKenttäHarmaaksiLoopSisempi
    inx
    cpx #$17
    beq kentanLoppuKokoKenttäHarmaaksiSpritet
    clc     
    lda $fb     ; Lisää rivi näyttömuistiosoittimeen
    adc #$28
    sta $fb
    lda $fc
    adc #$00
    sta $fc
    lda $fd     ; Lisää rivi värimuistiosoittimeen
    adc #$28
    sta $fd
    lda $fe
    adc #$00
    sta $fe
    jmp kentanLoppuKokoKenttäHarmaaksiLoop

kentanLoppuKokoKenttäHarmaaksiSpritet
    lda #$00        ; Spritet pois käytöstä
    sta $d015
    
kentanLoppuKokoKenttäHarmaaksiLoppu
    rts

kentanLoppuValmis

    jsr kentanLoppuKokoKenttäHarmaaksi

    jsr kentanLoppuTampaxiValmis

    jsr kentanLoppuOdotaNappia

    
    nop

    jmp luntaKentalle