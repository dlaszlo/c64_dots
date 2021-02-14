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
COLOR1            = YELLOW
COLOR2            = ORANGE
COLOR3            = RED

COLOR0B           = BLACK
COLOR1B           = WHITE
COLOR2B           = LIGHT_BLUE
COLOR3B           = BLUE

COLOR0C           = BLACK
COLOR1C           = YELLOW
COLOR2C           = ORANGE
COLOR3C           = RED
COLOR0D           = BLACK
COLOR1D           = WHITE
COLOR2D           = LIGHT_GREEN
COLOR3D           = GREEN
COLOR0E           = BLACK
COLOR1E           = WHITE
COLOR2E           = GREY
COLOR3E           = DARK_GREY


; COLOR0B           = BLACK
; COLOR1B           = WHITE
; COLOR2B           = LIGHT_BLUE
; COLOR3B           = BLUE
; COLOR0C           = BLACK
; COLOR1C           = YELLOW
; COLOR2C           = ORANGE
; COLOR3C           = RED
; COLOR0D           = BLACK
; COLOR1D           = BROWN
; COLOR2D           = LIGHT_GREEN
; COLOR3D           = GREEN
; COLOR0E           = BLACK
; COLOR1E           = CYAN
; COLOR2E           = LIGHT_GREY
; COLOR3E           = GREY


*               = $8000

                jsr     init_vic
                
                

-               lda     #$00
                sta     dcnt
                inc     dots
                inc     dots
                inc     dots
                inc     dots
                beq     +
                jsr     effect1
                jsr     switch_vic_bank
                jmp     -

+
-               
                inc     dots
                inc     dots
                beq     +
                jsr     effect2
                jsr     switch_vic_bank
                jmp     -

+
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank

                jsr     setup_color2
                jsr     effect3
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
-               
                inc     dots
                inc     dots
                beq     +
                jsr     effect3
                jsr     switch_vic_bank
                jmp     -

loop
+
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     setup_color2
                jsr     effect2
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
-               inc     dots
                inc     dots
                beq     +               
                jsr     effect2
                jsr     switch_vic_bank
                jmp     -

+
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     setup_color3
                jsr     effect3
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
-               inc     dots
                inc     dots
                beq     +
                jsr     effect3
                jsr     switch_vic_bank
                jmp     -

+               jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     setup_color4
                jsr     effect2
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
-               inc     dots
                inc     dots
                beq     +               
                jsr     effect2
                jsr     switch_vic_bank
                jmp     -

+
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     setup_color4
                jsr     effect3
                jsr     switch_vic_bank
                jsr     switch_vic_bank
                jsr     switch_vic_bank
-               inc     dots
                inc     dots
                beq     +
                jsr     effect3
                jsr     switch_vic_bank
                jmp     -

+               jmp     loop


.align 256
dcnt  .byte $00
dots  .byte $00
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

                lda     dcnt
                cmp     dots
                beq     +
                jsr     plot
                inc     dcnt
+               dec     count
                bne     effect1_next

                inc     posx1
                inc     posy1
                inc     posy1
                rts


effect2         lda     #$00
                sta     count

effect2_next:   ldx     posx1
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

+               dec     count
                bne     effect2_next

                inc     posx1
                inc     posy1
                inc     posy1
                rts


effect3         lda     #$00
                sta     count

effect3_next:   ldx     posx1
                lda     sin, x
                inx
                inx
                inx
                stx     posx1

                ldx     posx2
                clc
                adc     sin, x
                shr
                inx
                inx
                stx     posx2

                clc
                adc     #30
                tax

                ldy     posy1
                lda     sin, y
                iny
                iny
                iny
                iny
                sty     posy1

                ldy     posy2
                clc
                adc     sin, y
                shr
                iny
                sty     posy2

                clc
                adc     #50
                tay

                jsr     plot

+               dec     count
                bne     effect3_next

                inc     posx1
                inc     posx1
                inc     posx1
                inc     posy1
                inc     posy1
                inc     posx2
                inc     posx2
                inc     posy2
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
init_vic        
                lda     #$0b
                sta     $d011

                jsr     setup_color
                jsr     clearscreen

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
-               lda     #((COLOR3 << 4) + COLOR2)
                .for i := 0, i < $400, i += $100
                sta     COLOR1_ADDRESS1 + i, x
                sta     COLOR1_ADDRESS2 + i, x
                .next
                lda     #(COLOR1)
                .for i := 0, i < $400, i += $100
                sta     COLOR2_ADDRESS + i, x
                .next
                dex
                beq     +
                jmp     -
+               rts

setup_color2    lda     #$00
                tax
-               lda     #((COLOR3B << 4) + COLOR2B)
                .for i := 0, i < $400, i += $100
                sta     COLOR1_ADDRESS1 + i, x
                sta     COLOR1_ADDRESS2 + i, x
                .next
                lda     #(COLOR1B)
                .for i := 0, i < $400, i += $100
                sta     COLOR2_ADDRESS + i, x
                .next
                dex
                beq     +
                jmp     -
+               rts

setup_color3

                ldx     20
-               .for ya0 := 0, ya0 < 13, ya0 += 1
                lda     #((COLOR3B << 4) + COLOR2B)
                sta     COLOR1_ADDRESS1 + (ya0 * 40), x
                sta     COLOR1_ADDRESS2 + (ya0 * 40), x
                lda     #(COLOR1B)
                sta     COLOR2_ADDRESS  + (ya0 * 40), x
                .next
                dex
                beq     +
                jmp     -

+               ldx     20
-               .for ya1 := 0, ya1 < 13, ya1 += 1
                lda     #((COLOR3C << 4) + COLOR2C)
                sta     COLOR1_ADDRESS1 + (ya1 * 40) + 19, x
                sta     COLOR1_ADDRESS2 + (ya1 * 40) + 19, x
                lda     #(COLOR1C)
                sta     COLOR2_ADDRESS  + (ya1 * 40) + 19, x
                .next
                dex
                beq     +
                jmp     -
 
+               ldx     20
-               .for ya2 := 13, ya2 < 25, ya2 += 1
                lda     #((COLOR3D << 4) + COLOR2D)
                sta     COLOR1_ADDRESS1 + (ya2 * 40), x
                sta     COLOR1_ADDRESS2 + (ya2 * 40), x
                lda     #(COLOR1D)
                sta     COLOR2_ADDRESS  + (ya2 * 40), x
                .next
                dex
                beq     +
                jmp     -

+               ldx     20
-              .for ya3 := 13, ya3 < 25, ya3 += 1
                lda     #((COLOR3E << 4) + COLOR2E)
                sta     COLOR1_ADDRESS1 + (ya3 * 40) + 19, x
                sta     COLOR1_ADDRESS2 + (ya3 * 40) + 19, x
                lda     #(COLOR1E)
                sta     COLOR2_ADDRESS  + (ya3 * 40) + 20, x
                .next
                dex
                beq     +
                jmp     -

+               rts

setup_color4
                ldx     20
-               .for ya0 := 0, ya0 < 13, ya0 += 1
                lda     #((COLOR3E << 4) + COLOR2E)
                sta     COLOR1_ADDRESS1 + (ya0 * 40), x
                sta     COLOR1_ADDRESS2 + (ya0 * 40), x
                lda     #(COLOR1E)
                sta     COLOR2_ADDRESS  + (ya0 * 40), x
                .next
                dex
                beq     +
                jmp     -

+               ldx     20
-               .for ya1 := 0, ya1 < 13, ya1 += 1
                lda     #((COLOR3D << 4) + COLOR2D)
                sta     COLOR1_ADDRESS1 + (ya1 * 40) + 19, x
                sta     COLOR1_ADDRESS2 + (ya1 * 40) + 19, x
                lda     #(COLOR1D)
                sta     COLOR2_ADDRESS  + (ya1 * 40) + 19, x
                .next
                dex
                beq     +
                jmp     -
 
+               ldx     20
-               .for ya2 := 13, ya2 < 25, ya2 += 1
                lda     #((COLOR3C << 4) + COLOR2C)
                sta     COLOR1_ADDRESS1 + (ya2 * 40), x
                sta     COLOR1_ADDRESS2 + (ya2 * 40), x
                lda     #(COLOR1C)
                sta     COLOR2_ADDRESS  + (ya2 * 40), x
                .next
                dex
                beq     +
                jmp     -

+               ldx     20
-              .for ya3 := 13, ya3 < 25, ya3 += 1
                lda     #((COLOR3B << 4) + COLOR2B)
                sta     COLOR1_ADDRESS1 + (ya3 * 40) + 19, x
                sta     COLOR1_ADDRESS2 + (ya3 * 40) + 19, x
                lda     #(COLOR1B)
                sta     COLOR2_ADDRESS  + (ya3 * 40) + 20, x
                .next
                dex
                beq     +
                jmp     -

+               rts


; ===========================
; Képernyő törlése
; ===========================
clearscreen     lda     #$00
                tax
-               lda     #$00
                .for i := 0, i < $2000, i += $100
                sta     BITMAP_ADDRESS1 + i, x
                sta     BITMAP_ADDRESS2 + i, x
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
-               .for i := $0, i < $2000, i += $100
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
-               .for i := $0, i < $2000, i += $100
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


