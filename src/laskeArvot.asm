; Lasketaan tavun arvot pelikentältä
; Lasketaan yksinkertaisuuden vuoksi myös muista merkeistä kuin lumesta
; Etsittävä arvo oltava osoitteessa $fd
; Rivi, joka lasketaan, on osoitteessa $c024

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