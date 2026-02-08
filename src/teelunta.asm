lumiSarakkeeseenXjaRiviinY2x3

    ; Aseta rivi osoitteeseen $fd
    ; Ensimmäisen rivin numero on 0
    ; Aseta sarake osoitteeseen $fe
    ; Ensimmäisen sarakkeen numero on 0

    ; Muokkaa nollasivua $fb, $fc, $fd, $fe

    ; Aseta merkin grafiikat osoitteeseen $c000-$c0007
    
    ; Screen memoryn paikka
    lda #$00 ; Alku $5c00
    sta $fb
    lda #$5c
    sta $fc

    ldx #$00
rivilaskuriSM
    lda $fb ; Lisää alkuun rivit
    clc
    adc #$28
    sta $fb
    lda $fc
    adc #$00
    sta $fc
    inx
    cpx $fd
    bne rivilaskuriSM

    lda $fb ; Lisää sarake
    clc
    adc $fe
    sta $fb
    lda $fc
    adc #$00
    sta $fc
    
    ; Osoite selvillä - kirjoitetaan värit screen memoryyn 2x3 alueelle
    ldy #$00
    lda #$f1 ; vaaleanharmaa (f) ja valkea (1)
    sta ($fb),y
    iny
    sta ($fb),y
    iny
    sta ($fb),y
    tya
    clc
    adc #$26
    tay
    lda #$f1
    sta ($fb),y
    iny
    sta ($fb),y
    iny
    sta ($fb),y

    ; Grafiikkamuistin alku $6000
    lda #$00
    sta $fb
    lda #$60
    sta $fc
    ldx #$00
rivilaskuriGM
    lda $fb ; Lisää alkuun rivit, kukin $140 = 320
    clc
    adc #$40
    sta $fb
    lda $fc
    adc #$01
    sta $fc
    inx
    cpx $fd
    bne rivilaskuriGM

    ldx #$00
sarakelaskuriGM
    lda $fb ; Lisää sarakkeet, kukin $08
    clc
    adc #$08
    sta $fb
    lda $fc
    adc #$00
    sta $fc
    inx
    cpx $fe
    bne sarakelaskuriGM

    ; Osoite selvillä
    ; Maalataan kahdeksan riviä 2x3 alueelle
    lda #$00; Luetaan grafikka osoitteesta $c000-$c007 ja laitetaan nollasivuun $fd
    sta $fd
    lda #$c0
    sta $fe
    ldy #$17
    ;lda #$5a ; Screen memory lower and upper color    
maalaaGM
    lda #$aa ;lda ($fd),y
    sta ($fb),y
    dey
    bpl maalaaGM
    lda $fb ; Lisää $140 = 320
    clc
    adc #$40
    sta $fb
    lda $fc
    adc #$01
    sta $fc
    ldy #$17
maalaaGM2
    lda #$aa ;lda ($fd),y
    sta ($fb),y
    dey
    bpl maalaaGM2

rts ; Palaa kutsujaan

; Tässä tehdään lunta useisiin merkkeihin
luntaKentalle

    ; Asetetaan näyttömuisti ensin vihreäksi, jotta erotetaan missä on lunta
    ; Rivit 2-24, sarakkeet 2-28
    lda #$00 ; Näyttömuisti $5c00 - $5fe7    
    sta $fb
    lda #$5c
    sta $fc
vihreanayttoloopUlko
    lda $fb ; Lisätään $28 eli rivin verran
    clc
    adc #$28
    sta $fb
    lda $fc
    adc #$00
    sta $fc
    ldy #$1b ; Loopin alkuasetukset
    lda #$5d ; Molemmat vihreät
vihreanayttoloop ; Loopataan tämä rivi
    sta ($fb),y
    dey
    bne vihreanayttoloop
    ; Tarkistetaan onko viimeinen rivi
    lda $fc
    cmp #$5f
    bne vihreanayttoloopUlko
    lda $fb
    cmp #$98
    bne vihreanayttoloopUlko

    ; Aseta grafiikat osoitteeseen $c000
    lda #$00
    sta $fb
    lda #$c0
    sta $fc
    ldy #$07
    lda #$aa
grafiikkaarvoluuppi    
    sta ($fb),y
    dey
    bpl grafiikkaarvoluuppi

; Luo lunta kentän numero × $10 kpl, osa voi olla samoissa kohdissa
    lda $c025
    asl
    asl
    asl
    asl
    sta $c00a
lumenluontiluuppi
    ; Arvotaan rivejä
    ; Lisätään satunnaislukuja x kpl, jotta saadaan lähes normaalijakauma
    lda #$00
    sta $c008
    sta $c009
    ldx #$10    ; kpl rivikomponentteja
normluuppiR
    lda $d012   ; Satunnaisluku
    eor $dc04
    clc
    adc $c009
    sta $c009
    lda $c008
    adc #$00
    sta $c008
    dex
    bpl normluuppiR
    lda $c008   ; Tallenna rivin numeroksi
    asl         ; Kerro neljällä
    asl
    sta $c008
    lda #$03    ; Lisää ehkä 0-3
    and $dc04
    ora $c008
    clc         ; Siirrä keskemmälle
    sbc #$15
    ; Tarkistetaan, että on välillä $02-$15 eli 2-21
    cmp #$02
    bcs alarajaokR
    lda #$02
alarajaokR
    cmp #$15
    bcc ylarajaokR
    lda #$15
ylarajaokR
    sta $fd ; Tallenna rivin numeroksi

    jmp sarakearvonta

sarakearvonta
    ; Arvotaan sarakkeita
    ; Lisätään satunnaislukuja x kpl
    lda #$00
    sta $c008
    sta $c009
    ldx #$13 ; kpl sarakearvontakierrosta
normluuppiS
    lda $d012
    eor $dc04    
    clc
    adc $c009
    sta $c009
    lda $c008
    adc #$00
    sta $c008
    dex
    bpl normluuppiS
    lda $c008
    asl ; Kerro neljällä
    asl
    sta $c008
    lda #$03 ; Lisää ehkä 0-3
    and $dc04
    ora $c008
    clc ; Siirrä keskemmälle
    sbc #$1a
    sta $c008
    ; Tarkistetaan, että on välillä $02-$18 eli 2-24
    cmp #$02
    bcs alarajaokS
    lda #$02
alarajaokS
    cmp #$18
    bcc ylarajaokS
    lda #$18
ylarajaokS
    sta $fe  ; Tallenna sarakkeen numeroksi
    jsr lumiSarakkeeseenXjaRiviinY2x3

    ldy $c00a
    dey
    sty $c00a
    beq lumenluontiluuppiOhi
    jmp lumenluontiluuppi

; --------------------------------------------------------
; Laitellaan lunta nätimmäksi
; --------------------------------------------------------

lumenluontiluuppiOhi
; Loopataan näyttömuistin ($5c00-) kenttäalueen läpi
; $c000 ja $c001 pitävät kirjaa missä mennään
    lda #$28; Alkuna toinen rivi
    sta $c000
    lda #$5c
    sta $c001

lumenhiontarivilooppi

    ldy #$02 ; Aloitetaan kolmannesta sarakkeesta

lumenhiontasarakelooppi

    lda $c000 ; Palauta sijainti kun $fb-$fc voi olla muokattu
    sta $fb
    lda $c001
    sta $fc
    
    jmp lumenhiontayläreuna

seuraavasijainti
    iny
    cpy #$1b
    bne lumenhiontasarakelooppi

    lda $c000   ; Seuraava rivi?
    clc
    adc #$28
    sta $c000
    lda $c001
    adc #$00
    sta $c001
    cmp #$5f
    bne lumenhiontarivilooppi
    lda $c000
    cmp #$c0
    bne lumenhiontarivilooppi

    jmp kivetJaKasvit
    
; -----------
; Tasaisen yläreunan tarkistus ja hionta
; Huom. ($fb),y osoittaa seuraavaan merkkiin. Y:tä ei saa muokata
lumenhiontayläreunapaluu
    ldy $c002   ; Palauta y
    lda $c000   ; Palauta sijainti kun $fb-$fc voi olla muokattu
    sta $fb
    lda $c001
    sta $fc
    jmp lumenhiontaalareuna
lumenhiontayläreuna
; Jos tässä tyhjä ja alapuolella lunta, hiotaan yläreunaa
    sty $c002   ; Tallenna y
    lda ($fb),y ; Tämä merkki
    cmp #$5d    ; Tausta
    bne lumenhiontayläreunapaluu
    tya         ; Alapuolella
    clc
    adc #$28
    tay
    lda ($fb),y
    cmp #$f1    ; Lunta
    bne lumenhiontayläreunapaluu
    ; ----------- Kaikki oikein -> kaunista yläreuna -------------
    ; Lasketaan mistä tämän grafiikka alkaa = 8 × merkin sijainti (suhteessa alkuun)    
    lda $fc     ; Vähennetään alkuosoite $5c00
    sec
    sbc #$5c 
    sta $fc
    tya         ; Lisätään y
    clc
    adc $fb
    sta $fb
    lda $fc
    adc #$00
    sta $fc
    jsr kahdeksankerto
    lda $fc     ; Lisätään grafiikan alku $6000
    clc
    adc #$60
    sta $fc
    ; Muokataan yläreunaa
    ; Laitetaan yksi neljästä vaihtoehdosta osoitteessa 
    lda $d012   ; Satunnaisluku
    eor $dc04
    and #$03    ; Neljä vaihtoehtoa
    asl
    asl         ; × 4
    sta $fd     ; Lukupaikka osoitteeseen $fd/$fe
    lda #$10
    sta $fe
    ldy #$03
lumenhiontayläreunarivit
    lda ($fd),y
    sta ($fb),y
    dey
    bpl lumenhiontayläreunarivit

    ldy $c002  ; Palauta y
    jmp lumenhiontaalareuna ; Valmista
    
kahdeksankerto ; Kerrotaan $fb-fc kahdeksealla

    ldx #$03 ; Kerrotaan kolmesti kahdella
kahdeksankertoluup
    lda $fc ; × 2
    asl
    sta $fc
    lda $fb ; × 2
    asl     
    sta $fb
    lda $fc ; Lisää mahdollisesti ylivuotanut bitti
    adc #$00
    sta $fc
    dex
    bne kahdeksankertoluup
    rts

; -----------
; Tasaisen alareunan tarkistus ja hionta
; Huom. ($fb),y osoittaa seuraavaan merkkiin. Y:tä ei saa muokata
lumenhiontaalareunapaluu
    ldy $c002   ; Palauta y
    lda $c000   ; Palauta sijainti kun $fb-$fc voi olla muokattu
    sta $fb
    lda $c001
    sta $fc
    jmp lumenhiontavasenreuna
lumenhiontaalareuna
; Jos tässä lunta ja apuolella tyhjää, hiotaan alareunaa
    sty $c002   ; Tallenna y
    lda ($fb),y ; Tämä merkki
    cmp #$f1    ; Lunta
    bne lumenhiontaalareunapaluu
    lda $fb     ; Alempi rivi, keskellä
    clc
    adc #$28
    sta $fb
    lda $fc
    adc #$00
    sta $fc
    lda ($fb),y
    cmp #$5d    ; Tausta
    bne lumenhiontaalareunapaluu
    ; ----------- Kaikki oikein -> kaunista alareuna -------------
    ; Lasketaan mistä tämän grafiikka alkaa = 8 × merkin sijainti (suhteessa alkuun)    
    lda $fc     ; Vähennetään alkuosoite $5c00
    sec
    sbc #$5c 
    sta $fc
    tya         ; Lisätään y
    clc
    adc $fb
    sta $fb
    lda $fc
    adc #$00
    sta $fc
    jsr kahdeksankerto
    lda $fb     ; Lisätään grafiikan alku $6000 miinus neljä pikseliriviä ja yksi merkkirivi = $5ec4
    clc
    adc #$c4
    sta $fb
    lda $fc
    adc #$5e
    sta $fc
    ; Muokataan alareunaa
    ; Laitetaan yksi neljästä vaihtoehdosta osoitteessa 
    lda $d012   ; Satunnaisluku
    eor $dc04
    and #$03    ; Neljä vaihtoehtoa
    asl
    asl         ; × 4
    sta $fd     ; Lukupaikka osoitteeseen $fd/$fe
    lda #$10
    sta $fe
    ; Loopataan käsin koska pitää saada ylösalaisin
    ldy #$00    ; 0 ja 3
    lda ($fd),y
    ldy #$03
    sta ($fb),y
    ldy #$01    ; 1 ja 2
    lda ($fd),y
    ldy #$02
    sta ($fb),y
    ldy #$02    ; 2 ja 1
    lda ($fd),y
    ldy #$01
    sta ($fb),y
    ldy #$03    ; 3 ja 0#
    lda ($fd),y
    ldy #$00
    sta ($fb),y
    jmp lumenhiontaalareunapaluu ; Valmista

; -----------
; Tasaisen vasemman reunan tarkistus ja hionta
lumenhiontavasenreunapaluu
    ldy $c002   ; Palauta y
    lda $c000   ; Palauta sijainti kun $fb-$fc voi olla muokattu
    sta $fb
    lda $c001
    sta $fc
    jmp lumenhiontaoikeareuna

; Huom. ($fb),y osoittaa seuraavaan merkkiin. Y:tä ei saa muokata
lumenhiontavasenreuna
; Jos alla lunta ja alavasemmalla taustaa, hio vasenta reunaa
    sty $c002   ; Ota y talteen
    tya         ; Alla lunta?
    clc
    adc #$28
    tay    
    lda ($fb),y 
    cmp #$f1
    bne lumenhiontavasenreunapaluu
    dey         ; Alavasemmalla taustaa
    lda ($fb),y
    cmp #$5d
    bne lumenhiontavasenreunapaluu
    ; ----------- Kaikki oikein -> kaunista vasen reuna -------------
    lda #$29   ; Muokattavan merkin y
    clc
    adc $c002  ; Täällä alkuperäinen y tallessa
    tay
    ; Lasketaan mistä tämän grafiikka alkaa = 8 × merkin sijainti (suhteessa alkuun)
    lda $fc     ; Vähennetään alkuosoite $5c00
    sec
    sbc #$5c 
    sta $fc
    tya         ; Lisätään y
    clc
    adc $fb
    sta $fb
    lda $fc
    adc #$00
    sta $fc
    jsr kahdeksankerto
    lda $fb     ; Lisätään grafiikan alku $6000 miinus yksi merkki = $5ff8    
    clc
    adc #$f8
    sta $fb
    lda $fc
    adc #$5f
    sta $fc
    ; Muokataan vasenta reunaa
    ; Laitetaan yksi kahdesta vaihtoehdosta osoitteessa $1010
    lda $d012   ; Satunnaisluku
    eor $dc04
    and #$01    ; Kaksi vaihtoehtoa
    asl
    asl
    asl         ; × 8 (riviä per merkki)
    clc
    adc #$10
    sta $fd     ; Lukupaikka osoitteeseen $fd/$fe
    lda #$10
    sta $fe
    ldy #$07
lumenhiontavasenreunarivit
    lda ($fd),y
    sta ($fb),y
    dey
    bpl lumenhiontavasenreunarivit

    ldy $c002  ; Palauta y
    jmp lumenhiontavasenreunapaluu ; Valmista

; -----------
; Tasaisen oikean reunan tarkistus ja hionta
lumenhiontaoikeareunapaluu
    ldy $c002   ; Palauta y
    lda $c000   ; Palauta sijainti kun $fb-$fc voi olla muokattu
    sta $fb
    lda $c001
    sta $fc
    jmp lumenhiontaOikeaYlakulma

; Huom. ($fb),y osoittaa seuraavaan merkkiin. Y:tä ei saa muokata
lumenhiontaoikeareuna
; Jos alla lunta ja oikealla taustaa, hio oikeaa reunaa
    sty $c002   ; Ota y talteen
    tya
    clc
    adc #$28
    tay
    lda ($fb),y ; Alla lunta?
    cmp #$f1
    bne lumenhiontaoikeareunapaluu
    iny         ; Alaoikealla taustaa?
    lda ($fb),y
    cmp #$5d
    bne lumenhiontaoikeareunapaluu
    ; ----------- Kaikki oikein -> kaunista oikea reuna -------------
    lda #$29   ; Muokattavan merkin y
    clc
    adc $c002  ; Täällä alkuperäinen y tallessa
    tay
    ; Lasketaan mistä tämän grafiikka alkaa = 8 × merkin sijainti (suhteessa alkuun)
    lda $fc     ; Vähennetään alkuosoite $5c00
    sec
    sbc #$5c 
    sta $fc
    tya         ; Lisätään y
    clc
    adc $fb
    sta $fb
    lda $fc
    adc #$00
    sta $fc
    jsr kahdeksankerto
    lda $fb     ; Lisätään grafiikan alku $6000 miinus yksi merkki = $5ff8    
    clc
    adc #$f8
    sta $fb
    lda $fc
    adc #$5f
    sta $fc
    ; Muokataan oikeaa reunaa
    ; Laitetaan yksi kahdesta vaihtoehdosta osoitteessa $1020
    lda $d012   ; Satunnaisluku
    eor $dc04
    and #$01    ; Kaksi vaihtoehtoa
    asl
    asl
    asl         ; × 8 (riviä per merkki)
    clc
    adc #$20
    sta $fd     ; Lukupaikka osoitteeseen $fd/$fe
    lda #$10
    sta $fe
    ldy #$07
lumenhiontaoikeareunarivit
    lda ($fd),y
    sta ($fb),y
    dey
    bpl lumenhiontaoikeareunarivit

    ldy $c002  ; Palauta y
    jmp lumenhiontaoikeareunapaluu ; Valmista

; -----------
; Oikean yläkulman tarkistus ja hionta
lumenhiontaOikeaYlakulmaPaluu
    ldy $c002   ; Palauta y
    lda $c000   ; Palauta sijainti kun $fb-$fc voi olla muokattu
    sta $fb
    lda $c001
    sta $fc
    jmp lumenhiontaVasenYlakulma
lumenhiontaOikeaYlakulma
; Jos tässä taustaa, alhaalla lunta ja alaoikealla taustaa, hio oikea yläkulma
    sty $c002   ; Ota y talteen
    lda ($fb),y ; Tämä merkki taustaa?
    cmp #$5d
    bne lumenhiontaOikeaYlakulmaPaluu
    tya         ; Merkki alhaalla lunta?
    clc
    adc #$28
    tay
    lda ($fb),y
    cmp #$f1
    bne lumenhiontaOikeaYlakulmaPaluu
    iny         ; Merkki alaoikealla taustaa?
    lda ($fb),y
    cmp #$5d
    bne lumenhiontaOikeaYlakulmaPaluu
    ; ----------- Kaikki oikein -> kaunista oikea reuna -------------
    lda #$29   ; Muokattavan merkin y
    clc
    adc $c002  ; Täällä alkuperäinen y tallessa
    tay
    ; Lasketaan mistä tämän grafiikka alkaa = 8 × merkin sijainti (suhteessa alkuun)
    lda $fc     ; Vähennetään alkuosoite $5c00
    sec
    sbc #$5c 
    sta $fc
    tya         ; Lisätään y
    clc
    adc $fb
    sta $fb
    lda $fc
    adc #$00
    sta $fc
    jsr kahdeksankerto
    lda $fb     ; Lisätään grafiikan alku $6000 miinus yksi merkki = $5ff8    
    clc
    adc #$f8
    sta $fb
    lda $fc
    adc #$5f
    sta $fc
    ; Muokataan oikeaa reunaa
    ; Laitetaan yksi kahdesta vaihtoehdosta
    lda $d012   ; Satunnaisluku
    eor $dc04
    and #$01    ; Kaksi vaihtoehtoa
    asl
    asl
    asl         ; × 8 (riviä per merkki)
    clc
    adc #$30    ; Osoitteessa $1030
    sta $fd     ; Lukupaikka osoitteeseen $fd/$fe
    lda #$10
    sta $fe
    ldy #$07
lumenhiontaOikeaYlakulmarivit
    lda ($fd),y
    sta ($fb),y
    dey
    bpl lumenhiontaOikeaYlakulmarivit

    ldy $c002  ; Palauta y
    jmp lumenhiontaOikeaYlakulmaPaluu ; Valmista
; -----------
; Vasemman yläkulman tarkistus ja hionta
lumenhiontaVasenYlakulmaPaluu
    ldy $c002   ; Palauta y
    lda $c000   ; Palauta sijainti kun $fb-$fc voi olla muokattu
    sta $fb
    lda $c001
    sta $fc
    jmp lumenhiontaVasenAlakulma
lumenhiontaVasenYlakulma
; Jos tässä taustaa, alhaalla lunta ja vasemmalla alhaalla taustaa, hio vasen yläkulma
    sty $c002   ; Ota y talteen
    lda ($fb),y ; Tämä merkki taustaa?
    cmp #$5d
    bne lumenhiontaVasenYlakulmaPaluu
    tya         ; Merkki vasemmalla alhaalla taustaa?
    clc
    adc #$27
    tay
    lda ($fb),y
    cmp #$5d
    bne lumenhiontaVasenYlakulmaPaluu
    iny         ; Merkki alla lunta?
    lda ($fb),y
    cmp #$f1
    bne lumenhiontaVasenYlakulmaPaluu
    ; ----------- Kaikki oikein -> kaunista oikea reuna -------------
    lda #$29   ; Muokattavan merkin y
    clc
    adc $c002  ; Täällä alkuperäinen y tallessa
    tay
    ; Lasketaan mistä tämän grafiikka alkaa = 8 × merkin sijainti (suhteessa alkuun)
    lda $fc     ; Vähennetään alkuosoite $5c00
    sec
    sbc #$5c 
    sta $fc
    tya         ; Lisätään y
    clc
    adc $fb
    sta $fb
    lda $fc
    adc #$00
    sta $fc
    jsr kahdeksankerto
    lda $fb     ; Lisätään grafiikan alku $6000 miinus yksi merkki = $5ff8    
    clc
    adc #$f8
    sta $fb
    lda $fc
    adc #$5f
    sta $fc
    ; Muokataan oikeaa reunaa
    ; Laitetaan yksi kahdesta vaihtoehdosta
    lda $d012   ; Satunnaisluku
    eor $dc04
    and #$01    ; Kaksi vaihtoehtoa
    asl
    asl
    asl         ; × 8 (riviä per merkki)
    clc
    adc #$40    ; Osoitteessa $1040
    sta $fd     ; Lukupaikka osoitteeseen $fd/$fe
    lda #$10
    sta $fe
    ldy #$07
lumenhiontaVasenYlakulmarivit
    lda ($fd),y
    sta ($fb),y
    dey
    bpl lumenhiontaVasenYlakulmarivit

    ldy $c002  ; Palauta y
    jmp lumenhiontaVasenYlakulmaPaluu ; Valmista
; -----------
; Vasemman alakulman tarkistus ja hionta
lumenhiontaVasenAlakulmaPaluu
    ldy $c002   ; Palauta y
    lda $c000   ; Palauta sijainti kun $fb-$fc voi olla muokattu
    sta $fb
    lda $c001
    sta $fc
    jmp lumenhiontaOikeaAlakulma
lumenhiontaVasenAlakulma
; Jos tässä lunta, vasemmalla taustaa ja alhaalla taustaa, hio vasen alakulma
    sty $c002   ; Ota y talteen
    lda ($fb),y ; Tämä merkki lunta?
    cmp #$f1
    bne lumenhiontaVasenAlakulmaPaluu
    dey         ; Vasemmalla taustaa?
    lda ($fb),y
    cmp #$5d
    bne lumenhiontaVasenAlakulmaPaluu
    tya         ; Alhaalla taustaa?
    clc
    adc #$29
    tay
    lda ($fb),y
    cmp #$5d
    bne lumenhiontaVasenAlakulmaPaluu
    ; ----------- Kaikki oikein -> kaunista vasen alakulma  -------------
    lda #$01   ; Muokattavan merkin y
    clc
    adc $c002  ; Täällä alkuperäinen y tallessa
    tay
    ; Lasketaan mistä tämän grafiikka alkaa = 8 × merkin sijainti (suhteessa alkuun)
    lda $fc     ; Vähennetään alkuosoite $5c00
    sec
    sbc #$5c 
    sta $fc
    tya         ; Lisätään y
    clc
    adc $fb
    sta $fb
    lda $fc
    adc #$00
    sta $fc
    jsr kahdeksankerto
    lda $fb     ; Lisätään grafiikan alku $6000 miinus yksi merkki = $5ff8    
    clc
    adc #$f8
    sta $fb
    lda $fc
    adc #$5f
    sta $fc
    ; Muokataan oikeaa reunaa
    ; Laitetaan yksi kahdesta vaihtoehdosta
    lda $d012   ; Satunnaisluku
    eor $dc04
    and #$01    ; Kaksi vaihtoehtoa
    asl
    asl
    asl         ; × 8 (riviä per merkki)
    clc
    adc #$50    ; Osoitteessa $1050
    sta $fd     ; Lukupaikka osoitteeseen $fd/$fe
    lda #$10
    sta $fe
    ldy #$07
lumenhiontaVasenAlakulmarivit
    lda ($fd),y
    sta ($fb),y
    dey
    bpl lumenhiontaVasenAlakulmarivit

    ldy $c002  ; Palauta y
    jmp lumenhiontaVasenAlakulmaPaluu ; Valmista
; -----------
; Oikean alakulman tarkistus ja hionta
lumenhiontaOikeaAlakulmaPaluu
    ldy $c002   ; Palauta y
    lda $c000   ; Palauta sijainti kun $fb-$fc voi olla muokattu
    sta $fb
    lda $c001
    sta $fc
    jmp seuraavasijainti
lumenhiontaOikeaAlakulma
; Jos tässä lunta, oikealla taustaa ja alhaalla on taustaa, hio oikea alakulma
    sty $c002   ; Ota y talteen
    lda ($fb),y ; Tämä merkki lunta?
    cmp #$f1
    bne lumenhiontaOikeaAlakulmaPaluu
    iny         ; Merkki oikealla taustaa?
    lda ($fb),y
    cmp #$5d
    bne lumenhiontaOikeaAlakulmaPaluu
    tya         ; Alhaalla taustaa?
    clc
    adc #$27
    tay
    lda ($fb),y
    cmp #$5d
    bne lumenhiontaOikeaAlakulmaPaluu
    ; ----------- Kaikki oikein -> kaunista vasen alakulma  -------------
    lda #$01   ; Muokattavan merkin y
    clc
    adc $c002  ; Täällä alkuperäinen y tallessa
    tay
    ; Lasketaan mistä tämän grafiikka alkaa = 8 × merkin sijainti (suhteessa alkuun)
    lda $fc     ; Vähennetään alkuosoite $5c00
    sec
    sbc #$5c 
    sta $fc
    tya         ; Lisätään y
    clc
    adc $fb
    sta $fb
    lda $fc
    adc #$00
    sta $fc
    jsr kahdeksankerto
    lda $fb     ; Lisätään grafiikan alku $6000 miinus yksi merkki = $5ff8    
    clc
    adc #$f8
    sta $fb
    lda $fc
    adc #$5f
    sta $fc
    ; Muokataan oikeaa reunaa
    ; Laitetaan yksi kahdesta vaihtoehdosta
    lda $d012   ; Satunnaisluku
    eor $dc04
    and #$01    ; Kaksi vaihtoehtoa
    asl
    asl
    asl         ; × 8 (riviä per merkki)
    clc
    adc #$60    ; Osoitteessa $1060
    sta $fd     ; Lukupaikka osoitteeseen $fd/$fe
    lda #$10
    sta $fe
    ldy #$07
lumenhiontaOikeaAlakulmarivit
    lda ($fd),y
    sta ($fb),y
    dey
    bpl lumenhiontaOikeaAlakulmarivit

    ldy $c002  ; Palauta y
    jmp lumenhiontaOikeaAlakulmaPaluu ; Valmista
; 
; Koristellaan vielä kasveilla, kivillä yms.
kivetJaKasvit
    ldx #$f0    ; Kasvien ja kivien  lukumäärä
    ; Arvotaan luku väliltä 0-$0398 (merkkien määrä ruudulla, ei eka eikä vika rivi)
kivetJaKasvitArvonta
    lda $d012   ; Ylempi tavu, 0-3
    eor $dc04
    and #$03    
    sta $fc
    lda $d012   ; Alempi tavu, 0-$ff
    eor $dc04
    sta $fb
    ; Tarkista yläraja $0398
    lda $fc
    cmp #$03
    bne kivetJaKasvitArvontaJatko
    lda $fb
    cmp #$98
    bcs kivetJaKasvitArvonta ; Liian iso, arvo uusi
    jmp kivetJaKasvitArvontaJatko
kivetJaKasvitArvontaVäliaskel
    jmp kivetJaKasvitArvonta
kivetJaKasvitArvontaJatko
    ; Tarkista onko merkki taustaa
    ; Pidetään alkuperäinen arvo tallessa $fb:ssä ja käytetään nollasivua $fd-$fe
    lda $fb
    clc
    adc #$28    ; Näyttömuistin toisen rivin alku on $5c28
    sta $fd
    lda $fc
    adc #$5c    ; Näyttömuistin toisen rivin alku on $5c28
    sta $fe
    ldy #$00
    lda ($fd),y
    cmp #$5d
    beq kivetJaKasvitMerkkiOk ; Tämä merkki ei taustaa, ei piirretä mitään
    jmp kivetJaKasvitSeuraavako

kivetJaKasvitMerkkiOk
    ; Neljä vaihtoehtoa
    ;   0 : Vihreä normaali
    ;   1 : Vihreä käänteiset värit
    ;   2 : Kivi normaali
    ;   3 : Kivi käänteiset värit
    ; Tallennetaan arvottu luku osoitteeseen $c000
    lda $d012
    and #$03
    sta $c000
    cmp #$00
    bne kivetJaKasvitVäri1
    lda #$d5    ; Vihreät oikeinpäin
    sta ($fd),y
    jmp kivetJaKasvitPiirto
kivetJaKasvitVäri1
    cmp #$01
    bne kivetJaKasvitVäri2
    lda #$5d    ; Vihreät käänteisesti
    sta ($fd),y
    jmp kivetJaKasvitPiirto    
kivetJaKasvitVäri2
    cmp #$02
    bne kivetJaKasvitVäri3
    lda #$bc    ; Harmaat oikeinpäin
    sta ($fd),y
    jmp kivetJaKasvitPiirto
kivetJaKasvitVäri3    
    lda #$cb    ; Harmaat käänteisesti
    sta ($fd),y    

kivetJaKasvitPiirto
    ; Lasketaan vastaava grafiikkamuistin osoite ja kopioidaan sinne kasvi
    ; Kerrotaan alkuperäinen arvo kahdeksalla ja lisätään grafiikkamuistin alku
    asl $fc     ; × 2
    asl $fb
    lda $fc
    adc #$00
    sta $fc
    asl $fc     ; × 4
    asl $fb
    lda $fc
    adc #$00
    sta $fc
    asl $fc     ; × 8
    asl $fb
    lda $fc
    adc #$00
    sta $fc
    lda $fb     ; Lisää $6140 (toisen rivin alku)
    clc
    adc #$40
    sta $fb
    lda $fc     ; Lisää $6140 (toisen rivin alku)
    adc #$61
    sta $fc

    ; Vihreän alku muistissa joko $1070 tai $1078
    ; Kiven alku muistissa joko $10c0 tai $10c8
    lda #$10    
    sta $fe
    lda $c000
    cmp #$02
    bcc kivetJaKasvitVihreänOsoite  ; Jos pienempi kuin 2, kyseessä vihreää
    ; Kyseessä kivi
    lda #$c0
    sta $fd
    lda $d012
    and #$01
    bne kivetJaKasvitGrafLoopUlko
    lda #$c8    ; Toinen kivi
    sta $fd
    jmp kivetJaKasvitGrafLoopUlko

kivetJaKasvitVihreänOsoite
    lda #$70
    sta $fd
    lda $d012
    and #$01
    bne kivetJaKasvitGrafLoopUlko
    lda #$78    ; Toinen kasvi
    sta $fd
    jmp kivetJaKasvitGrafLoopUlko

kivetJaKasvitGrafLoopUlko
    ldy #$07    ; Loopataan seitsemän bittiriviä
kivetJaKasvitGrafLoop
    lda ($fd),y
    sta ($fb),y
    dey
    bpl kivetJaKasvitGrafLoop

kivetJaKasvitSeuraavako
    dex         ; Arvotaanko vielä lisää?
    beq kivetJaKasvitLumenLaskenta
    jmp kivetJaKasvitArvontaVäliaskel
    
kivetJaKasvitLumenLaskenta

    ; Lasketaan montako lumen väristä merkkiä on pelikentällä
    lda #$f1
    sta $fd
    jsr laskeMerkit
    ; Jaetaan kahdella niin mahtuu yhteen tavuun
    clc
    ror $c021
    ror $c020
    ; Jaetaan kahdeksalla niin saadaan yhden palkin pykälän edistymistä vastaava määrä
    lsr $c020
    lsr $c020
    lsr $c020
    ; Tallennetaan palkin edistymispisteet muistipaikkoihin $c028-$c02f
    lda #$28
    sta $fb
    lda #$c0
    sta $fc
    ldy #$00
    lda #$00
teeluntaEdistymispalkinPykälät
    clc
    adc $c020
    sta ($fb),y
    iny
    cpy #$08
    bne teeluntaEdistymispalkinPykälät

    ; Nollataan laskuri
    lda #$00    ; Nollataan laskuri jalanjälkiä varten
    sta $c020
    sta $c021
    ; Aloitetaan jalanjälkien laskenta 3. riviltä
    lda #$02
    sta $c024
    
    rts; jmp spriteliiketestiAlku ; Valmista, poistu