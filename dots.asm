                .cpu "6502"
                .enc "screen"

VIC_MEM_SCHEMA    = #%00011010          ; Bitmap is at $2000, Screenmem is at $0000; Charmem is at $0800

VIC_BANK1         = #%00000011          ; Bank 0
VIC_BANK2         = #%00000010          ; Bank 1

VIC_BASE_ADDRESS1 = $0000
BITMAP_ADDRESS1   = VIC_BASE_ADDRESS1 + $2000
COLOR1_ADDRESS1   = VIC_BASE_ADDRESS1 + $0400
VIC_BASE_ADDRESS2 = $4000
BITMAP_ADDRESS2   = VIC_BASE_ADDRESS2 + $2000
COLOR1_ADDRESS2   = VIC_BASE_ADDRESS2 + $0400
COLOR2_ADDRESS    = $d800

PLOTADDR          = $02

.include "colors.inc"

COLOR0            = BLACK
COLOR1            = WHITE
COLOR2            = LIGHT_BLUE
COLOR3            = BLUE

*               = $8000

                jsr     init_vic

-               jsr     effect1
                jsr     switch_vic_bank
                jmp     -

.align 256
count .byte $00
posx1 .byte $00
posy1 .byte $40
posx2 .byte $20
posy2 .byte $50


effect1         lda     #$00
                sta     count

effect1_next:   ldx     posx1
                lda     sin, x
                inx
                stx     posx1

                ldx     posx2
                clc
                adc     sin, x
                shr
                inx
                inx
                inx
                stx     posx2

                clc
                adc     #30
                tax

                ldy     posy1
                lda     sin, y
                iny
                sty     posy1

                ldy     posy2
                clc
                adc     sin, y
                shr
                iny
                iny
                sty     posy2

                clc
                adc     #50
                tay

                jsr     plot

                dec     count
                bne     effect1_next

                inc     posx1
                inc     posy1
                inc     posy1
                rts

; =============================
; VIC bank váltás
; Rutinok címeinek a beállítása
; =============================
switch_vic_bank jmp swb1

swb1            ldx     #<swb2
                stx     switch_vic_bank + 1
                ldx     #>swb2
                stx     switch_vic_bank + 2
                ldx     #<plot2
                stx     plot + 1
                ldx     #>plot2
                stx     plot + 2
                lda     $dd00
                and     #%11111100      ; VIC bank mask
                ora     VIC_BANK1
                sta     $dd00
                jsr     fade2
                rts

swb2            ldx     #<swb1
                stx     switch_vic_bank + 1
                ldx     #>swb1
                stx     switch_vic_bank + 2
                ldx     #<plot1
                stx     plot + 1
                ldx     #>plot1
                stx     plot + 2
                lda     $dd00
                and     #%11111100      ; VIC bank mask
                ora     VIC_BANK2
                sta     $dd00
                jsr     fade1
                rts

; ===========================
; Képpont rajzolása
; Paraméterek: x, y
; ===========================
plot            jmp     plot1

plot1           clc                
                lda     ytablelow1, y
                adc     xtablelow, x
                sta     PLOTADDR
                lda     ytablehigh1, y
                adc     xtablehigh, x
                sta     PLOTADDR + 1
                ldy     #$00
                lda     (PLOTADDR), y
                ora     mask, x
                sta     (PLOTADDR), y
                rts

plot2           clc                
                lda     ytablelow2, y
                adc     xtablelow, x
                sta     PLOTADDR
                lda     ytablehigh2, y
                adc     xtablehigh, x
                sta     PLOTADDR + 1
                ldy     #$00
                lda     (PLOTADDR), y
                ora     mask, x
                sta     (PLOTADDR), y
                rts

; ===========================
; VIC inicializálása
; ===========================
init_vic        jsr     setup_color
                jsr     clearscreen1
                jsr     clearscreen2

                ; Background color: 00
                lda     #(COLOR0)
                sta     $d020
                sta     $d021
                jsr     switch_vic_bank

                ; VIC mem schema
                lda     VIC_MEM_SCHEMA
                sta     $d018

                ; Multicolor bitmap mode
                lda     #$3b
                sta     $d011
                lda     #$18
                sta     $d016
                rts

; ===========================
; Színek beállítása
; ===========================
setup_color     lda     #$00
                tax
                ; white + light blue
-               lda     #((COLOR3 << 4) + COLOR2)
                .for i := COLOR1_ADDRESS1, i < COLOR1_ADDRESS1 + $400, i += $100
                sta     i, x
                .next
                ; white + light blue
                lda     #((COLOR3 << 4) + COLOR2)
                .for i := COLOR1_ADDRESS2, i < COLOR1_ADDRESS2 + $400, i += $100
                sta     i, x
                .next
                ; blue
                lda     #(COLOR1)
                .for i := COLOR2_ADDRESS, i < COLOR2_ADDRESS + $400, i += $100
                sta     i, x
                .next
                dex
                beq     +
                jmp     -
+               rts

; ===========================
; 1. képernyő törlése
; ===========================
clearscreen1    lda     #$00
                tax
-               lda     #$00
                .for i := BITMAP_ADDRESS1, i < BITMAP_ADDRESS1 + $2000, i += $100
                sta     i, x
                .next
                dex
                beq     +
                jmp     -
+               rts

; ===========================
; 2. képernyő törlése
; ===========================
clearscreen2    lda     #$00
                tax
-               lda     #$00
                .for i := BITMAP_ADDRESS2, i < BITMAP_ADDRESS2 + $2000, i += $100
                sta     i, x
                .next
                dex
                beq     +
                jmp     -
+               rts

; ===========================
; 1. képernyő halványítása
; ===========================
fade1           lda     #$00
                tax
-               .for i := $500, i < $1800, i += $100
                lda     BITMAP_ADDRESS1 + i, x
                cmp     #00
                beq     +
                tay
                lda     fade, y
                sta     BITMAP_ADDRESS1 + i, x
+               .next
                dex
                beq     +
                jmp     -
+               rts

; ===========================
; 2. képernyő halványítása
; ===========================
fade2           lda     #$00
                tax
-               .for i := $500, i < $1800, i += $100
                lda     BITMAP_ADDRESS2 + i, x
                cmp     #00
                beq     +
                tay
                lda     fade, y
                sta     BITMAP_ADDRESS2 + i, x
+               .next
                dex
                beq     +
                jmp     -
+               rts

; ===========================
; Szorzás
; ===========================
;mul             dec num2
;                lda #$00
;                ldx #$08
;                lsr num1
;loop_mul        bcc skip_mul
;                adc num2
;skip_mul        ror
;                ror num1
;                dex
;                bne loop_mul
;                sta num2
;                rts
;num1 .byte 0
;num2 .byte 20

.include "tables.inc"


