uusiKentta

    ; Kentän taustan ruskeat pisteet värimuistista
    lda #$48 ; $6148 grafiikkamuistin 2. rivi ja 2. sarake
    sta $fb
    lda #$61
    sta $fc
    ldy #$00
    ldx #$00
uusiKenttaKentantaustaloop
    inx ; Joka toinen grafiikkarivi musta, joka toinen #$cc
    txa
    and #$01
    beq uusiKenttaVariruskea
    lda #$00
    jmp uusiKenttaKentantaustaloopsisin
uusiKenttaVariruskea
    lda #$cc
uusiKenttaKentantaustaloopsisin
    sta ($fb),y
    iny
    cpy #$d8
    bne uusiKenttaKentantaustaloop
    ldy #$00
    lda $fb
    clc
    adc #$40
    sta $fb
    lda $fc
    adc #$01
    sta $fc
    cmp #$7e ; Pysähdy toiseksi viimeiselle riville osoitteeseen $7e08
    bne uusiKenttaKentantaustaloop

; Värimuistin arvot kentän taustalle ruskeiksi
    lda #$29 ; $d829 värimuistin 2. rivi ja 2. sarake
    sta $fb
    lda #$d8
    sta $fc
    ldy #$00
uusiKenttaKentantaustavarimuistiloop
    lda #$f0
    and ($fb),y
    ora #$09 ; ruskea
    sta ($fb),y
    iny
    cpy #$1c
    bne uusiKenttaKentantaustavarimuistiloop
    ldy #$00
    lda $fb
    clc
    adc #$28
    sta $fb
    lda $fc
    adc #$00
    sta $fc    
    cmp #$db ; Pysähdy toiseksi viimeiselle riville osoitteeseen $dbc1
    bne uusiKenttaKentantaustavarimuistiloop
    lda $fb
    cmp #$c1 ; Pysähdy toiseksi viimeiselle riville osoitteeseen $dbc1
    bne uusiKenttaKentantaustavarimuistiloop

    lda #$86    ; Spritejen 0-4 x-sijainnit ruudulle
    sta $D000
    sta $D002
    sta $D004
    sta $D006
    sta $D008
    lda #$00    ; Ylimmät x-bitit nolliksi
    sta $D010
    lda #$83    ; Spritejen 0-4 y-sijainnit ruudulle
    sta $D001
    sta $D003
    sta $D005
    sta $D007
    sta $D009
    
    lda #$1f    ; Spritet 0-4 päälle, muut pois
    sta $D015

    ; Spritejen 0-4 pointterit
    lda #$03    ; Kasvot
    sta $5FF8
    lda #$01    ; Pipa
    sta $5FF9
    lda #$00    ; Takki
    sta $5FFA
    lda #$02    ; Vasen jalka
    sta $5FFB
    lda #$05    ; Oikae jalka
    sta $5FFC
    
    ; Kentän numero ruudulle
    lda #$11    ; Numeroiden ylätavu
    sta $fc
    lda $c025   ; Onko kentän numero vähintään 10?
    cmp #$0a
    bcc uusiKenttaNumeroAlleKymmenen    ; Kentän numero alle kymmenen, piirrä 0
    lda #$88    ; Kenttä vähintään kymmenen, piirrä 1
    sta $fb    
    lda $c025   ; Vähennä 10, jotta saadaan toinen numero
    sec
    sbc #$0a
    sta $fd
    jmp uusiKenttaNumeroKopioiYlempi
uusiKenttaNumeroAlleKymmenen
    lda #$80
    sta $fb
    lda $c025   ; Tallenna kentän numero sellaisenaan
    sta $fd
uusiKenttaNumeroKopioiYlempi
    ldy #$07    ; Kopioidaan numero
    uusiKenttaNumeroLoop
    lda ($fb),Y
    sta $7668,y
    dey
    bne uusiKenttaNumeroLoop
    
    lda $fd     ; Kerrotaan kentän numeroa kahdeksalla niin saadaan oikean numeron grafiikan alkuosoite
    asl
    asl
    asl
    clc
    adc #$80
    sta $fb
    ldy #$07    ; Kopioidaan numero
uusiKenttaNumeroLoopAlempi
    lda ($fb),Y
    sta $7670,y
    dey
    bne uusiKenttaNumeroLoopAlempi

    nop
    rts