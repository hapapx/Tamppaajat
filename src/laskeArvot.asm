; Lasketaan tietyn väristen merkkien määeä pelikentältä
; Etsittävä arvo oltava osoitteessa $fd
; Tulos tallennetaan osoitteisiin $$c020-$c0211
laskeMerkit

    ; Nollataan laskuri
    lda #$00
    sta $c020
    sta $c021

    ; Lasketaan 3. riviltä 23. riville
    lda #$50
    sta $fb
    lda #$5c
    sta $fc
laskeMerkitSisempi
    ; Lasketaan 3. sarakkeelta lähtien 28. sarakkeelle asti
    ldy #$02
laskeMerkitSisin
    lda ($fb),y
    cmp $fd
    bne laskeMerkitEiLunta
    inc $c020
    bne laskeMerkitEiLunta  ; Menikö laskuri ympäri?
    inc $c021
laskeMerkitEiLunta
    iny
    cpy #$1b
    bne laskeMerkitSisin
    clc         ; Lisätään rivi osoitteeseen
    lda $fb
    adc #$28
    sta $fb
    lda $fc
    adc #$00
    sta $fc
    cmp #$5f
    bne laskeMerkitSisempi
    lda $fb
    cmp #$98
    bne laskeMerkitSisempi
    rts         ; Valmista

; Lasketaan tavun arvot pelikentältä
; Lasketaan yksinkertaisuuden vuoksi myös muista merkeistä kuin lumesta
; Etsittävä arvo oltava osoitteessa $fd
; Rivi, joka lasketaan, on osoitteessa $c024
; Tulos tallennetaan osoitteisiin $$c020-$c0211 (pienempi ensin)

laskeArvot
    
    ; Laitetaan laskettavan rivin alkuosoite $6000 nollasivuun $fb-$fc
    lda #$00
    sta $fb
    lda #$60
    sta $fc
    ; Lisätään rivien määrä × $0140 alkuosoitteeseen
    ldx $c024
laskeArvotLisaaRiveja
    cpx #$00
    beq laskeArvotLoop
    clc
    lda #$40
    adc $fb
    sta $fb
    lda #$01
    adc $fc
    sta $fc
    dex
    jmp laskeArvotLisaaRiveja

laskeArvotLoop
    ldy #2    ; Loopataan 3. sarakkeelta lähtien
    
laskeArvotLoopSisempi    
    lda ($fb),y ; Tarkistetaan onko tavun arvo $aa
    cmp $fd
    bne laskeArvotLoopSisempiEiEtsitty    
    inc $c020   ; Tämä on etsitty arvo, lisätään laskuria
    bne laskeArvotLoopSisempiEiEtsitty ; Menikö laskurin alempi tavu ympäri?
    inc $c021

laskeArvotLoopSisempiEiEtsitty
    iny         ; Loopataan 28. sarakkeelle asti eli 224 tavua
    cpy #$e0
    bne laskeArvotLoopSisempi

laskeArvotPoistu
    rts     ; Palataan sinne mistä tultiin