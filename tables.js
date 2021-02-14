fs = require('fs');

const VIC_BASE_ADDR1 = 0x0000
const  BITMAP_ADDR1 = VIC_BASE_ADDR1 + 0x02000

const VIC_BASE_ADDR2 = 0x4000
const  BITMAP_ADDR2 = VIC_BASE_ADDR2 + 0x02000

const maskAnd = [0b00111111, 0b11001111, 0b11110011, 0b11111100]
const maskOr1 = [0b01000000, 0b00010000, 0b00000100, 0b00000001]
const maskOr2 = [0b10000000, 0b00100000, 0b00001000, 0b00000010]
const maskOr3 = [0b11000000, 0b00110000, 0b00001100, 0b00000011]

const overflow = (i, m) => i >= m ? 0 : i;
const lowbyte = (i) => i & 255
const highbyte = (i) => i >> 8
const hex = (i) => "$" + (i < 16 ? "0" : "") + i.toString(16);

const calcy = (i, addr) => (i & 0b00000111) + 320 * (i >> 3) + addr

const calcx = (i) => (i >> 2) << 3

const calcm = (i, m) => m[i & 3]

const sint = (i) => Math.sin(i * Math.PI / 128.0) * 50 + 50

const fade = (i) => {
    res = 0
    shl = [0, 2, 4, 6]
    shl.forEach(s => {
        x = (i >> s) & 3
        if (x > 0) {
            x--;
        }
        res |= x << s
    })
    return res
}

const dump = (str, tablename, calc) => {
    str.push(tablename)
    for (i = 0; i < 256; i++) {
        str.push(i % 16 == 0 ? '\n\t.byte ' : ', ') 
        str.push(calc(i))
    }
    str.push('\n\n')
    return str
}

var content = ['.align 256\n']
dump(content, "ytablelow1", i => hex(lowbyte(calcy(overflow(i, 200), BITMAP_ADDR1))))
dump(content, "ytablehigh1", i => hex(highbyte(calcy(overflow(i, 200), BITMAP_ADDR1))))
dump(content, "ytablelow2", i => hex(lowbyte(calcy(overflow(i, 200), BITMAP_ADDR2))))
dump(content, "ytablehigh2", i => hex(highbyte(calcy(overflow(i, 200), BITMAP_ADDR2))))
dump(content, "xtablelow", i => hex(lowbyte(calcx(overflow(i, 160)))))
dump(content, "xtablehigh", i => hex(highbyte(calcx(overflow(i, 160)))))
dump(content, "maskand", i => hex(lowbyte(calcm(i, maskAnd))))
dump(content, "mask", i => hex(lowbyte(calcm(i, maskOr3))))
dump(content, "sin", i => hex(lowbyte(sint(i))))
dump(content, "fade", i => hex(lowbyte(fade(i))))

const data = content.join('')
fs.writeFile('tables.inc', data, 'UTF-8', function (err) {
    if (err) return console.log(err);
    console.log('tables.js > tables.inc');
});
