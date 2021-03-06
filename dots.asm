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

.include "macros.asm"

COLOR0            = BLACK
COLOR1            = WHITE
COLOR2            = LIGHT_BLUE
COLOR3            = BLUE

*               = $8000

                jsr     init
                
-               
                jsr     reset_plot_addr

                ; 6 képernyőnként kell resetelni a plot rutinban a pointereket,
                ; ezért itt hatszor meghívjuk az effektet
                .for i := 0, i < 6, i += 1
                jsr     calc_framerate
                jsr     effect2
                jsr     switch_vic_bank
                .next

                jmp     -

.align 256
frame_rate      .byte $00
current_frame   .byte $00
count           .byte $00
posx1           .byte $00
posy1           .byte $40
posx2           .byte $20
posy2           .byte $50

calc_framerate  lda     current_frame
                sta     frame_rate
                lda     #$00
                sta     current_frame
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
                inx
                inx
                inx
                stx     posx2
                clc
                adc     #80
                tax

                ldy     posy1
                lda     sin, y
                iny
                sty     posy1
                ldy     posy2
                clc
                adc     sin, y
                iny
                iny
                sty     posy2
                clc

                adc     #100
                tay

                jsr     plot

+               dec     count
                bne     effect2_next

                inc     posx1
                inc     posy1
                inc     posy1
                rts

; ----------------------------------------
; VIC bank váltás
; Rutinok címeinek a beállítása
; ----------------------------------------
switch_vic_bank jmp swb1

swb1

                ; A következő híváskor a VIC bank váltó rutin az swb2 lesz.
                #mod_addr   swb2, switch_vic_bank

                ; A plotter rutin mostantól a plot2 lesz
                ; (mivel az 1-es VIC-blank-ot mutatjuk a másikat rajzoljuk)
                #mod_addr   plot2, plot           
                                                
                lda     $dd00
                and     #%11111100              ; VIC bank mask
                ora     VIC_BANK1
                sta     $dd00

                ; inicializálás után ez a jmp a fade2-re fog mutatni,
                ; de inicializálás közben nem kell meghívni a fade2-t,
                ; ezért mutat az rts-re
fade2jmp        jmp     +                       
+               rts

swb2

                ; A következő híváskor a VIC bank váltó rutin az swb1 lesz.
                #mod_addr swb1, switch_vic_bank 

                ; A plotter rutin mostantól a plot1 lesz
                ; (mivel az 1-es VIC-blank-ot mutatjuk a másikat rajzoljuk)
                #mod_addr plot1, plot

                lda     $dd00
                and     #%11111100              ; VIC bank mask
                ora     VIC_BANK2
                sta     $dd00

                ; inicializálás után ez a jmp fade1-re fog mutatni,
                ; de inicializálás közben nem kell meghívni a fade1-t,
                ; ezért mutat az rts-re
fade1jmp        jmp     +
+               rts

; ----------------------------------------
; Képpont rajzolása
; Paraméterek: x, y
; ----------------------------------------
plot            jmp     plot1

plot1           clc                
                lda     ytablelow1, y
                adc     xtablelow, x
                sta     PLOTADDR
plot1add1       sta     FADE1_LDA_LO
plot1add2       sta     FADE1_STA_LO
                lda     ytablehigh1, y
                adc     xtablehigh, x
                sta     PLOTADDR + 1
plot1add3       sta     FADE1_LDA_HI
plot1add4       sta     FADE1_STA_HI
                ldy     #$00
                lda     (PLOTADDR), y
                ora     mask, x
                sta     (PLOTADDR), y

                #add_word plot1add1 + 1, FADE_INC_SIZ
                #add_word plot1add2 + 1, FADE_INC_SIZ
                #add_word plot1add3 + 1, FADE_INC_SIZ
                #add_word plot1add4 + 1, FADE_INC_SIZ

                rts

plot2           clc                
                lda     ytablelow2, y
                adc     xtablelow, x
                sta     PLOTADDR
plot2add1       sta     FADE2_LDA_LO
plot2add2       sta     FADE2_STA_LO
                lda     ytablehigh2, y
                adc     xtablehigh, x
                sta     PLOTADDR + 1
plot2add3       sta     FADE2_LDA_HI
plot2add4       sta     FADE2_STA_HI
                ldy     #$00
                lda     (PLOTADDR), y
                ora     mask, x
                sta     (PLOTADDR), y

                #add_word plot2add1 + 1, FADE_INC_SIZ
                #add_word plot2add2 + 1, FADE_INC_SIZ
                #add_word plot2add3 + 1, FADE_INC_SIZ
                #add_word plot2add4 + 1, FADE_INC_SIZ

                rts

; ----------------------------------------
; A plot rutin címeit reseteli
; Paraméterek: x, y
; ----------------------------------------
reset_plot_addr
                mod_addr FADE1_LDA_LO, plot1add1
                mod_addr FADE1_STA_LO, plot1add2
                mod_addr FADE1_LDA_HI, plot1add3
                mod_addr FADE1_STA_HI, plot1add4
                mod_addr FADE2_LDA_LO, plot2add1
                mod_addr FADE2_STA_LO, plot2add2
                mod_addr FADE2_LDA_HI, plot2add3
                mod_addr FADE2_STA_HI, plot2add4
                rts

; ----------------------------------------
; Színek beállítása
; ----------------------------------------
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

; ----------------------------------------
; Képernyő törlése
; ----------------------------------------
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

init    		sei					; Set interrupt flag -> disable IRQs

                ; #$37 (#%00110111) - BASIC ON  ($a000-$bfff) / KERNAL ON  ($e000-$ffff) / IO AREA ON
                ; #$36 (#%00110110) - BASIC OFF ($a000-$bfff) / KERNAL ON  ($e000-$ffff) / IO AREA ON
                ; #$35 (#%00110101) - BASIC OFF ($a000-$bfff) / KERNAL OFF ($e000-$ffff) / IO AREA ON
                ; #$34 (#%00110100) - BASIC OFF ($a000-$bfff) / KERNAL OFF ($e000-$ffff) / IO AREA OFF
                lda		#$35        
                sta		$01			; Bank out kernal and basic

                lda		#$7f
                sta		$dc0d		; Disable CIA1 timer interrupts
                sta		$dd0d		; Disable CIA2 timer interrupts
                asl		$d019		; Acknowledge any previous IRQs (reading the interrupt control registers, clears them)
                bit		$dc0d
                bit		$dd0d
                lda		#$01
                sta		$d01a		; Enable raster interrupt (bit0), RASTER IRQ

                ; Set NMI vector
                #set_addr   nmi, $fffa

                lda		#$00		; stop Timer A
                sta		$dd0e
                sta		$dd04		; set Timer A to 0, after starting
                sta		$dd05		; NMI will occur immediately
                lda		#$81
                sta		$dd0d		; set Timer A as source for NMI
                lda		#$01		; start Timer A -> NMI
                sta		$dd0e		; from here on NMI is disabled

                jsr     init_vic

                ; Set up the IRQ vector - into the Hardware Interrupt Vector
                #set_addr   irq10, $fffe

                lda		#$0
                sta		$d012		; Set the rasterline to generate the interrupt at line #64
              
;               lda		#$1b		; SCREEN OFF
;               sta		$d011		; Option 2: Clearing the high bit (9th bit for the rasterline)

                lda     $d011       ; Option 2: Clearing the high bit (9th bit for the rasterline)
                and     #%01111111
                sta     $d011

                cli					; Clear interrupt flag -> enable IRQs

                rts
; ===========================
; VIC inicializálása
; ===========================
init_vic        lda     #$0b
                sta     $d011

                jsr     setup_color
                jsr     clearscreen

                ; Background color
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

                #mod_addr fade1, fade1jmp
                #mod_addr fade2, fade2jmp

                rts

; ----------------------------------------
; IRQ #10 / Playing the music
; ----------------------------------------
irq10           sta		rea10+1		; Preserve A,X and Y registers
                stx		rex10+1
                sty		rey10+1

;               jsr		$e003
                inc     current_frame

                asl		$d019		; Acknowledge IRQ				
rea10           lda		#$00    	; Reload A,X,and Y registers
rex10           ldx		#$00
rey10           ldy		#$00
nmi             rti		

dummy           .byte 0

.align          256
.include        "tables.asm"

FADE_INC_SIZ = #10           ; A fade rutinokban 1 pixelhez 10 bájt hosszú kód kell
FADE1_LDA_LO = fade1 + 1    ; A fade rutinokban itt szerepel az első LDA-hoz a cím
FADE1_LDA_HI = fade1 + 2
FADE2_LDA_LO = fade2 + 1
FADE2_LDA_HI = fade2 + 2

FADE1_STA_LO = fade1 + 8    ; A fade rutinokban itt szerepel az első STA-hoz a cím
FADE1_STA_HI = fade1 + 9
FADE2_STA_LO = fade2 + 8
FADE2_STA_HI = fade2 + 9


.align          256
fade1           .for i := 0, i < 768, i += 1
                lda     dummy
                tay
                lda     fade, y
                sta     dummy
                .next
                rts

.align          256
fade2           .for i := 0, i < 768, i += 1
                lda     dummy
                tay
                lda     fade, y
                sta     dummy
                .next
                rts

