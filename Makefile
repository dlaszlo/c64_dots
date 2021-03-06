VICE = d:/c64/vice/x64sc.exe 
TASS = d:/c64/tools/64tass.exe
BYTEBOOZER2 = d:/c64/tools/b2.exe
NODE = node.exe
PROGRAM = dots

RM = del /Q /F
CP = copy

all: $(PROGRAM).prg
	$(VICE) $<

$(PROGRAM).prg: $(PROGRAM).tmp
	$(BYTEBOOZER2) -c 8000 $<
	$(CP) $<.b2 $@

$(PROGRAM).tmp: $(PROGRAM).asm
	$(NODE) tables.js
	$(TASS) -C -a $< -o $@ -L $(PROGRAM).lst --verbose-list -l $(PROGRAM).sym

.INTERMEDIATE: $(PROGRAM).tmp
.PHONY: all clean
clean:
	$(RM) $(PROGRAM).prg $(PROGRAM).tmp $(PROGRAM).lst $(PROGRAM).sym $(PROGRAM).tmp.b2
