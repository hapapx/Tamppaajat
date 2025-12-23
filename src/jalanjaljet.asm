jalanjaljet

    ; Määritetään tarkkuusgrafiikan merkki, johon jalanjälki piirretään
    ; Jalan sijainti        x = $d008 ja y = $d009
    ; Grafiikan alku        $6000
    ; Näyttömuistin alku    $5c00    

    ; Lisätään jälki kahteen vierekkäiseen merkkiin
    ; Muistin $c0002 yli tavu kertoo, onko ensimmäinen (0) vai toinen (1) merkki
    lda #$00
    sta $c002

jalanjaljetAlku    
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
    jmp jalanjaljetKorjaus2   ; Joku muu suunta
jalanjaljetKorjausPysty
    clc         ; Hienosäätö x-koordinaattiin
    lda $c000
    adc #$0c
    sta $c000
    clc         ; Hienosäätö y-koordinaattiin
    lda $c001
    adc #$00
    sta $c001
    lda #$80    ; Merkin osoite sivulle $fd-$fe
    sta $fd
    lda #$10
    sta $fe
    jmp jalanjaljetPäälooppi

jalanjaljetKorjaus2
    cpx #$0A    ; Liike ylös tai alas
    beq jalanjaljetKorjausVaaka
    jmp jalanjaljetKorjaus3   ; Joku muu suunta
jalanjaljetKorjausVaaka
    clc         ; Hienosäätö x-koordinaattiin
    lda $c000
    adc #$0e
    sta $c000
    clc         ; Hienosäätö y-koordinaattiin
    lda $c001
    adc #$07
    sta $c001
    lda #$90    ; Merkin osoite sivulle $fd-$fe
    sta $fd
    lda #$10
    sta $fe
    jmp jalanjaljetPäälooppi

jalanjaljetKorjaus3
    cpx #$0f    ; Liike koillinen tai lounas
    beq jalanjaljetKorjausKoillisLounas
    jmp jalanjaljetKorjaus4   ; Joku muu suunta
jalanjaljetKorjausKoillisLounas
    clc         ; Hienosäätö x-koordinaattiin
    lda $c000
    adc #$00
    sta $c000
    clc         ; Hienosäätö y-koordinaattiin
    lda $c001
    adc #$00
    sta $c001
    lda #$a0    ; Merkin osoite sivulle $fd-$fe
    sta $fd
    lda #$10
    sta $fe
    jmp jalanjaljetPäälooppi

jalanjaljetKorjaus4
    cpx #$14    ; Liike kaakko tai lounas
    beq jalanjaljetKorjausKaakkoLuode
    jmp jalanjaljetPoistu   ; Vielä määrittämätön jalka
jalanjaljetKorjausKaakkoLuode
    clc         ; Hienosäätö x-koordinaattiin
    lda $c000
    adc #$03
    sta $c000
    clc         ; Hienosäätö y-koordinaattiin
    lda $c001
    adc #$0a
    sta $c001
    lda #$b0    ; Merkin osoite sivulle $fd-$fe
    sta $fd
    lda #$10
    sta $fe
    jmp jalanjaljetPäälooppi

jalanjaljetPäälooppi
    ; Jos toinen kierros, siirrytään yksi merkki oikealle
    lda $c002
    and #$80
    beq jalanjaljetToinenMerkki
    lda $c000
    clc
    adc #$08
    sta $c000
jalanjaljetToinenMerkki

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
    ; tässä ja alhaalla
    ; Käytetään osoitteen $c0002 neljää alinta bittiä tämän muistamiseen    
    lda $c002        ; Alustetaan muistin $c002 alimamt tavut
    ora #$0f
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
    and #$fe
    sta $c002
jalanjaljetOnkoLunta1
    ldy #$28        ; Onko alhaalla lunta?
    lda ($fb),y
    cmp #$f1
    bcs jalanjaljetOnkoLunta3
    lda $c002        ; Alhaalla ei lunta
    and #$fb
    sta $c002
jalanjaljetOnkoLunta3

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

    ; Ensimmäisellä kierroksella siirretään bittejä oikealle tarkan x-koordinaatin jakojäännöksen verran
    ; Kopioidaan jalanjäljen OR- ja AND-merkit osoitteeseen $c010-$c01f muokattavaksi
    lda #$10    ; Kirjoitus sivun $02-$03 kautta
    sta $02
    lda #$c0
    sta $03
    ldy #15    ; y looppaa 16 tavun verran
jalanjaljetMerkinKopiointiLoop

    lda $c000   ; Siirtojen määrä x:ään
    and #$07
    lsr         ; Kaksi siirtoa joka kerta, siksi tässä jaetaan kahdella
    tax

    ; Jos toinen kierros, siirretään bittejä vasemmalle
    lda $c002
    and #$80
    beq jalanjaljetMerkinSiirtoOikealleLoopAlku
    jmp jalanjaljetMerkinSiirtoVasemmalleLoopAlku

    ; Jos ensimmäinen kierros, siirretään bittejä oikealle
jalanjaljetMerkinSiirtoOikealleLoopAlku
    lda ($fd),y ; Ladataan alkuperäinen merkki
jalanjaljetMerkinSiirtoOikealleLoop
    dex
    bmi jalanjaljetMerkinKopiointiLoopSeuraavaTavu    ; Seuraavaan tavuun
    lsr
    lsr    
    cpy #$08    ; Jos y>=8, kyseessä AND ja pitää lisätä 11 vasemmalle
    bcc jalanjaljetMerkinSiirtoOikealleLoop ; Kyseessä OR-merkki
    ora #$c0
    jmp jalanjaljetMerkinSiirtoOikealleLoop

    ; Jos toinen kierros, siirretään bittejä vasemmalle    
jalanjaljetMerkinSiirtoVasemmalleLoopAlku
    stx $c004   ; Vasemmalle siirtomäärä on 4 miinus siirtomäärä oikealle
    lda #$04
    sec
    sbc $c004
    tax    
    lda ($fd),y ; Ladataan alkuperäinen merkki    
jalanjaljetMerkinSiirtoVasemmalleLoop
    ;jsr jalanjaljetKerto7b ; DEBUG
    dex
    bmi jalanjaljetMerkinKopiointiLoopSeuraavaTavu    ; Seuraavaan tavuun
    asl
    asl    
    cpy #$08    ; Jos y>=8, kyseessä AND ja pitää lisätä bitit 11 oikealle
    bcc jalanjaljetMerkinSiirtoVasemmalleLoop ; Kyseessä OR-merkki
    ora #$03
    jmp jalanjaljetMerkinSiirtoVasemmalleLoop

jalanjaljetMerkinKopiointiLoopSeuraavaTavu
    sta ($02),y  ; Tallennetaan muokattu
    dey
    bpl jalanjaljetMerkinKopiointiLoop

jalanjaljetORAND    
    lda #$01    ; Aluksi verrataan tämän merkin lumitilanteeseen
    sta $c003
    ; Ensin OR jalanjäljen kanssa. Merkki osoitteessa $c010. Nollasivu $fd-$fe
    ; Sitten AND. Merkki osoitteessa $c018. Nollasivu $02-$03
    lda #$10    ; OR varten
    sta $fd
    lda #$c0
    sta $fe
    lda #$18    ; AND varten
    sta $02
    lda #$c0
    sta $03
    ldy #$00    ; y looppaa merkin 8 rivin yli
jalanjaljetKerto7
    ; Jos lunta tässä, muokataan merkkiä
    lda $c002
    and $c003
    beq jalanjaljetKerto7a ; Tässä ei lunta    
    lda ($fb),y
    ora ($fd),y
    and ($02),y
    sta ($fb),y
jalanjaljetKerto7a
    iny                     ; Seuraava
    cpy #$08
    bcs jalanjaljetKerto7b  ; Jos kahdeksas piirto, lopetetaan
    clc                     ; Tarkistetaan tultiinko merkin loppuun
    tya
    adc $fb
    and #$07
    bne jalanjaljetKerto7   ; Merkki ei loppunut, jatketaan    
    lda #$04                ; Markki loppui. Jatkossa verrataan alapuolisen merkin lumitilanteeseen
    sta $c003    
    clc                     ; Seuraava rivi eli +39 merkkiä
    lda $fb
    adc #$38
    sta $fb
    lda $fc
    adc #$01
    sta $fc
    jmp jalanjaljetKerto7   ; Seuraava

jalanjaljetKerto7b
    ; Jos tämä oli ensimmäinen  kierros, aloitetaan toinen kierros alusta
    lda $c002
    and #$80
    bne jalanjaljetPoistu
    lda #$80
    sta $c002
    jmp jalanjaljetAlku

jalanjaljetPoistu
    jmp spriteliiketesti