import cv2
import numpy as np

import c64

# Ennyi karakter van
c = 8

# Az első betű pozíciója
yo = 5
xo = 4
# Szélesség magasság
ho = wo = 24

# A konvertált első betű Y pozíciója
yn = 0
# A konvertált szélesség, magasság
wn = 12
hn = 21

# Színek felmappelése C64 színekre
colors = {
    "0,0,0": c64.BLACK,
    "2,2,2": c64.BLACK,
    "0,57,67": c64.BROWN,
    "37,79,111": c64.ORANGE,
    "108,108,108": c64.YELLOW
}

# Bitmap kódok
bm = {
    c64.BLACK["colorCode"]: 0,
    c64.BROWN["colorCode"]: 1,
    c64.ORANGE["colorCode"]: 2,
    c64.YELLOW["colorCode"]: 3
}

newimg = np.zeros((hn * c, wn, 3), np.uint8)
c64img = np.zeros((hn * c * wn) >> 2, np.uint8)


def find_c64_color(rgb):
    key = "" + str(rgb[0]) + "," + str(rgb[1]) + "," + str(rgb[2])
    c64c = colors.get(key)
    if c64c is None or c64c == "NOT MAPPED":
        print("NOT MAPPED: " + key)
        colors[key] = c64.BLACK
        return c64.BLACK
    return c64c


image = cv2.imread("logo.png");

i = 0
while i < c:
    crop_image = image[yo:yo + ho - (ho - hn), xo:xo + wo]
    newimg[yn:yn + hn, 0:wn] = cv2.resize(crop_image, (wn, hn), interpolation=cv2.INTER_NEAREST)
    yn += hn
    xo += wo
    i += 1

shl = [6, 4, 2, 0]

p = 0
for i, row in enumerate(newimg):
    for j, pix in enumerate(row):
        c64color = find_c64_color(pix)
        rgb = c64color["rgb"]
        colorCode = c64color["colorCode"]
        newimg[i, j] = (rgb[2], rgb[1], rgb[0])
        bitmask = bm[colorCode]
        c64img[p >> 2] |= bitmask << shl[p & 3]
        p += 1


cnt = 0
p = 0
while p < np.size(c64img):
    if p % (21 * 3) == 0:
        print("")
        print(".align 64")
        print("sprite" + str(cnt), end=" ")
        cnt += 1
    else:
        print("  ", end="")
    if p % 3 == 0:
        print(".byte", end=" ")
        print("%{0:{fill}8b}".format(c64img[p], fill="0"), end=", ")
        print("%{0:{fill}8b}".format(c64img[p + 1], fill="0"), end=", ")
        print("%{0:{fill}8b}".format(c64img[p + 2], fill="0"), end="\n")
    p += 1

cv2.imshow("Converted", cv2.resize(newimg, (wn * 3, hn * c * 3), interpolation=cv2.INTER_NEAREST))

cv2.waitKey(0)
