                .cpu "6502"
                .enc "screen"

.include "macros.asm"
.include "plot.asm"

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
SPRITE1_POINTER1  = VIC_BASE_ADDRESS1 + $07f8
SPRITE2_POINTER1  = VIC_BASE_ADDRESS1 + $07f9
SPRITE3_POINTER1  = VIC_BASE_ADDRESS1 + $07fa
SPRITE4_POINTER1  = VIC_BASE_ADDRESS1 + $07fb
SPRITE5_POINTER1  = VIC_BASE_ADDRESS1 + $07fc
SPRITE6_POINTER1  = VIC_BASE_ADDRESS1 + $07fd
SPRITE7_POINTER1  = VIC_BASE_ADDRESS1 + $07fe
SPRITE8_POINTER1  = VIC_BASE_ADDRESS1 + $07ff
SPRITE_DATA1      = VIC_BASE_ADDRESS1 + $0C00
VIC_BASE_ADDRESS2 = $4000
BITMAP_ADDRESS2   = VIC_BASE_ADDRESS2 + $2000
COLOR1_ADDRESS2   = VIC_BASE_ADDRESS2 + $0400
SPRITE1_POINTER2  = VIC_BASE_ADDRESS2 + $07f8
SPRITE2_POINTER2  = VIC_BASE_ADDRESS2 + $07f9
SPRITE3_POINTER2  = VIC_BASE_ADDRESS2 + $07fa
SPRITE4_POINTER2  = VIC_BASE_ADDRESS2 + $07fb
SPRITE5_POINTER2  = VIC_BASE_ADDRESS2 + $07fc
SPRITE6_POINTER2  = VIC_BASE_ADDRESS2 + $07fd
SPRITE7_POINTER2  = VIC_BASE_ADDRESS2 + $07fe
SPRITE8_POINTER2  = VIC_BASE_ADDRESS2 + $07ff
SPRITE_DATA2      = VIC_BASE_ADDRESS2 + $0C00

COLOR2_ADDRESS    = $d800

COLOR0            = BLACK
COLOR1            = WHITE
COLOR2            = LIGHT_BLUE
COLOR3            = BLUE

SPRITE_COLOR1     = YELLOW
SPRITE_COLOR2     = ORANGE
SPRITE_COLOR3     = BROWN

.section        data
fade1_curr_addr   .addr ?
fade2_curr_addr   .addr ?
cnt_start_effect  .byte 42
.send

; ----------------------------------------
; *ENTRY
; ----------------------------------------
.section        code

                jsr     init
                jsr     effect0.init

-               
                set_addr    gen_code.fade1, fade1_curr_addr
                set_addr    gen_code.fade2, fade2_curr_addr

                ; 6 képernyőnként kell resetelni a plot rutinban a pointereket,
                ; ezért itt hatszor meghívjuk az effektet
                .for i := 0, i < 3, i += 1
                
                cpy16   fade2_curr_addr, fade_curr_addr
                jsr     calc_framerate
                jsr     effect0
                jsr     switch_bank2
                jsr     gen_code.fade1
                cpy16   fade_curr_addr, fade2_curr_addr

                cpy16   fade1_curr_addr, fade_curr_addr
                jsr     calc_framerate
                jsr     effect0
                jsr     switch_bank1
                jsr     gen_code.fade2
                cpy16   fade_curr_addr, fade1_curr_addr

                .next

                dec     cnt_start_effect
                beq     +
                jmp     -
+
-
                set_addr    gen_code.fade1, fade1_curr_addr
                set_addr    gen_code.fade2, fade2_curr_addr

                ; 6 képernyőnként kell resetelni a plot rutinban a pointereket,
                ; ezért itt hatszor meghívjuk az effektet
                .for i := 0, i < 3, i += 1
                
                cpy16   fade2_curr_addr, fade_curr_addr
                jsr     calc_framerate
                jsr     effect1
                jsr     switch_bank2
                jsr     gen_code.fade1
                cpy16   fade_curr_addr, fade2_curr_addr

                cpy16   fade1_curr_addr, fade_curr_addr
                jsr     calc_framerate
                jsr     effect1
                jsr     switch_bank1
                jsr     gen_code.fade2
                cpy16   fade_curr_addr, fade1_curr_addr

                .next

                jmp     -

; ----------------------------------------
; VIC bank váltás
; Rutinok címeinek a beállítása
; ----------------------------------------

.section        zeropage
cnt0            .byte   ?
count           .byte   ?
posx1           .byte   ?
posy1           .byte   ?
posx2           .byte   ?
posy2           .byte   ?
prevx           .byte   ?
prevy           .byte   ?
.send

effect0         .proc

                lda     #$00
                sta     count

                clc
effect_next:    ldx     posx1
                lda     sinx, x
                inx
                stx     posx1
                ldx     posx2
                adc     sin, x
                inx
                inx
                inx
                stx     posx2
                tax

                ldy     posy1
                lda     siny, y
                iny
                sty     posy1
                ldy     posy2
                adc     sin, y
                iny
                iny
                sty     posy2
                tay

                lda     cnt0
                cmp     count
                bcs     +
                ldx     prevx
                ldy     prevy
                jmp     ++
+
                stx     prevx
                sty     prevy
+               #plot


                dec     count
                bne     effect_next
                
                lda     cnt0
                inc     cnt0
                tay
                lsr
                lsr     
                lsr     
                lsr     
                lsr     
                tay     
                lda     sprite_enabled, y
                sta     $d015
                
                
                inc     posx1
                inc     posy1
                inc     posy1
                rts

init            lda     #$00
                sta     count
                sta     posx1
                lda     #$40
                sta     posy1
                lda     #$20
                sta     posx2
                lda     #$50
                sta     posy2
                lda     #$00
                sta     cnt0
                rts

                .pend

effect1         .proc

                lda     #$00
                sta     count

                clc
effect_next:    ldx     posx1
                lda     sinx, x
                inx
                stx     posx1
                ldx     posx2
                adc     sin, x
                inx
                inx
                inx
                stx     posx2
                tax

                ldy     posy1
                lda     siny, y
                iny
                sty     posy1
                ldy     posy2
                adc     sin, y
                iny
                iny
                sty     posy2
                tay

                #plot

+               dec     count
                bne     effect_next

                inc     posx1
                inc     posy1
                inc     posy1
                rts

                .pend

; ----------------------------------------
; VIC bank váltás az 1. bankra
; ----------------------------------------
switch_bank1    .proc
                ; A plotter rutin táblázatainak módosítása
                ; (mivel az 1-es VIC-blank-ot mutatjuk a másikat rajzoljuk)
                set_addr    ytablelow2,     ytablelo_addr
                set_addr    ytablehigh2,    ytablehi_addr
                lda     $dd00
                and     #%11111100              ; VIC bank mask
                ora     VIC_BANK1
                sta     $dd00
                rts
                .pend

; ----------------------------------------
; VIC bank váltás az 2. bankra
; ----------------------------------------
switch_bank2    .proc
                ; A plotter rutin táblázatainak módosítása
                ; (mivel az 1-es VIC-blank-ot mutatjuk a másikat rajzoljuk)
                set_addr    ytablelow1,     ytablelo_addr
                set_addr    ytablehigh1,    ytablehi_addr
                lda     $dd00
                and     #%11111100              ; VIC bank mask
                ora     VIC_BANK2
                sta     $dd00
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
                set_addr    nmi, $fffa

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
                set_addr    irq10, $fffe

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
                fill_block  BITMAP_ADDRESS1, #8000, #0
                fill_block  BITMAP_ADDRESS2, #8000, #0
                fill_block  COLOR1_ADDRESS1, #1000, #((COLOR3 << 4) + COLOR2)
                fill_block  COLOR1_ADDRESS2, #1000, #((COLOR3 << 4) + COLOR2)
                fill_block  COLOR2_ADDRESS,  #1000, #(COLOR1)

                copy_block  sprite0, SPRITE_DATA1, #(64 * 8), #1 
                copy_block  sprite0, SPRITE_DATA2, #(64 * 8), #1 

                ; VIC mem schema
                lda     VIC_MEM_SCHEMA
                sta     $d018

                jsr     switch_bank1

                ; Multicolor bitmap mode
                lda     #$3b
                sta     $d011
                lda     #$18
                sta     $d016

                lda     #(SPRITE_COLOR3)
                sta     $d025
                lda     #(SPRITE_COLOR1)
                sta     $d026
                lda     #(SPRITE_COLOR2)
                sta     $d027
                sta     $d028
                sta     $d029
                sta     $d02a
                sta     $d02b
                sta     $d02c
                sta     $d02d
                sta     $d02e

SPRITE_POS = (380 / 2) - (30 * 8 / 2)

                lda     #(SPRITE_POS + (30 * 0))
                sta     $d000
                lda     #(SPRITE_POS + (30 * 1))
                sta     $d002
                lda     #(SPRITE_POS + (30 * 2))
                sta     $d004
                lda     #(SPRITE_POS + (30 * 3))
                sta     $d006
                lda     #(SPRITE_POS + (30 * 4))
                sta     $d008
                lda     #(SPRITE_POS + (30 * 5))
                sta     $d00a
                lda     #(SPRITE_POS + (30 * 6))
                sta     $d00c
                lda     #((SPRITE_POS + (30 * 7)) & 255) 
                sta     $d00e

                lda     #%10000000
                sta     $d010

                lda     #140
                sta     $d001
                sta     $d003
                sta     $d005
                sta     $d007
                sta     $d009
                sta     $d00b
                sta     $d00d
                sta     $d00f

                lda     #00
                sta     $d015
                
                lda     #$00
                sta     $d017
                sta     $d01e
                sta     $d01f

                lda     #$00
                sta     $d01b

                lda     #$ff
                sta     $d01c

                lda     #$30
                sta     SPRITE1_POINTER1
                sta     SPRITE1_POINTER2
                lda     #$31
                sta     SPRITE2_POINTER1
                sta     SPRITE2_POINTER2
                lda     #$32
                sta     SPRITE3_POINTER1
                sta     SPRITE3_POINTER2
                lda     #$33
                sta     SPRITE4_POINTER1
                sta     SPRITE4_POINTER2
                lda     #$34
                sta     SPRITE5_POINTER1
                sta     SPRITE5_POINTER2
                lda     #$35
                sta     SPRITE6_POINTER1
                sta     SPRITE6_POINTER2
                lda     #$36
                sta     SPRITE7_POINTER1
                sta     SPRITE7_POINTER2
                lda     #$37
                sta     SPRITE8_POINTER1
                sta     SPRITE8_POINTER2

                rts

                .pend

; ----------------------------------------
; fade1, fade2 rutinok generálása
; ----------------------------------------
gen_code        .proc
                copy_block  fade_template, fade1, #size(fade_template), #768
                copy_block  fade_template, fade2, #size(fade_template), #768
                lda     rts_template
                sta     fade1 + (size(fade_template) * 768)
                sta     fade2 + (size(fade_template) * 768)
                rts

fade_template   .block
                ldy     dummy
*               = * - 2
lda_addr        .word   ?
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

                #wait_new_frame

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
                sta		rea10+1		    ; Preserve A,X and Y registers
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
.include        "sprites.asm"
.align          256
sprite_enabled  .byte %00000001
                .byte %00100001
                .byte %00100101
                .byte %10100101
                .byte %10101101
                .byte %11101101
                .byte %11101111
                .byte %11111111

.send
