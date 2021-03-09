                .cpu "6502"
                .enc "screen"

.include "macros.asm"

*               = $8000
.dsection       code
.cerror         * > $9fff, "Program too long!"

*               = $a000
.dsection       data
.cerror         * > $afff, "Data too long!"


; ----------------------------------------
; VIC
; ----------------------------------------
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

COLOR0            = BLACK
COLOR1            = WHITE
COLOR2            = LIGHT_BLUE
COLOR3            = BLUE

.section        zeropage
plotaddr          .addr ?
fade1_curr_addr   .addr ?
fade2_curr_addr   .addr ?
.send


; ----------------------------------------
; *ENTRY
; ----------------------------------------
.section        code

                jsr     init
-               
                seta    gen_code.fade1, fade1_curr_addr
                seta    gen_code.fade2, fade2_curr_addr

                ; 6 képernyőnként kell resetelni a plot rutinban a pointereket,
                ; ezért itt hatszor meghívjuk az effektet
                .for i := 0, i < 6, i += 1
                jsr     calc_framerate
                jsr     effect1
                jsr     switch_vic_bank
                .next

                jmp     -

; ----------------------------------------
; VIC bank váltás
; Rutinok címeinek a beállítása
; ----------------------------------------

.section        data
count           .byte   $00
posx1           .byte   $00
posy1           .byte   $40
posx2           .byte   $20
posy2           .byte   $50
.send

effect1         .proc

                lda     #$00
                sta     count

effect_next:    ldx     posx1
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
                bne     effect_next

                inc     posx1
                inc     posy1
                inc     posy1
                rts
                .pend

; ----------------------------------------
; VIC bank váltás
; Rutinok címeinek a beállítása
; ----------------------------------------
switch_vic_bank .proc

switchjmp       jmp swb1

swb1            ; A következő híváskor a VIC bank váltó rutin az swb2 lesz.
                moda    swb2, switchjmp

                ; A plotter rutin mostantól a plot2 lesz
                ; (mivel az 1-es VIC-blank-ot mutatjuk a másikat rajzoljuk)
                moda    plot.plot2, plot.plotjmp
                                                
                lda     $dd00
                and     #%11111100              ; VIC bank mask
                ora     VIC_BANK1
                sta     $dd00
                ; inicializálás után ez a jmp a fade2-re fog mutatni,
                ; de inicializálás közben nem kell meghívni a fade2-t,
                ; ezért mutat az rts-re
fade2jmp        jmp     +                       
+               rts

swb2            ; A következő híváskor a VIC bank váltó rutin az swb1 lesz.
                moda    swb1, switchjmp 

                ; A plotter rutin mostantól a plot1 lesz
                ; (mivel az 1-es VIC-blank-ot mutatjuk a másikat rajzoljuk)
                moda    plot.plot1, plot.plotjmp

                lda     $dd00
                and     #%11111100              ; VIC bank mask
                ora     VIC_BANK2
                sta     $dd00

                ; inicializálás után ez a jmp fade1-re fog mutatni,
                ; de inicializálás közben nem kell meghívni a fade1-t,
                ; ezért mutat az rts-re
fade1jmp        jmp     +
+               rts

                .pend

; ----------------------------------------
; Képpont rajzolása
; Paraméterek: x, y
; ----------------------------------------
plot            .proc

plotjmp         jmp     plot1

plot1           clc                
                lda     ytablelow1, y
                adc     xtablelow, x
                sta     plotaddr

                lda     ytablehigh1, y
                adc     xtablehigh, x
                sta     plotaddr + 1

                ldy     gen_code.FADE_LDA_OFFSET + 1
                sta     (fade1_curr_addr), y
                ldy     gen_code.FADE_STA_OFFSET + 1
                sta     (fade1_curr_addr), y

                ldy     #$00
                lda     (plotaddr), y
                ora     mask, x
                sta     (plotaddr), y

                lda     plotaddr
                ldy     gen_code.FADE_LDA_OFFSET
                sta     (fade1_curr_addr), y
                ldy     gen_code.FADE_STA_OFFSET
                sta     (fade1_curr_addr), y

                lda     fade1_curr_addr
                adc     #size(gen_code.fade_template)
                sta     fade1_curr_addr
                bcs     +
                rts
+               inc     fade1_curr_addr + 1
                rts


plot2           clc                
                lda     ytablelow2, y
                adc     xtablelow, x
                sta     plotaddr

                lda     ytablehigh2, y
                adc     xtablehigh, x
                sta     plotaddr + 1

                ldy     gen_code.FADE_LDA_OFFSET + 1
                sta     (fade2_curr_addr), y
                ldy     gen_code.FADE_STA_OFFSET + 1
                sta     (fade2_curr_addr), y

                ldy     #$00
                lda     (plotaddr), y
                ora     mask, x
                sta     (plotaddr), y

                lda     plotaddr
                ldy     gen_code.FADE_LDA_OFFSET
                sta     (fade2_curr_addr), y
                ldy     gen_code.FADE_STA_OFFSET
                sta     (fade2_curr_addr), y

                lda     fade2_curr_addr
                adc     #size(gen_code.fade_template)
                sta     fade2_curr_addr
                bcs     +
                rts
+               inc     fade2_curr_addr + 1
                rts

                .pend

; ----------------------------------------
; Inicializálás
; ----------------------------------------
init    		.proc
                sei					; Set interrupt flag -> disable IRQs

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
                seta    nmi, $fffa

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
                seta    irq10, $fffe

                lda		#$0
                sta		$d012		; Set the rasterline to generate the interrupt at line #64
              
;               lda		#$1b		; SCREEN OFF
;               sta		$d011		; Option 2: Clearing the high bit (9th bit for the rasterline)

                lda     $d011       ; Option 2: Clearing the high bit (9th bit for the rasterline)
                and     #%01111111
                sta     $d011

                cli					; Clear interrupt flag -> enable IRQs

                jsr     gen_code

                rts

; VIC inicializálása
init_vic        lda     #$0b
                sta     $d011

                ; Clear screen and set colors
                lda     #(COLOR0)   ; Background color
                sta     $d020
                sta     $d021
                fill    BITMAP_ADDRESS1, #8000, #0
                fill    BITMAP_ADDRESS2, #8000, #0
                fill    COLOR1_ADDRESS1, #1000, #((COLOR3 << 4) + COLOR2)
                fill    COLOR1_ADDRESS2, #1000, #((COLOR3 << 4) + COLOR2)
                fill    COLOR2_ADDRESS,  #1000, #(COLOR1)

                ; VIC mem schema
                lda     VIC_MEM_SCHEMA
                sta     $d018

                jsr     switch_vic_bank

                ; Multicolor bitmap mode
                lda     #$3b
                sta     $d011
                lda     #$18
                sta     $d016

                moda    gen_code.fade1, switch_vic_bank.fade1jmp
                moda    gen_code.fade2, switch_vic_bank.fade2jmp
                rts

                .pend

; ----------------------------------------
; fade1, fade2 rutinok generálása
; ----------------------------------------
gen_code        .proc
                cpyb    fade_template, fade1, #size(fade_template), #768
                cpyb    fade_template, fade2, #size(fade_template), #768
                lda     rts_template
                sta     fade1 + (size(fade_template) * 768)
                sta     fade2 + (size(fade_template) * 768)
                rts

fade_template   .block
                lda     dummy
*               = * - 2
lda_addr        .word   ?
                tay
                lda     fade, y
                sta     dummy
*               = * - 2
sta_addr        .word   ?
                .bend

rts_template    .block
                rts
                .bend

.section        data
dummy           .byte   $00
.send

; A fade rutinon belül az LDA paraméterének relatív memóriacíme
FADE_LDA_OFFSET     = #(fade_template.lda_addr - fade_template)
; A fade rutinon belül az STA paraméterének relatív memóriacíme
FADE_STA_OFFSET     = #(fade_template.sta_addr - fade_template)       

fade1             = $B000
fade2             = $E000

                .pend

; ----------------------------------------
; framerate mérése
; ----------------------------------------
calc_framerate  .proc
                lda     current_frame
                sta     frame_rate
                lda     #$00
                sta     current_frame
                rts
.section        data
frame_rate      .byte   $00
current_frame   .byte   $00
.send                
                .pend

; ----------------------------------------
; IRQ #10 / Playing the music
; ----------------------------------------
irq10           .proc
                sta		rea10+1		; Preserve A,X and Y registers
                stx		rex10+1
                sty		rey10+1

                inc     calc_framerate.current_frame
;               jsr		$e003

                asl		$d019		; Acknowledge IRQ				
rea10           lda		#$00    	; Reload A,X,and Y registers
rex10           ldx		#$00
rey10           ldy		#$00
                rti		
                .pend

; ----------------------------------------
; IRQ #10 / Playing the music
; ----------------------------------------
nmi             .proc
                rti
                .pend
.send

.section        data
.include        "tables.asm"
.send
