
A logo_to_sprite.py program egy logot convertál sprite-okra.

A program futtatásához python3-at kell telepíteni, illetve opencv, imutils, és numpy package-et.

```
pip install opencv-contrib-python
pip install imutils
pip install numpy
```

Ha valaki másra is használja a python-t, akkor javasolt virtualenv-et létrehoznia:

https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/

A logo-t a következő weboldallal generáltam:

https://codepo8.github.io/logo-o-matic/#goto-orc

A program futtatása:

```
python logo_to_sprites.py >> sprites.asm
```

A logot_to_sprites.py-ben át kell írni a kép méreteit, és a szín mappeléseket. A program multicolor sprite-ot hoz létre.

A beneti kép paraméterei:

```python
# Ennyi karakter van
c = 8

# Az első betű pozíciója
yo = 5
xo = 4
# Szélesség magasság (egy karakter)
ho = wo = 24
```

A sprite-ok paraméterei fixek (yn, wn, hn paraméterek).

A színek map-elését a következő két map-ben kell megadni:

```python
# Színek felmappelése C64 színekre
colors = {
"0,0,0": c64.BLACK,
"2,2,2": c64.BLACK,
"0,57,67": c64.BROWN,
"37,79,111": c64.ORANGE,
"108,108,108": c64.YELLOW
}

# Bitmap kódok (amik a sprite-ba kerülnek pixelenként)
bm = {
c64.BLACK["colorCode"]: 0,
c64.BROWN["colorCode"]: 1,
c64.ORANGE["colorCode"]: 2,
c64.YELLOW["colorCode"]: 3
}
```
