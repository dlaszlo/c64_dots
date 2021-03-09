
*               = $02
.dsection       zeropage
.cerror         * > $30, "To many zero page variables!"

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
; Zero page pointerek
; ----------------------------------------
.section        zeropage
ptr1            .addr ?
ptr2            .addr ?
cnt1            .addr ?
cnt2            .addr ?
.send

; ----------------------------------------
; Cím módosítás (makró bájtkód manipuláláshoz)
;
; Paraméterek:
;   src_addr: Beirandó cím
;   src_addr: Utasítás címe
; ----------------------------------------
moda            .function src_addr, dst_addr
                seta    src_addr, dst_addr + 1
                .endf

; ----------------------------------------
; Cím növelése 1-el (makró bájtkód manipuláláshoz)
;
; Paraméterek:
;   opcode_addr: Utasítás címe
; ----------------------------------------
inca            .function opcode_addr
                incw    opcode_addr + 1
                .endf

; ----------------------------------------
; Memória cím beírása adott címre
;
; Paraméterek:
;   src_addr: memória cím
;   dst_addr: cél cím
; ----------------------------------------
seta            .function src_addr, dst_addr
                ldx     #<src_addr
                stx     dst_addr
                ldx     #>src_addr
                stx     dst_addr + 1
                .endf

; ----------------------------------------
; Word beírása adott címre
;
; Paraméterek:
;   val:      érték
;   dst_addr: cél cím
; ----------------------------------------
setw            .function val, dst_addr
                ldx     <val
                stx     dst_addr
                ldx     >val
                stx     dst_addr + 1
                .endf

; ----------------------------------------
; Word növelése 1-el
;
; Paraméterek:
;   addr: Memóriacím, ahol a word van
; ----------------------------------------
incw            .function addr
                inc     addr
                bne     +
                inc     addr + 1
+               .endf

; ----------------------------------------
; Word csökkentése 1-el
;
; Paraméterek:
;   addr: Memóriacím, ahol a word van
; ----------------------------------------
decw            .function addr
                ldy     addr
                bne     +
                dec     addr + 1
+               dey
                sty     addr
                .endf

; ----------------------------------------
; Ugrás, ha a megadott word nem nulla
;
; Paraméterek:
;   word: A word, amit ellenőrzünk
;   addr: Cím, ahova ugrani kell, ha nem nulla a word értéke
; ----------------------------------------
bnew            .function val, addr
                lda     val
                bne     addr
                lda     val + 1
                bne     addr
                .endf

; ----------------------------------------
; Memória terület feltöltése a megadott byte-al (sorok, és oszlopok alapján)
;
; Paraméterek:
;   addr: Memóriacím
;   count: byte-ok száma
;   val:  Bájt, amivel feltöltjük a memóriát
; ----------------------------------------
fill            .function addr, count, val
                setw    count, cnt1
                seta    addr,  ptr1
-               ldy     #00
                lda     val
                sta     (ptr1), y
                incw    ptr1
                decw    cnt1
                bnew    cnt1, -
                .endf

; ----------------------------------------
; Block másolása kód generáláshoz
;
; Paraméterek:
;   src_addr:   Template kód memória címe
;   dst_addr:   Generált kód címe
;   block_size: A template kód mérete
;   count:      A template kódot ennyiszer másoljuk egymás után
; ----------------------------------------
cpyb            .function src_addr, dst_addr, block_size, count
                seta    dst_addr, ptr2
                setw    count, cnt2
-               seta    src_addr, ptr1
                setw    block_size, cnt1
-               ldy     #00
                lda     (ptr1), y
                sta     (ptr2), y
                incw    ptr1
                incw    ptr2
                decw    cnt1
                bnew    cnt1, -
                decw    cnt2
                bnew    cnt2, --
                .endf
