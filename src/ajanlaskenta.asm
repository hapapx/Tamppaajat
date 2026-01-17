ajanlaskentaNollaKello
    sei         ; Nollataan kello
    lda #0
    sta $a0     ; TI_LO
    sta $a1     ; TI_MI
    ; sta $a2     ; TI_HI
    ; sta $a3     ; TI_HOURS
    cli
    rts

ajanlaskentaAsetaPalkinLoppuun
    lda #$07     ; Palkin pituus
    sta $c022
    rts

ajanlaskentaPäivitäPalkki
    lda $a1; Onko kello yli?
    bne ajanlaskentaPäivitäPalkkiSeuraavaAskel
    rts
ajanlaskentaPäivitäPalkkiSeuraavaAskel
    ldy $c022
    lda #$70                    ; Laita pykälä mustaksi. $5fb6 on aikapalkin ensimmäisen merkin väri
    sta $5fb6,y                 
    jsr ajanlaskentaNollaKello  ; Nollaa aika
    dec $c022                   ; Vähennä pykälän osoitetta

    ; Oliko viimeinen pykälä    
    lda $c022
    cmp #$ff
    beq ajanlaskentaAikaLoppu    
    rts         ; Ei ollut viimeinen pykälä

ajanlaskentaAikaLoppu
    lda #$00 ; Tässä aika loppuisi
    rts