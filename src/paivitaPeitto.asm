paivitaPeitto

    ; Käy laskemassa harmaat yhdeltä riviltä
    lda #$55
    sta $fd
    jsr laskeArvot

    ; Debug
    lda $c020
    lda $c021
    lda $c022
    lda $c023

    ; Jos tämä oli rivi 23. rivi, päivitetään peittomittari
    lda $c024
    cmp #$22
    bne paivitaPeittoSeuraavaRivi
    ; Tässä päivitettäisiin peittomittaria
    ; Nollataan laskuri
    lda #$00
    sta $c020
    sta $c021
    ; Aloitetaan jalanjälkien laskenta uudestaan 3. riviltä
    lda #$02
    sta $c024
    jmp paivitaPeittoPoistu

paivitaPeittoSeuraavaRivi
    inc $c024

paivitaPeittoPoistu
    rts