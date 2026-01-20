; Alifunktio kopioi y tavua osoiteesta ($fb) osoitteeseen ($fd)
kentanLoppuTampaxiKopioiYTavua
    dey     ; Eka pois, koska loopataan (y-1):stä nollaan
kentanLoppuTampaxiKopioiYTavuaLoop
    lda ($fb),Y
    sta ($fd),Y
    dey
    bpl kentanLoppuTampaxiKopioiYTavuaLoop
    rts

; Alifunktio kopioi 8 tavua osoiteesta ($fb) osoitteeseen ($fd)
kentanLoppuTampaxiKopioi8Tavua
    ldy #$07    
kentanLoppuTampaxiKopioi8TavuaLoop
    lda ($fb),Y
    sta ($fd),Y
    dey
    bpl kentanLoppuTampaxiKopioi8TavuaLoop
    rts

kentanLoppuTampaxiValmis
    ; Kopioidaan kehyksen vasen yläkulma
    lda #$d0    ; Kehyksen vasen yläkulma osoitteessa $10d0
    sta $fb
    lda #$10
    sta $fc
    lda #$50    ; Kehyksen vasen yläkulma tulee osoitteeseen $6a50
    sta $fd
    lda #$6a
    sta $fe
    jsr kentanLoppuTampaxiKopioi8Tavua

    ; Kopioidaan kehyksen ylälaita seitsemän kertaa
    lda #$d8    ; Kehyksen ylä osoitteessa $10d8
    sta $fb
    lda #$58    ; Lähtee osoitteesta $6a58
    sta $fd
    ldx #$06
kentanLoppuTampaxiValmisLoop2a
    jsr kentanLoppuTampaxiKopioi8Tavua
    clc         ; Seuraava merkki
    lda $fd
    adc #$08
    sta $fd
    dex
    bpl kentanLoppuTampaxiValmisLoop2a

    ; Kopioidaan kehyksen oikea yläkulma
    lda #$e0    ; Kehyksen oikea yläkulma osoitteessa $10e0
    sta $fb
    lda #$90    ; Kehyksen oikea yläkulma tulee osoitteeseen $6a90
    sta $fd
    jsr kentanLoppuTampaxiKopioi8Tavua

    ; Kopioidaan kehyksen vasen reuna kahdesti
    lda #$e8    ; Kehyksen vasen reuna osoitteessa $10e8
    sta $fb
    lda #$90    ; Kehyksen vasen reuna osoitteeseen $6b90
    sta $fd
    lda #$6b
    sta $fe
    jsr kentanLoppuTampaxiKopioi8Tavua    
    lda #$d0    ; Kehyksen vasen reuna osoitteeseen $6cd0
    sta $fd
    lda #$6c
    sta $fe
    jsr kentanLoppuTampaxiKopioi8Tavua

    ; Kopioidaan kehyksen oikea reuna kahdesti
    lda #$f0    ; Kehyksen oikea reuna osoitteessa $10f0
    sta $fb
    lda #$d0    ; Kehyksen oikea reuna osoitteeseen $6bd0
    sta $fd
    lda #$6b
    sta $fe
    jsr kentanLoppuTampaxiKopioi8Tavua    
    lda #$10    ; Kehyksen vasen reuna osoitteeseen $6d10
    sta $fd
    lda #$6d
    sta $fe
    jsr kentanLoppuTampaxiKopioi8Tavua

    ; Kopioidaan kehyksen vasen alakulma
    lda #$f8    ; Kehyksen vasen alakulma osoitteessa $10f8
    sta $fb
    lda #$10    ; Kehyksen vasen alakulma tulee osoitteeseen $6e10
    sta $fd
    lda #$6e
    sta $fe
    jsr kentanLoppuTampaxiKopioi8Tavua

    ; Kopioidaan kehyksen alalaita seitsemän kertaa
    lda #$00    ; Kehyksen ala osoitteessa $1100
    sta $fb
    lda #$11
    sta $fc    
    lda #$18    ; Lähtee osoitteesta $6e18
    sta $fd
    ldx #$06
kentanLoppuTampaxiValmisLoop3
    jsr kentanLoppuTampaxiKopioi8Tavua
    clc         ; Seuraava merkki
    lda $fd
    adc #$08
    sta $fd
    dex
    bpl kentanLoppuTampaxiValmisLoop3

    ; Kopioidaan kehyksen oikea alakulma
    lda #$08    ; Kehyksen oikea alakulma osoitteessa $1108
    sta $fb
    lda #$50    ; Kehyksen oikea alakulma tulee osoitteeseen $6e50
    sta $fd
    lda #$6e
    sta $fe
    jsr kentanLoppuTampaxiKopioi8Tavua

    ; Kopioidaan teksti TAMPAXI
    lda #$10    ; Alkaen osoitteesta $1110
    sta $fb
    lda #$98    ; Alkaen osoitteeseen $6ba0
    sta $fd
    lda #$6b
    sta $fe
    ldy #$38
    jsr kentanLoppuTampaxiKopioiYTavua

    ; Kopioidaan teksti VALMIS!
    lda #$48    ; Alkaen osoitteesta $1148
    sta $fb
    lda #$d8    ; Alkaen osoitteeseen $6cd8
    sta $fd
    lda #$6c
    sta $fe
    ldy #$38
    jsr kentanLoppuTampaxiKopioiYTavua

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

    ldx #$00
kentanLoppuAjantuhlausLoop
    ldy #$00
kentanLoppuAjantuhlausLoopSisempi
    lda $c020
    iny
    cpy #$ff
    bne kentanLoppuAjantuhlausLoopSisempi
    inx
    cpx #$ff
    bne kentanLoppuAjantuhlausLoop
    nop

    jmp luntaKentalle