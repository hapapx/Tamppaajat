*=$0801          ; BASIC-ohjelman alkuosoite
!byte $0C, $08     ; seuraavan rivin osoite (low byte: $080C)
!byte $00, $00     ; rivinumero 0
!byte $9E          ; SYS-tokeni BASICissa
!pet "49168"       ; SYS 49168 ASCIIna
!byte $00          ; rivin loppu
!byte $00, $00     ; BASIC-ohjelman loppu (ei seuraavaa riviä)

!src "src/bitituusi.asm"
!src "src/varituusi.asm"

*=$c010

alustus

    lda #$7C    ; Screen memory
    sta 53272
    lda #2      ; Videopankki
    sta 56576
    lda #59     ; Bittikartta
    sta 53265
    lda #24     ; Multicolor
    sta 53270
    lda #$0
    sta $D021   ; Tausta mustaksi

latausuusi

    ; jsr varikierros1 ; Ohita lataus

    jsr bitituusi_kovakoodattu

    ; Bittikartan lataus (taitaa tulla myös screen memory)
    lda #1
    ldx #8
    ldy #1
    jsr $ffba
    lda #fendbitit-filenamebitit
    ldx #<filenamebitit
    ldy #>filenamebitit
    jsr $ffbd
    lda #0
    jsr $ffd5

    ; Värien lataus väliaikaisosoitteeseen
    lda #1
    ldx #8
    ldy #1
    jsr $ffba
    lda #fendvarit-filenamevarit
    ldx #<filenamevarit
    ldy #>filenamevarit
    jsr $ffbd
    lda #0
    jsr $ffd5

bitituusi_kovakoodattu

    ; Kopioi väliaikaisesta värimuistiin
    lda #$00 ; Ensimmäiset 256
    sta $c0
    lda #$d8
    sta $c1
    lda #$00
    sta $c2
    lda #$90
    sta $c3
    ldy #$00
    
varikierros1
    lda ($c0),y
    and #$F0
    ora ($c2),y
    sta ($c0),y   
    iny
    cpy #$00
    bne varikierros1
    lda #$00 ; Toiset 256
    sta $c0
    lda #$d9
    sta $c1
    lda #$00
    sta $c2
    lda #$91
    sta $c3
    ldy #$00
varikierros2
    lda ($c0),y
    and #$F0
    ora ($c2),y
    sta ($c0),y   
    iny
    cpy #$00
    bne varikierros2
    lda #$00 ; Viimeiset $80
    sta $c0
    lda #$da
    sta $c1
    lda #$00
    sta $c2
    lda #$92
    sta $c3
    ldy #$00
varikierros3
    lda ($c0),y
    and #$F0
    ora ($c2),y
    sta ($c0),y   
    iny
    cpy #$80
    bne varikierros3

; --- Kopioidaan bittikartta riviltä 17 riville 24 asti
    lda #$c0 ; $72c0
    sta $fb
    sta $fd
    lda #$72
    sta $fc
    sta $fe

    ldx #$00
kopirivilooppiBit
    lda $fd ; Lisätään yksi rivi tallennuspaikkaan
    clc
    adc #$40
    sta $fd
    lda $fe
    adc #$01
    sta $fe

    ldy #$00
kopilooppiBit
    lda ($fb),y
    sta ($fd),y   
    iny
    cpy #$e8
    bne kopilooppiBit

    inx
    cpx #$08
    bne kopirivilooppiBit

; --- Kopioidaan näyttömuisti riviltä 17 riville 24 asti
    lda #$58 ; $5e58
    sta $fb
    sta $fd
    lda #$5e
    sta $fc
    sta $fe
    
    ldx #$00
kopirivilooppiSM
    lda $fd ; Lisätään yksi rivi tallennuspaikkaan
    clc
    adc #$28
    sta $fd
    lda $fe
    adc #$00
    sta $fe

    ldy #$00
kopilooppiSM
    lda ($fb),y
    sta ($fd),y   
    iny
    cpy #$1d
    bne kopilooppiSM

    inx
    cpx #$08
    bne kopirivilooppiSM

; --- Kopioidaan värimuisti riviltä 17 riville 24 asti
    lda #$58 ; $da58
    sta $fb
    sta $fd
    lda #$da
    sta $fc
    sta $fe
    
    ldx #$00
kopirivilooppiCM
    lda $fd ; Lisätään yksi rivi tallennuspaikkaan
    clc
    adc #$28
    sta $fd
    lda $fe
    adc #$00
    sta $fe

    ldy #$00
kopilooppiCM
    lda ($fd),y ; Nollataan neljä alinta kohteesta
    and #$F0
    sta ($fd),y
    lda ($fb),y ; Nollataan neljä ylinta lähteestä
    and #$0f    
    ora ($fd),y ; OR noiden kahden välillä
    sta ($fd),y   
    iny
    cpy #$1d
    bne kopilooppiCM

    inx
    cpx #$08
    bne kopirivilooppiCM

; --- Kopioidaan ylin rivi käänteisesti alimmaksi
    ; Värimuisti
    lda #$00 ; $d800, värimuistin alku
    sta $fb
    lda #$d8
    sta $fc
    lda #$c0 ; $dbc0, alimman värimuistirivin alku
    sta $fd
    lda #$db
    sta $fe
    ldy #$00
kopiylinalinvari
    lda ($fd),y ; Nollataan neljä alinta kohteesta
    and #$F0
    sta ($fd),y
    lda ($fb),y ; Nollataan neljä ylinta lähteestä
    and #$0f    
    ora ($fd),y ; OR noiden kahden välillä
    sta ($fd),y   
    iny
    cpy #$1d
    bne kopiylinalinvari

    ; Näyttömuisti
    lda #$00 ; $5c00, näyttömuistin alku
    sta $fb
    lda #$5c
    sta $fc
    lda #$c0 ; $5fc0, alimman näyttömuistirivin alku
    sta $fd
    lda #$5f
    sta $fe
    ldy #$00
kopiylinalinSM
    lda ($fb),y
    sta ($fd),y   
    iny
    cpy #$1d
    bne kopiylinalinSM

    ; Bittikartta
    lda #$00 ; $6000, bittikartan alku
    sta $fb
    lda #$60
    sta $fc
    lda #$00 ; $7e00, bittikartan viimeisen rivin alku
    sta $fd
    lda #$7e
    sta $fe
    ldy #$00
kopiylinalinBit
    lda ($fb),y
    sta ($fd),y   
    iny
    lda ($fb),y
    sta ($fd),y   
    iny
    lda ($fb),y
    sta ($fd),y   
    iny
    lda ($fb),y
    sta ($fd),y
    iny

    lda #$0
    iny
    sta ($fd),y
    iny
    sta ($fd),y
    iny
    sta ($fd),y
    iny
    sta ($fd),y

    cpy #$e8
    bne kopiylinalinBit

; Kentän taustan ruskeat pisteet värimuistista
kentantausta    
    lda #$48 ; $6148 grafiikkamuistin 2. rivi ja 2. sarake
    sta $fb
    lda #$61
    sta $fc
    ldy #$00
    ldx #$00
kentantaustaloop
    inx ; Joka toinen grafiikkarivi musta, joka toinen #$cc
    txa
    and #$01
    beq variruskea
    lda #$00
    jmp kentantaustaloopsisin
variruskea
    lda #$cc
kentantaustaloopsisin
    sta ($fb),y
    iny
    cpy #$d8
    bne kentantaustaloop
    ldy #$00
    lda $fb
    clc
    adc #$40
    sta $fb
    lda $fc
    adc #$01
    sta $fc
    cmp #$7e ; Pysähdy toiseksi viimeiselle riville osoitteeseen $7e08
    bne kentantaustaloop

; Värimuistin arvot kentän taustalle ruskeiksi
kentantaustavarimuisti
    lda #$29 ; $d829 värimuistin 2. rivi ja 2. sarake
    sta $fb
    lda #$d8
    sta $fc
    ldy #$00
kentantaustavarimuistiloop
    lda #$f0
    and ($fb),y
    ora #$09 ; ruskea
    sta ($fb),y
    iny
    cpy #$1c
    bne kentantaustavarimuistiloop
    ldy #$00
    lda $fb
    clc
    adc #$28
    sta $fb
    lda $fc
    adc #$00
    sta $fc    
    cmp #$db ; Pysähdy toiseksi viimeiselle riville osoitteeseen $dbc1
    bne kentantaustavarimuistiloop
    lda $fb
    cmp #$c1 ; Pysähdy toiseksi viimeiselle riville osoitteeseen $dbc1
    bne kentantaustavarimuistiloop

spritetesti

    lda #$79    ; Spritejen 0-4 x-sijainnit ruudulle
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
    
    ; Spritejen värit
    lda #$09 // Takki, Unique Colour :9
    sta $D029
    lda #$05 // Pipa, Unique Colour :5
    sta $D028
    lda #$0A // Kasvot, Unique Colour :10
    sta $D027
    lda #$02 // Vasen kengä, Unique Colour :2
    sta $D02A
    lda #$02 // Oikea kengä, Unique Colour :2
    sta $D02B

    jmp spriteliiketestiAlustus

; LUMIGRAFIIKKA
*=$1000
!byte $41,$b5,$59,$9a, $41,$6d,$55,$96,    $45,$6d,$a6,$aa, $41,$55,$a6,$9a ; Tasainen yläreuna × 4, alkaa $1000
!byte $1a,$16,$c6,$06,$c6,$16,$d6,$1a,      $5a,$d6,$da,$5a,$6a,$6a,$6a,$5a ; Tasainen vasen reuna × 2, alkaa $1010
!byte $a4,$a5,$95,$94,$a5,$a9,$a9,$a5,      $a5,$a5,$a7,$94,$97,$94,$a7,$a4 ; Tasainen oikea reuna × 2, alkaa $1020
!byte $40,$90,$a4,$a4,$a4,$a4,$a5,$a9,      $50,$94,$a4,$a5,$a9,$a9,$a9,$a9 ; Oikea ylänurkka × 2, alkaa $1030
!byte $05,$16,$5a,$5a,$6a,$6a,$6a,$6a,      $01,$c6,$1a,$da,$1a,$da,$5a,$6a ; Vasen ylänurkka × 2, alkaa $1040
!byte $6a,$5a,$da,$1a,$da,$1a,$c6,$01,      $6a,$6a,$6a,$6a,$5a,$1a,$16,$05 ; Vasen alanurkka × 2, alkaa $1050
!byte $a9,$a5,$a7,$a4,$a7,$a4,$93,$40,      $a9,$a9,$a9,$a9,$a5,$a4,$94,$50 ; Oikea alanurkka × 2, alkaa $1060
!byte 128,172,37,228,16,220,0,204,           40,201,4,204,0,204,0,204         ; Vihreätä kentälle, alkaa $1070

; JALANJÄLJET
; 10 on lunta, 01 on jalanjälki
!byte 60,252,255,255,255,255,63,60  ; Jalkaterä ylöspäin OR, $1080 - $1087
!byte 215,87,85,85,85,85,213,215    ; Jalkaterä ylöspäin AND, $1088 - $108f

; SPRITET
*=$4000
; -- Vaakasuunta --
; 00: Takki
!byte 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 031, 255, 248, 063, 255, 252, 063, 255, 252, 063, 255, 252, 063, 255, 252, 031, 255, 248, 000, 255, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000
; 01: Pipa
!byte 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 060, 000, 000, 126, 000, 000, 255, 000, 000, 255, 000, 000, 255, 000, 000, 255, 000, 000, 126, 000, 000, 060, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000
; 02: Vasen kenkä
!byte 001, 224, 000, 003, 240, 000, 003, 240, 000, 003, 240, 000, 001, 240, 000, 001, 224, 000, 000, 224, 000, 000, 224, 000, 000, 128, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000
; 03: Kasvot oikealle
!byte 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 003, 000, 000, 002, 128, 000, 003, 224, 000, 003, 064, 000, 003, 128, 000, 003, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000
; 04: Kasvot vasemmalle
!byte 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 192, 000, 001, 064, 000, 007, 192, 000, 002, 192, 000, 001, 192, 000, 000, 192, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000
; 05: Oikea kenkä
!byte 000, 003, 192, 000, 007, 224, 000, 007, 224, 000, 007, 224, 000, 003, 224, 000, 003, 224, 000, 007, 192, 000, 007, 128, 000, 007, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000

; -- Pystysuunta --
; 06: Takki
!byte 000, 000, 000, 000, 060, 000, 000, 126, 000, 000, 126, 000, 000, 126, 000, 000, 126, 000, 000, 126, 000, 000, 254, 000, 000, 254, 000, 000, 254, 000, 000, 254, 000, 000, 254, 000, 000, 254, 000, 000, 254, 000, 000, 254, 000, 000, 126, 000, 000, 126, 000, 000, 126, 000, 000, 126, 000, 000, 126, 000, 000, 060, 000, 000
; 07: Vasen kenkä
!byte 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 028, 000, 000, 126, 000, 003, 254, 000, 001, 254, 000, 001, 254, 000, 000, 060, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000
; 08: Kasvot vasemmalle
!byte 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 008, 000, 000, 024, 000, 000, 044, 000, 000, 122, 000, 000, 126, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000
; 09: Kasvot oikealle
!byte 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 126, 000, 000, 122, 000, 000, 044, 000, 000, 024, 000, 000, 008, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000
; 0A: Oikea kenkä
!byte 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 003, 156, 000, 003, 254, 000, 003, 254, 000, 001, 254, 000, 000, 254, 000, 000, 124, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000

; -- Rintamasuunta luoteeseen --
; 0B: Takki
!byte 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 192, 000, 001, 224, 000, 003, 240, 000, 007, 240, 000, 015, 240, 000, 031, 224, 000, 063, 192, 000, 127, 192, 001, 255, 128, 003, 255, 000, 007, 254, 000, 015, 252, 000, 015, 248, 000, 031, 192, 000, 015, 000, 000, 006, 000, 000, 000, 000, 000, 000, 000, 000, 000
; 0C: Vasen kenkä
!byte 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 048, 000, 000, 120, 000, 000, 248, 000, 000, 252, 000, 000, 255, 000, 000, 127, 000, 000, 063, 000, 000, 003, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000
; 0D: Kasvot vasemmalle
!byte 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 128, 000, 000, 192, 000, 001, 192, 000, 002, 224, 000, 003, 176, 000, 003, 112, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000
; 0E: Kasvot oikealle
!byte 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 001, 128, 000, 005, 000, 000, 015, 000, 000, 006, 128, 000, 003, 128, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000
; 0F: Oikea kenkä
!byte 001, 128, 000, 007, 192, 000, 007, 192, 000, 015, 192, 000, 007, 224, 000, 007, 224, 000, 001, 240, 000, 000, 120, 000, 000, 112, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000

; -- Rintamasuunta lounaaseen --
; 10: Takki
!byte 000, 000, 000, 000, 000, 000, 000, 000, 000, 003, 000, 000, 007, 192, 000, 015, 248, 000, 015, 254, 000, 015, 255, 000, 007, 255, 128, 003, 255, 192, 000, 255, 192, 000, 063, 224, 000, 015, 224, 000, 007, 224, 000, 003, 240, 000, 001, 240, 000, 001, 248, 000, 000, 240, 000, 000, 096, 000, 000, 000, 000, 000, 000, 000
; 11: Vasen kenkä
!byte 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 006, 000, 000, 126, 000, 000, 254, 000, 001, 254, 000, 001, 248, 000, 001, 240, 000, 000, 240, 000, 000, 096, 000, 000, 000, 000, 000
; 12: Kasvot vasemmalle
!byte 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 001, 000, 000, 003, 128, 000, 007, 064, 000, 013, 192, 000, 007, 192, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000
; 13: Kasvot oikealle
!byte 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 128, 000, 007, 096, 000, 003, 224, 000, 002, 192, 000, 001, 128, 000, 000, 128, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000
; 14: Oikea kenkä
!byte 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 064, 000, 000, 224, 000, 003, 224, 000, 063, 224, 000, 127, 128, 000, 127, 000, 000, 062, 000, 000, 062, 000, 000, 008, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000

; Taustagrafiikka 
filenamebitit !pet "bitituusi.bin"
fendbitit
filenamevarit !pet "variuusi.bin"
fendvarit