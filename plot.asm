
.section        zeropage
plotaddr          .addr ?
fade_curr_addr    .addr ?
ytablelo_addr     .addr ?
ytablehi_addr     .addr ?
.send

; ----------------------------------------
; Képpont rajzolása
; Paraméterek: x, y
; ----------------------------------------
plot            .macro
                clc                
                lda     (ytablelo_addr), y
                adc     xtablelow, x
                sta     plotaddr

                lda     (ytablehi_addr), y
                adc     xtablehigh, x
                sta     plotaddr + 1

                ldy     gen_code.FADE_LDA_OFFSET + 1
                sta     (fade_curr_addr), y
                ldy     gen_code.FADE_STA_OFFSET + 1
                sta     (fade_curr_addr), y

                ldy     #$00
                lda     (plotaddr), y
                ora     mask, x
                sta     (plotaddr), y

                lda     plotaddr
                ldy     gen_code.FADE_LDA_OFFSET
                sta     (fade_curr_addr), y
                ldy     gen_code.FADE_STA_OFFSET
                sta     (fade_curr_addr), y

                lda     fade_curr_addr
                adc     #size(gen_code.fade_template)
                sta     fade_curr_addr
                bcc     +
                inc     fade_curr_addr + 1
+
                .endm
