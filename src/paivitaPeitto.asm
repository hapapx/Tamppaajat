paivitaPeitto

    ; Käy laskemassa harmaat yhdeltä riviltä
    lda #$55
    sta $fd
    jsr laskeArvot

    ; Jos tämä oli rivi 24. rivi, päivitetään peittomittari
    lda $c024
    cmp #$23
    bne paivitaPeittoSeuraavaRivi

    ; Tässä päivitetään peittomittaria
    ; Jaetaan aluksi kahdeksalla niin ollaan verrannollisia lumimerkkien määrän kanssa
    clc
    ror $c021
    ror $c020
    clc
    ror $c021
    ror $c020
    clc
    ror $c021
    ror $c020
    ; Jaetaan vielä kahdella niin mahtuu yhteen tavuun 
    ;  ja on verrannollinen edistymispalkin pykälien kanssa
    clc
    ror $c021
    ror $c020
    
    ; Käydään läpi pykälät ja muutetaan merkin väri
    lda #$28    ; Pykälät osoitteessa $c028-$c02f
    sta $fb
    lda #$c0
    sta $fc
    lda #$3e    ; Palkin eka väri osoittessa $5f3e
    sta $fd
    lda #$5f
    sta $fe
    ldy #$00    ; Loopin alku
paivitaPeittoPalkinpykälät
    lda $c020
    cmp ($fb),y
    bcc paivitaPeittoAloitetaanAlusta   ; Lopeta, jos harmaita on vähemmän kuin tämä pykälä
    lda #$75                            ; Värjää merkki. 
    sta ($fd),y
    iny
    cpy #$02 ;#$08
    bne paivitaPeittoPalkinpykälät      ; Seuraava, jos palkki ei ole täynnä
    jmp kentanLoppuValmis               ; Tässä kenttä loppuisi    
    
paivitaPeittoAloitetaanAlusta
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