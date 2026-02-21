ajanlaskentaNollaKello
    sei         ; Nollataan kello
    lda #$00
    sta $a0     ; TI_LO
    sta $a1     ; TI_MI
    sta $a2     ; TI_HI
    cli
    rts

ajanlaskentaAsetaPalkinLoppuun
    lda #$07     ; Palkin pituus
    sta $c022
    rts

ajanlaskentaPäivitäPalkki
    lda $a1; Onko kello yli?
    cmp #$02
    ;lda $a2; Onko kello yli? DEBUG
    ;cmp #$20    
    beq ajanlaskentaPäivitäPalkkiSeuraavaAskel
    jmp toimintaPaluuAjanPaivityksesta
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
    jmp toimintaPaluuAjanPaivityksesta  ; Ei ollut viimeinen pykälä

ajanlaskentaAikaLoppu
    jmp kentanLoppuAikaLoppui ; Aika loppui!
    