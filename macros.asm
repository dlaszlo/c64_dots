
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
mod_addr        .function src_addr, dst_addr
                set_addr    src_addr, dst_addr + 1
                .endf

; ----------------------------------------
; Cím növelése 1-el (makró bájtkód manipuláláshoz)
;
; Paraméterek:
;   opcode_addr: Utasítás címe
; ----------------------------------------
inc_addr        .function opcode_addr
                inc16   opcode_addr + 1
                .endf

; ----------------------------------------
; Memória cím beírása adott címre
;
; Paraméterek:
;   src_addr: memória cím
;   dst_addr: cél cím
; ----------------------------------------
set_addr        .function src_addr, dst_addr
                ldx     #<src_addr
                stx     dst_addr
                ldx     #>src_addr
                stx     dst_addr + 1
                .endf

; ----------------------------------------
; Word másolása
;
; Paraméterek:
;   src: forrás cím
;   dst: cél cím
; ----------------------------------------
cpy16           .function src, dst
                lda     src
                sta     dst
                lda     src + 1
                sta     dst + 1
                .endf


; ----------------------------------------
; Word beírása adott címre
;
; Paraméterek:
;   val:      érték
;   dst_addr: cél cím
; ----------------------------------------
set16            .function val, dst_addr
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
inc16            .function addr
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
dec16            .function addr
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
bne16            .function val, addr
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
fill_block      .function addr, count, val
                set16   count, cnt1
                set_addr    addr,  ptr1
-               ldy     #00
                lda     val
                sta     (ptr1), y
                inc16    ptr1
                dec16   cnt1
                bne16   cnt1, -
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
copy_block      .function src_addr, dst_addr, block_size, count
                set_addr dst_addr, ptr2
                set16   count, cnt2
-               set_addr src_addr, ptr1
                set16   block_size, cnt1
-               ldy     #00
                lda     (ptr1), y
                sta     (ptr2), y
                inc16   ptr1
                inc16   ptr2
                dec16   cnt1
                bne16   cnt1, -
                dec16   cnt2
                bne16   cnt2, --
                .endf

; ----------------------------------------
; Új frame megvárása
; ----------------------------------------
wait_new_frame  .macro
-               bit     $d011
                bpl     -
-               bit     $d011
                bmi     -
                .endm
