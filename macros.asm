
; ----------------------------------------
; Színek
; ----------------------------------------
BLACK             = $00
WHITE             = $01
RED               = $02
CYAN              = $03
PURPLE            = $04
GREEN             = $05
BLUE              = $06
YELLOW            = $07
ORANGE            = $08
BROWN             = $09
PINK              = $0A
DARK_GREY         = $0B
GREY              = $0C
LIGHT_GREEN       = $0D
LIGHT_BLUE        = $0E
LIGHT_GREY        = $0F

; ----------------------------------------
; Cím módosítás makró bájtkód manipuláláshoz
; param1: cím, param2: utasítás címe
; ----------------------------------------
mod_addr        .macro
                #set_addr \1, \2 + 1
                .endm

; ----------------------------------------
; Memória cím beírása adott címre
; param1: memória cím, param2: cél cím
; ----------------------------------------
set_addr        .macro
                ldx     #<\1
                stx     \2
                ldx     #>\1
                stx     \2 + 1
                .endm

; ----------------------------------------
; A címen lévő word-hoz byte hozzáadása
; param1: memória cím: param2: hozzáadandó byte
; ----------------------------------------
add_word        .macro
                lda     \1
                clc
                adc     \2
                bcc     +
                inc     \1 + 1
+               sta     \1
                .endm
                