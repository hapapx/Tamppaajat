jalanjaljet

    ; Määritetään tarkkuusgrafiikan merkki, johon jalanjälki piirretään
    ; Jalan sijainti        x = $d008 ja y = $d009
    ; Grafiikan alku        $6000
    ; Näyttömuistin alku    $5c00    

    ; Siirretään spriten sijainti  osoitteeseen $c000-$c0001 vähentäen reunukset
    lda $d008   ; x-koordinaatti
    sec
    sbc #$18
    sta $c000
    lda $d009   ; y-koordinaatti
    sec
    sbc #$32
    sta $c001

    ; Spritekohtainen hienosäätö
    ldx $5FFC   ; Oikea jalka
    cpx #$05    ; Liike oikealle tai vasemmalle
    beq jalanjaljetKorjausPysty
    jmp jalanjaljetPoistu   ; Vielä määrittämätön jalka
jalanjaljetKorjausPysty
    clc         ; Hienosäätö x-koordinaattiin
    lda $c000
    adc #$00    
    sta $c000
    clc         ; Hienosäätö y-koordinaattiin
    lda $c001
    adc #$00    
    sta $c001

    ; Lasketaan sijaintia vastaava osoite näyttömuistissa. Rivin alku saadaan 
    ;  vähentämällä ensin $32, koska vasta se on ensimmäinen näkyvä y-koordinaatti
    ;  nollaamalla kolme alinta bittiä y-koordinaatista, sillä operoimme täysillä merkeillä (0, 8, 16, ...)
    ;  ja kertomalla lopputulos luvulla 5 (oikeasti 40, mutta 8 tulee jo koordinaatista)
    lda #$00    ; Ylempi tavu ensin nollaksi
    sta $fc
    lda $c001   ; Jalan y-koordinaatti
    and #$f8    ; Nollataan alimmat bitit
    sta $fb
    asl $fb     ; = y-sijainti × 2
    rol $fc
    asl $fb     ; = y-sijainti × 4
    rol $fc
    clc
    adc $fb     ; = y-sijainti × 5 (alkuperäinen arvo oli vielä tallessa akussa)
    sta $fb
    lda $fc
    adc #$00
    sta $fc     
    
    ; Nyt osoitteessa $fb-$fc on näyttömuistin oikean rivin alku
    ; Määritetään vielä sarake jakamalla x-koordinaatti kahdeksalla hukaten alimmat bitit
    lda $c000
    lsr
    lsr
    lsr
    clc         ; Lisätään rivin alkuosoitteeseen
    adc $fb
    sta $fb
    lda $fc
    adc #$00
    sta $fc

    ; Tarkistetaan, onko näyttömuistissa lunta
    ; tässä, oikealla, alhaalla ja alaoikealla
    ; Käytetään osoitteen $c0002 neljää alinta bittiä tämän muistamiseen    
    lda #$0f        ; Alustetaan muisti $c002
    sta $c002
    lda $fc         ; Lisätään värimuistin alku osoitteen $fb-$fc
    clc
    adc #$5c
    sta $fc
    ldy #$00        ; Onko tässä lunta?
    lda ($fb),y
    cmp #$f1
    bcs jalanjaljetOnkoLunta1
    lda $c002        ; Tämä merkki ei lunta
    and #$0e
    sta $c002
jalanjaljetOnkoLunta1
    ldy #$01        ; Onko oikealla lunta?
    lda ($fb),y
    cmp #$f1
    bcs jalanjaljetOnkoLunta2
    lda $c002        ; Oikealla  ei lunta
    and #$0d
    sta $c002
jalanjaljetOnkoLunta2
    ldy #$28        ; Onko alhaalla lunta?
    lda ($fb),y
    cmp #$f1
    bcs jalanjaljetOnkoLunta3
    lda $c002        ; Alhaalla ei lunta
    and #$0b
    sta $c002
jalanjaljetOnkoLunta3
    ldy #$29        ; Onko alaoikealla lunta?
    lda ($fb),y
    cmp #$f1
    bcs jalanjaljetOnkoLunta4
    lda $c002        ; Alaoikealla  ei lunta
    and #$07
    sta $c002
jalanjaljetOnkoLunta4

    ; Tarkkuusgrafiikkan alkua varten 
    ;  vähennetään näyttömuistin alku
    ;  kerrotaan kahdeksalla
    ;  lisätään grafiikkamuistin alku
    lda $fc     ; Vähennetään näyttömuistin alku
    sec
    sbc #$5c
    sta $fc
    asl $fb     ; kerrotaan kahdeksalla
    rol $fc
    asl $fb
    rol $fc
    asl $fb
    rol $fc

    ; Lisätään grafiikan alku #$6000
    lda $fc
    clc    
    adc #$60
    sta $fc

    ; Jos lunta tässä, muokataan merkkiä
    lda $c002
    and #$01
    bne jalanjaljetTassaLunta
    jmp jalanjaljetPoistu ; Tässä ei lunta

jalanjaljetTassaLunta
    ; Lisätään alimmat bitit osoitteeseen, jotta saadaan tarkka y-koordinaatti
    clc
    lda $c001
    and #$7
    adc $fb
    sta $fb
    lda $fc
    adc #$00
    sta $fc
    ; Ensin OR jalanjäljen kanssa. Merkki osoitteessa $1080. Nollasivu $fd-$fe
    ; Sitten AND. Merkki osoitteessa $1088. Nollasivu $02-$03
    lda #$80    ; OR varten
    sta $fd
    lda #$10
    sta $fe
    lda #$88    ; AND varten
    sta $02
    lda #$10
    sta $03
    ldy #$00    ; y looppaa merkin 8 rivin yli
jalanjaljetKerto7
    lda ($fb),y
    ora ($fd),y
    and ($02),y
    sta ($fb),y
    iny                     ; Seuraava
    cpy #$08
    bcs jalanjaljetKerto7b  ; Jos kahdeksas piirto, lopetetaan
    clc                     ; Tarkistetaan tultiinko merkin loppuun
    tya
    adc $fb
    and #$07
    bne jalanjaljetKerto7   ; Merkki ei loppunut, jatketaan
    clc                     ; Merkki loppui. Onko alapuolen merkissä lunta?
    lda $c002
    and #$04
    beq jalanjaljetKerto7b  ; Alla ei lunta, lopetetaan
    clc                     ; Seuraava rivi eli +39 merkkiä
    lda $fb
    adc #$38
    sta $fb
    lda $fc
    adc #$01
    sta $fc
    jmp jalanjaljetKerto7   ; Seuraava

jalanjaljetKerto7b
    ; Sitten AND jalanjäljen kanssa. Merkki osoitteessa $1088
;   lda #$88
;   sta $fd
;   lda #$10
;   sta $fe
;   ldy #$00
jalanjaljetKerto7c
;   lda ($fb),y
;   and ($fd),y
;   sta ($fb),y
jalanjaljetKerto7d
;   iny
;   cpy #$07
;   bcc jalanjaljetKerto7c


jalanjaljetPoistu
    jmp spriteliiketesti