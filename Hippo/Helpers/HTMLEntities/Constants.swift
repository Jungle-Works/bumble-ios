/*
 * Copyright IBM Corporation 2016, 2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Linux toolchain requires Foundation to resolve `String` class's `hasSuffix()` function
#if os(Linux)
    import Foundation
#endif

// Replacement character U+FFFD
let replacementCharacterAsUInt32: UInt32 = 0xFFFD

// Generated from
// https://www.w3.org/TR/html5/syntax.html#tokenizing-character-references
// "Find the row with that number in the first column, and return a character token for
// the Unicode character given in the second column of that row."
let deprecatedNumericDecodeMap: [UInt32: UInt32] = [
    0x00:0xFFFD,0x80:0x20AC,0x82:0x201A,0x83:0x0192,0x84:0x201E,0x85:0x2026,0x86:0x2020,
    0x87:0x2021,0x88:0x02C6,0x89:0x2030,0x8A:0x0160,0x8B:0x2039,0x8C:0x0152,0x8E:0x017D,
    0x91:0x2018,0x92:0x2019,0x93:0x201C,0x94:0x201D,0x95:0x2022,0x96:0x2013,0x97:0x2014,
    0x98:0x02DC,0x99:0x2122,0x9A:0x0161,0x9B:0x203A,0x9C:0x0153,0x9E:0x017E,0x9F:0x0178
]

// Generated from
// https://www.w3.org/TR/html5/syntax.html#tokenizing-character-references
// "[I]f the number is in the range 0x0001 to 0x0008, 0x000D to 0x001F, 0x007F
// to 0x009F, 0xFDD0 to 0xFDEF, or is one of 0x000B, 0xFFFE, 0xFFFF, 0x1FFFE,
// 0x1FFFF, 0x2FFFE, 0x2FFFF, 0x3FFFE, 0x3FFFF, 0x4FFFE, 0x4FFFF, 0x5FFFE,
// 0x5FFFF, 0x6FFFE, 0x6FFFF, 0x7FFFE, 0x7FFFF, 0x8FFFE, 0x8FFFF, 0x9FFFE,
// 0x9FFFF, 0xAFFFE, 0xAFFFF, 0xBFFFE, 0xBFFFF, 0xCFFFE, 0xCFFFF, 0xDFFFE,
// 0xDFFFF, 0xEFFFE, 0xEFFFF, 0xFFFFE, 0xFFFFF, 0x10FFFE, or 0x10FFFF, then
// this is a parse error."
let disallowedNumericReferences: Set<UInt32> = [
    0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0xB,0xD,0xE,0xF,0x10,0x11,0x12,0x13,0x14,0x15,0x16,
    0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,0x1F,0xFDD0,0xFDD1,0xFDD2,0xFDD3,0xFDD4,
    0xFDD5,0xFDD6,0xFDD7,0xFDD8,0xFDD9,0xFDDA,0xFDDB,0xFDDC,0xFDDD,0xFDDE,0xFDDF,0xFDE0,
    0xFDE1,0xFDE2,0xFDE3,0xFDE4,0xFDE5,0xFDE6,0xFDE7,0xFDE8,0xFDE9,0xFDEA,0xFDEB,0xFDEC,
    0xFDED,0xFDEE,0xFDEF,0xFFFE,0xFFFF,0x1FFFE,0x1FFFF,0x2FFFE,0x2FFFF,0x3FFFE,0x3FFFF,
    0x4FFFE,0x4FFFF,0x5FFFE,0x5FFFF,0x6FFFE,0x6FFFF,0x7FFFE,0x7FFFF,0x8FFFE,0x8FFFF,
    0x9FFFE,0x9FFFF,0xAFFFE,0xAFFFF,0xBFFFE,0xBFFFF,0xCFFFE,0xCFFFF,0xDFFFE,0xDFFFF,
    0xEFFFE,0xEFFFF,0xFFFFE,0xFFFFF,0x10FFFE,0x10FFFF
]

// Only encode to named character references that end with ;
// If multiple exists for a given character, i.e., 'AMP;' and 'amp;', pick the one
// that is shorter and/or all lowercase
let hippoNamedCharactersEncodeMap = hippoNamedCharactersDecodeMap.inverting() {
    existing, new in
    let isExistingLegacy = !existing.hasSuffix(";")
    let isNewLegacy = !new.hasSuffix(";")
    
    #if swift(>=3.2)
    let existingCount = existing.count
    let newCount = new.count
    #else
    let existingCount = existing.characters.count
    let newCount = new.characters.count
    #endif
    
    if isExistingLegacy && !isNewLegacy {
        // prefer non-legacy
        return new
    }
    
    if !isExistingLegacy && isNewLegacy {
        // prefer non-legacy
        return existing
    }
    
    if existingCount < newCount {
        // if both are same type, prefer shorter name
        return existing
    }
    
    if newCount < existingCount {
        // if both are same type, prefer shorter name
        return new
    }
    
    if new == new.lowercased() {
        // if both are same type and same length, prefer lowercase name
        return new
    }
    
    // new isn't better than existing
    // return existing
    return existing
}

// Only encode to named character references that end with ;
// If multiple exists for a given character, i.e., 'AMP;' and 'amp;', pick the one
// that is shorter and/or all lowercase
let namedCharactersEncodeMap = namedCharactersDecodeMap.inverting() {
    existing, new in
    let isExistingLegacy = !existing.hasSuffix(";")
    let isNewLegacy = !new.hasSuffix(";")

    #if swift(>=3.2)
        let existingCount = existing.count
        let newCount = new.count
    #else
        let existingCount = existing.characters.count
        let newCount = new.characters.count
    #endif

    if isExistingLegacy && !isNewLegacy {
        // prefer non-legacy
        return new
    }

    if !isExistingLegacy && isNewLegacy {
        // prefer non-legacy
        return existing
    }

    if existingCount < newCount {
        // if both are same type, prefer shorter name
        return existing
    }

    if newCount < existingCount {
        // if both are same type, prefer shorter name
        return new
    }

    if new == new.lowercased() {
        // if both are same type and same length, prefer lowercase name
        return new
    }

    // new isn't better than existing
    // return existing
    return existing
}

// Entities that map to more than one character in Swift
// E.g., their decoded form spans more than one extended grapheme cluster
let specialNamedCharactersDecodeMap: [String: String] = [
    "fjlig;":"\u{66}\u{6A}",
    "ThickSpace;":"\u{205F}\u{200A}"
]

// Range of string lengths of legacy named characters
// Should be 2...6, but generate statically to avoid hardcoding numbers
let legacyNamedCharactersLengthRange: CountableClosedRange<Int> = { () -> CountableClosedRange<Int> in
    var min = Int.max, max = Int.min

    for (name, _) in legacyNamedCharactersDecodeMap {
        #if swift(>=3.2)
            let length = name.count
        #else
            let length = name.characters.count
        #endif
        min = length < min ? length : min
        max = length > max ? length : max
    }

    return min...max
}()

// Named character references that may be parsed without an ending ;
let legacyNamedCharactersDecodeMap: [String: Character] = [
    "Aacute":Character(Unicode.Scalar(0xC1)!),"aacute":Character(Unicode.Scalar(0xE1)!),"Acirc":Character(Unicode.Scalar(0xC2)!),"acirc":Character(Unicode.Scalar(0xE2)!),
    "acute":Character(Unicode.Scalar(0xB4)!),"AElig":Character(Unicode.Scalar(0xC6)!),"aelig":Character(Unicode.Scalar(0xE6)!),"Agrave":Character(Unicode.Scalar(0xC0)!),
    "agrave":Character(Unicode.Scalar(0xE0)!),"AMP":Character(Unicode.Scalar(0x26)!),"amp":Character(Unicode.Scalar(0x26)!),"Aring":Character(Unicode.Scalar(0xC5)!),
    "aring":Character(Unicode.Scalar(0xE5)!),"Atilde":Character(Unicode.Scalar(0xC3)!),"atilde":Character(Unicode.Scalar(0xE3)!),"Auml":Character(Unicode.Scalar(0xC4)!),
    "auml":Character(Unicode.Scalar(0xE4)!),"brvbar":Character(Unicode.Scalar(0xA6)!),"Ccedil":Character(Unicode.Scalar(0xC7)!),"ccedil":Character(Unicode.Scalar(0xE7)!),
    "cedil":Character(Unicode.Scalar(0xB8)!),"cent":Character(Unicode.Scalar(0xA2)!),"COPY":Character(Unicode.Scalar(0xA9)!),"copy":Character(Unicode.Scalar(0xA9)!),
    "curren":Character(Unicode.Scalar(0xA4)!),"deg":Character(Unicode.Scalar(0xB0)!),"divide":Character(Unicode.Scalar(0xF7)!),"Eacute":Character(Unicode.Scalar(0xC9)!),
    "eacute":Character(Unicode.Scalar(0xE9)!),"Ecirc":Character(Unicode.Scalar(0xCA)!),"ecirc":Character(Unicode.Scalar(0xEA)!),"Egrave":Character(Unicode.Scalar(0xC8)!),
    "egrave":Character(Unicode.Scalar(0xE8)!),"ETH":Character(Unicode.Scalar(0xD0)!),"eth":Character(Unicode.Scalar(0xF0)!),"Euml":Character(Unicode.Scalar(0xCB)!),
    "euml":Character(Unicode.Scalar(0xEB)!),"frac12":Character(Unicode.Scalar(0xBD)!),"frac14":Character(Unicode.Scalar(0xBC)!),"frac34":Character(Unicode.Scalar(0xBE)!),
    "GT":Character(Unicode.Scalar(0x3E)!),"gt":Character(Unicode.Scalar(0x3E)!),"Iacute":Character(Unicode.Scalar(0xCD)!),"iacute":Character(Unicode.Scalar(0xED)!),
    "Icirc":Character(Unicode.Scalar(0xCE)!),"icirc":Character(Unicode.Scalar(0xEE)!),"iexcl":Character(Unicode.Scalar(0xA1)!),"Igrave":Character(Unicode.Scalar(0xCC)!),
    "igrave":Character(Unicode.Scalar(0xEC)!),"iquest":Character(Unicode.Scalar(0xBF)!),"Iuml":Character(Unicode.Scalar(0xCF)!),"iuml":Character(Unicode.Scalar(0xEF)!),
    "laquo":Character(Unicode.Scalar(0xAB)!),"LT":Character(Unicode.Scalar(0x3C)!),"lt":Character(Unicode.Scalar(0x3C)!),"macr":Character(Unicode.Scalar(0xAF)!),
    "micro":Character(Unicode.Scalar(0xB5)!),"middot":Character(Unicode.Scalar(0xB7)!),"nbsp":Character(Unicode.Scalar(0xA0)!),"not":Character(Unicode.Scalar(0xAC)!),
    "Ntilde":Character(Unicode.Scalar(0xD1)!),"ntilde":Character(Unicode.Scalar(0xF1)!),"Oacute":Character(Unicode.Scalar(0xD3)!),"oacute":Character(Unicode.Scalar(0xF3)!),
    "Ocirc":Character(Unicode.Scalar(0xD4)!),"ocirc":Character(Unicode.Scalar(0xF4)!),"Ograve":Character(Unicode.Scalar(0xD2)!),"ograve":Character(Unicode.Scalar(0xF2)!),
    "ordf":Character(Unicode.Scalar(0xAA)!),"ordm":Character(Unicode.Scalar(0xBA)!),"Oslash":Character(Unicode.Scalar(0xD8)!),"oslash":Character(Unicode.Scalar(0xF8)!),
    "Otilde":Character(Unicode.Scalar(0xD5)!),"otilde":Character(Unicode.Scalar(0xF5)!),"Ouml":Character(Unicode.Scalar(0xD6)!),"ouml":Character(Unicode.Scalar(0xF6)!),
    "para":Character(Unicode.Scalar(0xB6)!),"plusmn":Character(Unicode.Scalar(0xB1)!),"pound":Character(Unicode.Scalar(0xA3)!),"QUOT":Character(Unicode.Scalar(0x22)!),
    "quot":Character(Unicode.Scalar(0x22)!),"raquo":Character(Unicode.Scalar(0xBB)!),"REG":Character(Unicode.Scalar(0xAE)!),"reg":Character(Unicode.Scalar(0xAE)!),
    "sect":Character(Unicode.Scalar(0xA7)!),"shy":Character(Unicode.Scalar(0xAD)!),"sup1":Character(Unicode.Scalar(0xB9)!),"sup2":Character(Unicode.Scalar(0xB2)!),
    "sup3":Character(Unicode.Scalar(0xB3)!),"szlig":Character(Unicode.Scalar(0xDF)!),"THORN":Character(Unicode.Scalar(0xDE)!),"thorn":Character(Unicode.Scalar(0xFE)!),
    "times":Character(Unicode.Scalar(0xD7)!),"Uacute":Character(Unicode.Scalar(0xDA)!),"uacute":Character(Unicode.Scalar(0xFA)!),"Ucirc":Character(Unicode.Scalar(0xDB)!),
    "ucirc":Character(Unicode.Scalar(0xFB)!),"Ugrave":Character(Unicode.Scalar(0xD9)!),"ugrave":Character(Unicode.Scalar(0xF9)!),"uml":Character(Unicode.Scalar(0xA8)!),
    "Uuml":Character(Unicode.Scalar(0xDC)!),"uuml":Character(Unicode.Scalar(0xFC)!),"Yacute":Character(Unicode.Scalar(0xDD)!),"yacute":Character(Unicode.Scalar(0xFD)!),
    "yen":Character(Unicode.Scalar(0xA5)!),"yuml":Character(Unicode.Scalar(0xFF)!)
]

// Split map into two halves; otherwise, segmentation fault when compiling
let namedCharactersDecodeMap = namedCharactersDecodeMap1.updating(namedCharactersDecodeMap2)
// Split map into two halves; otherwise, segmentation fault when compiling
let hippoNamedCharactersDecodeMap = hippoNamedCharactersDecodeMap1

let hippoNamedCharactersDecodeMap1: [String: Character] = [
    "gt;": Character(Unicode.Scalar(0x3E)!),
    "lt;": Character(Unicode.Scalar(0x3C)!),
    "amp;": Character(Unicode.Scalar(0x26)!),
    "quot;": Character(Unicode.Scalar(0x22)!),
    "apos;": Character(Unicode.Scalar(0x27)!)
]

let namedCharactersDecodeMap1: [String: Character] = [
    "Aacute;":Character(Unicode.Scalar(0xC1)!),"aacute;":Character(Unicode.Scalar(0xE1)!),"Abreve;":Character(Unicode.Scalar(0x102)!),"abreve;":Character(Unicode.Scalar(0x103)!),
    "ac;":Character(Unicode.Scalar(0x223E)!),"acd;":Character(Unicode.Scalar(0x223F)!),"acE;":"\u{223E}\u{333}","Acirc;":Character(Unicode.Scalar(0xC2)!),
    "acirc;":Character(Unicode.Scalar(0xE2)!),"acute;":Character(Unicode.Scalar(0xB4)!),"Acy;":Character(Unicode.Scalar(0x410)!),"acy;":Character(Unicode.Scalar(0x430)!),
    "AElig;":Character(Unicode.Scalar(0xC6)!),"aelig;":Character(Unicode.Scalar(0xE6)!),"af;":Character(Unicode.Scalar(0x2061)!),"Afr;":Character(Unicode.Scalar(0x1D504)!),
    "afr;":Character(Unicode.Scalar(0x1D51E)!),"Agrave;":Character(Unicode.Scalar(0xC0)!),"agrave;":Character(Unicode.Scalar(0xE0)!),"alefsym;":Character(Unicode.Scalar(0x2135)!),
    "aleph;":Character(Unicode.Scalar(0x2135)!),"Alpha;":Character(Unicode.Scalar(0x391)!),"alpha;":Character(Unicode.Scalar(0x3B1)!),"Amacr;":Character(Unicode.Scalar(0x100)!),
    "amacr;":Character(Unicode.Scalar(0x101)!),"amalg;":Character(Unicode.Scalar(0x2A3F)!),"AMP;":Character(Unicode.Scalar(0x26)!),"amp;":Character(Unicode.Scalar(0x26)!),
    "And;":Character(Unicode.Scalar(0x2A53)!),"and;":Character(Unicode.Scalar(0x2227)!),"andand;":Character(Unicode.Scalar(0x2A55)!),"andd;":Character(Unicode.Scalar(0x2A5C)!),
    "andslope;":Character(Unicode.Scalar(0x2A58)!),"andv;":Character(Unicode.Scalar(0x2A5A)!),"ang;":Character(Unicode.Scalar(0x2220)!),"ange;":Character(Unicode.Scalar(0x29A4)!),
    "angle;":Character(Unicode.Scalar(0x2220)!),"angmsd;":Character(Unicode.Scalar(0x2221)!),"angmsdaa;":Character(Unicode.Scalar(0x29A8)!),"angmsdab;":Character(Unicode.Scalar(0x29A9)!),
    "angmsdac;":Character(Unicode.Scalar(0x29AA)!),"angmsdad;":Character(Unicode.Scalar(0x29AB)!),"angmsdae;":Character(Unicode.Scalar(0x29AC)!),"angmsdaf;":Character(Unicode.Scalar(0x29AD)!),
    "angmsdag;":Character(Unicode.Scalar(0x29AE)!),"angmsdah;":Character(Unicode.Scalar(0x29AF)!),"angrt;":Character(Unicode.Scalar(0x221F)!),"angrtvb;":Character(Unicode.Scalar(0x22BE)!),
    "angrtvbd;":Character(Unicode.Scalar(0x299D)!),"angsph;":Character(Unicode.Scalar(0x2222)!),"angst;":Character(Unicode.Scalar(0xC5)!),"angzarr;":Character(Unicode.Scalar(0x237C)!),
    "Aogon;":Character(Unicode.Scalar(0x104)!),"aogon;":Character(Unicode.Scalar(0x105)!),"Aopf;":Character(Unicode.Scalar(0x1D538)!),"aopf;":Character(Unicode.Scalar(0x1D552)!),
    "ap;":Character(Unicode.Scalar(0x2248)!),"apacir;":Character(Unicode.Scalar(0x2A6F)!),"apE;":Character(Unicode.Scalar(0x2A70)!),"ape;":Character(Unicode.Scalar(0x224A)!),
    "apid;":Character(Unicode.Scalar(0x224B)!),"apos;":Character(Unicode.Scalar(0x27)!),"ApplyFunction;":Character(Unicode.Scalar(0x2061)!),"approx;":Character(Unicode.Scalar(0x2248)!),
    "approxeq;":Character(Unicode.Scalar(0x224A)!),"Aring;":Character(Unicode.Scalar(0xC5)!),"aring;":Character(Unicode.Scalar(0xE5)!),"Ascr;":Character(Unicode.Scalar(0x1D49C)!),
    "ascr;":Character(Unicode.Scalar(0x1D4B6)!),"Assign;":Character(Unicode.Scalar(0x2254)!),"ast;":Character(Unicode.Scalar(0x2A)!),"asymp;":Character(Unicode.Scalar(0x2248)!),
    "asympeq;":Character(Unicode.Scalar(0x224D)!),"Atilde;":Character(Unicode.Scalar(0xC3)!),"atilde;":Character(Unicode.Scalar(0xE3)!),"Auml;":Character(Unicode.Scalar(0xC4)!),
    "auml;":Character(Unicode.Scalar(0xE4)!),"awconint;":Character(Unicode.Scalar(0x2233)!),"awint;":Character(Unicode.Scalar(0x2A11)!),"backcong;":Character(Unicode.Scalar(0x224C)!),
    "backepsilon;":Character(Unicode.Scalar(0x3F6)!),"backprime;":Character(Unicode.Scalar(0x2035)!),"backsim;":Character(Unicode.Scalar(0x223D)!),"backsimeq;":Character(Unicode.Scalar(0x22CD)!),
    "Backslash;":Character(Unicode.Scalar(0x2216)!),"Barv;":Character(Unicode.Scalar(0x2AE7)!),"barvee;":Character(Unicode.Scalar(0x22BD)!),"Barwed;":Character(Unicode.Scalar(0x2306)!),
    "barwed;":Character(Unicode.Scalar(0x2305)!),"barwedge;":Character(Unicode.Scalar(0x2305)!),"bbrk;":Character(Unicode.Scalar(0x23B5)!),"bbrktbrk;":Character(Unicode.Scalar(0x23B6)!),
    "bcong;":Character(Unicode.Scalar(0x224C)!),"Bcy;":Character(Unicode.Scalar(0x411)!),"bcy;":Character(Unicode.Scalar(0x431)!),"bdquo;":Character(Unicode.Scalar(0x201E)!),
    "becaus;":Character(Unicode.Scalar(0x2235)!),"Because;":Character(Unicode.Scalar(0x2235)!),"because;":Character(Unicode.Scalar(0x2235)!),"bemptyv;":Character(Unicode.Scalar(0x29B0)!),
    "bepsi;":Character(Unicode.Scalar(0x3F6)!),"bernou;":Character(Unicode.Scalar(0x212C)!),"Bernoullis;":Character(Unicode.Scalar(0x212C)!),"Beta;":Character(Unicode.Scalar(0x392)!),
    "beta;":Character(Unicode.Scalar(0x3B2)!),"beth;":Character(Unicode.Scalar(0x2136)!),"between;":Character(Unicode.Scalar(0x226C)!),"Bfr;":Character(Unicode.Scalar(0x1D505)!),
    "bfr;":Character(Unicode.Scalar(0x1D51F)!),"bigcap;":Character(Unicode.Scalar(0x22C2)!),"bigcirc;":Character(Unicode.Scalar(0x25EF)!),"bigcup;":Character(Unicode.Scalar(0x22C3)!),
    "bigodot;":Character(Unicode.Scalar(0x2A00)!),"bigoplus;":Character(Unicode.Scalar(0x2A01)!),"bigotimes;":Character(Unicode.Scalar(0x2A02)!),"bigsqcup;":Character(Unicode.Scalar(0x2A06)!),
    "bigstar;":Character(Unicode.Scalar(0x2605)!),"bigtriangledown;":Character(Unicode.Scalar(0x25BD)!),"bigtriangleup;":Character(Unicode.Scalar(0x25B3)!),"biguplus;":Character(Unicode.Scalar(0x2A04)!),
    "bigvee;":Character(Unicode.Scalar(0x22C1)!),"bigwedge;":Character(Unicode.Scalar(0x22C0)!),"bkarow;":Character(Unicode.Scalar(0x290D)!),"blacklozenge;":Character(Unicode.Scalar(0x29EB)!),
    "blacksquare;":Character(Unicode.Scalar(0x25AA)!),"blacktriangle;":Character(Unicode.Scalar(0x25B4)!),"blacktriangledown;":Character(Unicode.Scalar(0x25BE)!),"blacktriangleleft;":Character(Unicode.Scalar(0x25C2)!),
    "blacktriangleright;":Character(Unicode.Scalar(0x25B8)!),"blank;":Character(Unicode.Scalar(0x2423)!),"blk12;":Character(Unicode.Scalar(0x2592)!),"blk14;":Character(Unicode.Scalar(0x2591)!),
    "blk34;":Character(Unicode.Scalar(0x2593)!),"block;":Character(Unicode.Scalar(0x2588)!),"bne;":"\u{3D}\u{20E5}","bnequiv;":"\u{2261}\u{20E5}",
    "bNot;":Character(Unicode.Scalar(0x2AED)!),"bnot;":Character(Unicode.Scalar(0x2310)!),"Bopf;":Character(Unicode.Scalar(0x1D539)!),"bopf;":Character(Unicode.Scalar(0x1D553)!),
    "bot;":Character(Unicode.Scalar(0x22A5)!),"bottom;":Character(Unicode.Scalar(0x22A5)!),"bowtie;":Character(Unicode.Scalar(0x22C8)!),"boxbox;":Character(Unicode.Scalar(0x29C9)!),
    "boxDL;":Character(Unicode.Scalar(0x2557)!),"boxDl;":Character(Unicode.Scalar(0x2556)!),"boxdL;":Character(Unicode.Scalar(0x2555)!),"boxdl;":Character(Unicode.Scalar(0x2510)!),
    "boxDR;":Character(Unicode.Scalar(0x2554)!),"boxDr;":Character(Unicode.Scalar(0x2553)!),"boxdR;":Character(Unicode.Scalar(0x2552)!),"boxdr;":Character(Unicode.Scalar(0x250C)!),
    "boxH;":Character(Unicode.Scalar(0x2550)!),"boxh;":Character(Unicode.Scalar(0x2500)!),"boxHD;":Character(Unicode.Scalar(0x2566)!),"boxHd;":Character(Unicode.Scalar(0x2564)!),
    "boxhD;":Character(Unicode.Scalar(0x2565)!),"boxhd;":Character(Unicode.Scalar(0x252C)!),"boxHU;":Character(Unicode.Scalar(0x2569)!),"boxHu;":Character(Unicode.Scalar(0x2567)!),
    "boxhU;":Character(Unicode.Scalar(0x2568)!),"boxhu;":Character(Unicode.Scalar(0x2534)!),"boxminus;":Character(Unicode.Scalar(0x229F)!),"boxplus;":Character(Unicode.Scalar(0x229E)!),
    "boxtimes;":Character(Unicode.Scalar(0x22A0)!),"boxUL;":Character(Unicode.Scalar(0x255D)!),"boxUl;":Character(Unicode.Scalar(0x255C)!),"boxuL;":Character(Unicode.Scalar(0x255B)!),
    "boxul;":Character(Unicode.Scalar(0x2518)!),"boxUR;":Character(Unicode.Scalar(0x255A)!),"boxUr;":Character(Unicode.Scalar(0x2559)!),"boxuR;":Character(Unicode.Scalar(0x2558)!),
    "boxur;":Character(Unicode.Scalar(0x2514)!),"boxV;":Character(Unicode.Scalar(0x2551)!),"boxv;":Character(Unicode.Scalar(0x2502)!),"boxVH;":Character(Unicode.Scalar(0x256C)!),
    "boxVh;":Character(Unicode.Scalar(0x256B)!),"boxvH;":Character(Unicode.Scalar(0x256A)!),"boxvh;":Character(Unicode.Scalar(0x253C)!),"boxVL;":Character(Unicode.Scalar(0x2563)!),
    "boxVl;":Character(Unicode.Scalar(0x2562)!),"boxvL;":Character(Unicode.Scalar(0x2561)!),"boxvl;":Character(Unicode.Scalar(0x2524)!),"boxVR;":Character(Unicode.Scalar(0x2560)!),
    "boxVr;":Character(Unicode.Scalar(0x255F)!),"boxvR;":Character(Unicode.Scalar(0x255E)!),"boxvr;":Character(Unicode.Scalar(0x251C)!),"bprime;":Character(Unicode.Scalar(0x2035)!),
    "Breve;":Character(Unicode.Scalar(0x2D8)!),"breve;":Character(Unicode.Scalar(0x2D8)!),"brvbar;":Character(Unicode.Scalar(0xA6)!),"Bscr;":Character(Unicode.Scalar(0x212C)!),
    "bscr;":Character(Unicode.Scalar(0x1D4B7)!),"bsemi;":Character(Unicode.Scalar(0x204F)!),"bsim;":Character(Unicode.Scalar(0x223D)!),"bsime;":Character(Unicode.Scalar(0x22CD)!),
    "bsol;":Character(Unicode.Scalar(0x5C)!),"bsolb;":Character(Unicode.Scalar(0x29C5)!),"bsolhsub;":Character(Unicode.Scalar(0x27C8)!),"bull;":Character(Unicode.Scalar(0x2022)!),
    "bullet;":Character(Unicode.Scalar(0x2022)!),"bump;":Character(Unicode.Scalar(0x224E)!),"bumpE;":Character(Unicode.Scalar(0x2AAE)!),"bumpe;":Character(Unicode.Scalar(0x224F)!),
    "Bumpeq;":Character(Unicode.Scalar(0x224E)!),"bumpeq;":Character(Unicode.Scalar(0x224F)!),"Cacute;":Character(Unicode.Scalar(0x106)!),"cacute;":Character(Unicode.Scalar(0x107)!),
    "Cap;":Character(Unicode.Scalar(0x22D2)!),"cap;":Character(Unicode.Scalar(0x2229)!),"capand;":Character(Unicode.Scalar(0x2A44)!),"capbrcup;":Character(Unicode.Scalar(0x2A49)!),
    "capcap;":Character(Unicode.Scalar(0x2A4B)!),"capcup;":Character(Unicode.Scalar(0x2A47)!),"capdot;":Character(Unicode.Scalar(0x2A40)!),"CapitalDifferentialD;":Character(Unicode.Scalar(0x2145)!),
    "caps;":"\u{2229}\u{FE00}","caret;":Character(Unicode.Scalar(0x2041)!),"caron;":Character(Unicode.Scalar(0x2C7)!),"Cayleys;":Character(Unicode.Scalar(0x212D)!),
    "ccaps;":Character(Unicode.Scalar(0x2A4D)!),"Ccaron;":Character(Unicode.Scalar(0x10C)!),"ccaron;":Character(Unicode.Scalar(0x10D)!),"Ccedil;":Character(Unicode.Scalar(0xC7)!),
    "ccedil;":Character(Unicode.Scalar(0xE7)!),"Ccirc;":Character(Unicode.Scalar(0x108)!),"ccirc;":Character(Unicode.Scalar(0x109)!),"Cconint;":Character(Unicode.Scalar(0x2230)!),
    "ccups;":Character(Unicode.Scalar(0x2A4C)!),"ccupssm;":Character(Unicode.Scalar(0x2A50)!),"Cdot;":Character(Unicode.Scalar(0x10A)!),"cdot;":Character(Unicode.Scalar(0x10B)!),
    "cedil;":Character(Unicode.Scalar(0xB8)!),"Cedilla;":Character(Unicode.Scalar(0xB8)!),"cemptyv;":Character(Unicode.Scalar(0x29B2)!),"cent;":Character(Unicode.Scalar(0xA2)!),
    "CenterDot;":Character(Unicode.Scalar(0xB7)!),"centerdot;":Character(Unicode.Scalar(0xB7)!),"Cfr;":Character(Unicode.Scalar(0x212D)!),"cfr;":Character(Unicode.Scalar(0x1D520)!),
    "CHcy;":Character(Unicode.Scalar(0x427)!),"chcy;":Character(Unicode.Scalar(0x447)!),"check;":Character(Unicode.Scalar(0x2713)!),"checkmark;":Character(Unicode.Scalar(0x2713)!),
    "Chi;":Character(Unicode.Scalar(0x3A7)!),"chi;":Character(Unicode.Scalar(0x3C7)!),"cir;":Character(Unicode.Scalar(0x25CB)!),"circ;":Character(Unicode.Scalar(0x2C6)!),
    "circeq;":Character(Unicode.Scalar(0x2257)!),"circlearrowleft;":Character(Unicode.Scalar(0x21BA)!),"circlearrowright;":Character(Unicode.Scalar(0x21BB)!),"circledast;":Character(Unicode.Scalar(0x229B)!),
    "circledcirc;":Character(Unicode.Scalar(0x229A)!),"circleddash;":Character(Unicode.Scalar(0x229D)!),"CircleDot;":Character(Unicode.Scalar(0x2299)!),"circledR;":Character(Unicode.Scalar(0xAE)!),
    "circledS;":Character(Unicode.Scalar(0x24C8)!),"CircleMinus;":Character(Unicode.Scalar(0x2296)!),"CirclePlus;":Character(Unicode.Scalar(0x2295)!),"CircleTimes;":Character(Unicode.Scalar(0x2297)!),
    "cirE;":Character(Unicode.Scalar(0x29C3)!),"cire;":Character(Unicode.Scalar(0x2257)!),"cirfnint;":Character(Unicode.Scalar(0x2A10)!),"cirmid;":Character(Unicode.Scalar(0x2AEF)!),
    "cirscir;":Character(Unicode.Scalar(0x29C2)!),"ClockwiseContourIntegral;":Character(Unicode.Scalar(0x2232)!),"CloseCurlyDoubleQuote;":Character(Unicode.Scalar(0x201D)!),"CloseCurlyQuote;":Character(Unicode.Scalar(0x2019)!),
    "clubs;":Character(Unicode.Scalar(0x2663)!),"clubsuit;":Character(Unicode.Scalar(0x2663)!),"Colon;":Character(Unicode.Scalar(0x2237)!),"colon;":Character(Unicode.Scalar(0x3A)!),
    "Colone;":Character(Unicode.Scalar(0x2A74)!),"colone;":Character(Unicode.Scalar(0x2254)!),"coloneq;":Character(Unicode.Scalar(0x2254)!),"comma;":Character(Unicode.Scalar(0x2C)!),
    "commat;":Character(Unicode.Scalar(0x40)!),"comp;":Character(Unicode.Scalar(0x2201)!),"compfn;":Character(Unicode.Scalar(0x2218)!),"complement;":Character(Unicode.Scalar(0x2201)!),
    "complexes;":Character(Unicode.Scalar(0x2102)!),"cong;":Character(Unicode.Scalar(0x2245)!),"congdot;":Character(Unicode.Scalar(0x2A6D)!),"Congruent;":Character(Unicode.Scalar(0x2261)!),
    "Conint;":Character(Unicode.Scalar(0x222F)!),"conint;":Character(Unicode.Scalar(0x222E)!),"ContourIntegral;":Character(Unicode.Scalar(0x222E)!),"Copf;":Character(Unicode.Scalar(0x2102)!),
    "copf;":Character(Unicode.Scalar(0x1D554)!),"coprod;":Character(Unicode.Scalar(0x2210)!),"Coproduct;":Character(Unicode.Scalar(0x2210)!),"COPY;":Character(Unicode.Scalar(0xA9)!),
    "copy;":Character(Unicode.Scalar(0xA9)!),"copysr;":Character(Unicode.Scalar(0x2117)!),"CounterClockwiseContourIntegral;":Character(Unicode.Scalar(0x2233)!),"crarr;":Character(Unicode.Scalar(0x21B5)!),
    "Cross;":Character(Unicode.Scalar(0x2A2F)!),"cross;":Character(Unicode.Scalar(0x2717)!),"Cscr;":Character(Unicode.Scalar(0x1D49E)!),"cscr;":Character(Unicode.Scalar(0x1D4B8)!),
    "csub;":Character(Unicode.Scalar(0x2ACF)!),"csube;":Character(Unicode.Scalar(0x2AD1)!),"csup;":Character(Unicode.Scalar(0x2AD0)!),"csupe;":Character(Unicode.Scalar(0x2AD2)!),
    "ctdot;":Character(Unicode.Scalar(0x22EF)!),"cudarrl;":Character(Unicode.Scalar(0x2938)!),"cudarrr;":Character(Unicode.Scalar(0x2935)!),"cuepr;":Character(Unicode.Scalar(0x22DE)!),
    "cuesc;":Character(Unicode.Scalar(0x22DF)!),"cularr;":Character(Unicode.Scalar(0x21B6)!),"cularrp;":Character(Unicode.Scalar(0x293D)!),"Cup;":Character(Unicode.Scalar(0x22D3)!),
    "cup;":Character(Unicode.Scalar(0x222A)!),"cupbrcap;":Character(Unicode.Scalar(0x2A48)!),"CupCap;":Character(Unicode.Scalar(0x224D)!),"cupcap;":Character(Unicode.Scalar(0x2A46)!),
    "cupcup;":Character(Unicode.Scalar(0x2A4A)!),"cupdot;":Character(Unicode.Scalar(0x228D)!),"cupor;":Character(Unicode.Scalar(0x2A45)!),"cups;":"\u{222A}\u{FE00}",
    "curarr;":Character(Unicode.Scalar(0x21B7)!),"curarrm;":Character(Unicode.Scalar(0x293C)!),"curlyeqprec;":Character(Unicode.Scalar(0x22DE)!),"curlyeqsucc;":Character(Unicode.Scalar(0x22DF)!),
    "curlyvee;":Character(Unicode.Scalar(0x22CE)!),"curlywedge;":Character(Unicode.Scalar(0x22CF)!),"curren;":Character(Unicode.Scalar(0xA4)!),"curvearrowleft;":Character(Unicode.Scalar(0x21B6)!),
    "curvearrowright;":Character(Unicode.Scalar(0x21B7)!),"cuvee;":Character(Unicode.Scalar(0x22CE)!),"cuwed;":Character(Unicode.Scalar(0x22CF)!),"cwconint;":Character(Unicode.Scalar(0x2232)!),
    "cwint;":Character(Unicode.Scalar(0x2231)!),"cylcty;":Character(Unicode.Scalar(0x232D)!),"Dagger;":Character(Unicode.Scalar(0x2021)!),"dagger;":Character(Unicode.Scalar(0x2020)!),
    "daleth;":Character(Unicode.Scalar(0x2138)!),"Darr;":Character(Unicode.Scalar(0x21A1)!),"dArr;":Character(Unicode.Scalar(0x21D3)!),"darr;":Character(Unicode.Scalar(0x2193)!),
    "dash;":Character(Unicode.Scalar(0x2010)!),"Dashv;":Character(Unicode.Scalar(0x2AE4)!),"dashv;":Character(Unicode.Scalar(0x22A3)!),"dbkarow;":Character(Unicode.Scalar(0x290F)!),
    "dblac;":Character(Unicode.Scalar(0x2DD)!),"Dcaron;":Character(Unicode.Scalar(0x10E)!),"dcaron;":Character(Unicode.Scalar(0x10F)!),"Dcy;":Character(Unicode.Scalar(0x414)!),
    "dcy;":Character(Unicode.Scalar(0x434)!),"DD;":Character(Unicode.Scalar(0x2145)!),"dd;":Character(Unicode.Scalar(0x2146)!),"ddagger;":Character(Unicode.Scalar(0x2021)!),
    "ddarr;":Character(Unicode.Scalar(0x21CA)!),"DDotrahd;":Character(Unicode.Scalar(0x2911)!),"ddotseq;":Character(Unicode.Scalar(0x2A77)!),"deg;":Character(Unicode.Scalar(0xB0)!),
    "Del;":Character(Unicode.Scalar(0x2207)!),"Delta;":Character(Unicode.Scalar(0x394)!),"delta;":Character(Unicode.Scalar(0x3B4)!),"demptyv;":Character(Unicode.Scalar(0x29B1)!),
    "dfisht;":Character(Unicode.Scalar(0x297F)!),"Dfr;":Character(Unicode.Scalar(0x1D507)!),"dfr;":Character(Unicode.Scalar(0x1D521)!),"dHar;":Character(Unicode.Scalar(0x2965)!),
    "dharl;":Character(Unicode.Scalar(0x21C3)!),"dharr;":Character(Unicode.Scalar(0x21C2)!),"DiacriticalAcute;":Character(Unicode.Scalar(0xB4)!),"DiacriticalDot;":Character(Unicode.Scalar(0x2D9)!),
    "DiacriticalDoubleAcute;":Character(Unicode.Scalar(0x2DD)!),"DiacriticalGrave;":Character(Unicode.Scalar(0x60)!),"DiacriticalTilde;":Character(Unicode.Scalar(0x2DC)!),"diam;":Character(Unicode.Scalar(0x22C4)!),
    "Diamond;":Character(Unicode.Scalar(0x22C4)!),"diamond;":Character(Unicode.Scalar(0x22C4)!),"diamondsuit;":Character(Unicode.Scalar(0x2666)!),"diams;":Character(Unicode.Scalar(0x2666)!),
    "die;":Character(Unicode.Scalar(0xA8)!),"DifferentialD;":Character(Unicode.Scalar(0x2146)!),"digamma;":Character(Unicode.Scalar(0x3DD)!),"disin;":Character(Unicode.Scalar(0x22F2)!),
    "div;":Character(Unicode.Scalar(0xF7)!),"divide;":Character(Unicode.Scalar(0xF7)!),"divideontimes;":Character(Unicode.Scalar(0x22C7)!),"divonx;":Character(Unicode.Scalar(0x22C7)!),
    "DJcy;":Character(Unicode.Scalar(0x402)!),"djcy;":Character(Unicode.Scalar(0x452)!),"dlcorn;":Character(Unicode.Scalar(0x231E)!),"dlcrop;":Character(Unicode.Scalar(0x230D)!),
    "dollar;":Character(Unicode.Scalar(0x24)!),"Dopf;":Character(Unicode.Scalar(0x1D53B)!),"dopf;":Character(Unicode.Scalar(0x1D555)!),"Dot;":Character(Unicode.Scalar(0xA8)!),
    "dot;":Character(Unicode.Scalar(0x2D9)!),"DotDot;":Character(Unicode.Scalar(0x20DC)!),"doteq;":Character(Unicode.Scalar(0x2250)!),"doteqdot;":Character(Unicode.Scalar(0x2251)!),
    "DotEqual;":Character(Unicode.Scalar(0x2250)!),"dotminus;":Character(Unicode.Scalar(0x2238)!),"dotplus;":Character(Unicode.Scalar(0x2214)!),"dotsquare;":Character(Unicode.Scalar(0x22A1)!),
    "doublebarwedge;":Character(Unicode.Scalar(0x2306)!),"DoubleContourIntegral;":Character(Unicode.Scalar(0x222F)!),"DoubleDot;":Character(Unicode.Scalar(0xA8)!),"DoubleDownArrow;":Character(Unicode.Scalar(0x21D3)!),
    "DoubleLeftArrow;":Character(Unicode.Scalar(0x21D0)!),"DoubleLeftRightArrow;":Character(Unicode.Scalar(0x21D4)!),"DoubleLeftTee;":Character(Unicode.Scalar(0x2AE4)!),"DoubleLongLeftArrow;":Character(Unicode.Scalar(0x27F8)!),
    "DoubleLongLeftRightArrow;":Character(Unicode.Scalar(0x27FA)!),"DoubleLongRightArrow;":Character(Unicode.Scalar(0x27F9)!),"DoubleRightArrow;":Character(Unicode.Scalar(0x21D2)!),"DoubleRightTee;":Character(Unicode.Scalar(0x22A8)!),
    "DoubleUpArrow;":Character(Unicode.Scalar(0x21D1)!),"DoubleUpDownArrow;":Character(Unicode.Scalar(0x21D5)!),"DoubleVerticalBar;":Character(Unicode.Scalar(0x2225)!),"DownArrow;":Character(Unicode.Scalar(0x2193)!),
    "Downarrow;":Character(Unicode.Scalar(0x21D3)!),"downarrow;":Character(Unicode.Scalar(0x2193)!),"DownArrowBar;":Character(Unicode.Scalar(0x2913)!),"DownArrowUpArrow;":Character(Unicode.Scalar(0x21F5)!),
    "DownBreve;":Character(Unicode.Scalar(0x311)!),"downdownarrows;":Character(Unicode.Scalar(0x21CA)!),"downharpoonleft;":Character(Unicode.Scalar(0x21C3)!),"downharpoonright;":Character(Unicode.Scalar(0x21C2)!),
    "DownLeftRightVector;":Character(Unicode.Scalar(0x2950)!),"DownLeftTeeVector;":Character(Unicode.Scalar(0x295E)!),"DownLeftVector;":Character(Unicode.Scalar(0x21BD)!),"DownLeftVectorBar;":Character(Unicode.Scalar(0x2956)!),
    "DownRightTeeVector;":Character(Unicode.Scalar(0x295F)!),"DownRightVector;":Character(Unicode.Scalar(0x21C1)!),"DownRightVectorBar;":Character(Unicode.Scalar(0x2957)!),"DownTee;":Character(Unicode.Scalar(0x22A4)!),
    "DownTeeArrow;":Character(Unicode.Scalar(0x21A7)!),"drbkarow;":Character(Unicode.Scalar(0x2910)!),"drcorn;":Character(Unicode.Scalar(0x231F)!),"drcrop;":Character(Unicode.Scalar(0x230C)!),
    "Dscr;":Character(Unicode.Scalar(0x1D49F)!),"dscr;":Character(Unicode.Scalar(0x1D4B9)!),"DScy;":Character(Unicode.Scalar(0x405)!),"dscy;":Character(Unicode.Scalar(0x455)!),
    "dsol;":Character(Unicode.Scalar(0x29F6)!),"Dstrok;":Character(Unicode.Scalar(0x110)!),"dstrok;":Character(Unicode.Scalar(0x111)!),"dtdot;":Character(Unicode.Scalar(0x22F1)!),
    "dtri;":Character(Unicode.Scalar(0x25BF)!),"dtrif;":Character(Unicode.Scalar(0x25BE)!),"duarr;":Character(Unicode.Scalar(0x21F5)!),"duhar;":Character(Unicode.Scalar(0x296F)!),
    "dwangle;":Character(Unicode.Scalar(0x29A6)!),"DZcy;":Character(Unicode.Scalar(0x40F)!),"dzcy;":Character(Unicode.Scalar(0x45F)!),"dzigrarr;":Character(Unicode.Scalar(0x27FF)!),
    "Eacute;":Character(Unicode.Scalar(0xC9)!),"eacute;":Character(Unicode.Scalar(0xE9)!),"easter;":Character(Unicode.Scalar(0x2A6E)!),"Ecaron;":Character(Unicode.Scalar(0x11A)!),
    "ecaron;":Character(Unicode.Scalar(0x11B)!),"ecir;":Character(Unicode.Scalar(0x2256)!),"Ecirc;":Character(Unicode.Scalar(0xCA)!),"ecirc;":Character(Unicode.Scalar(0xEA)!),
    "ecolon;":Character(Unicode.Scalar(0x2255)!),"Ecy;":Character(Unicode.Scalar(0x42D)!),"ecy;":Character(Unicode.Scalar(0x44D)!),"eDDot;":Character(Unicode.Scalar(0x2A77)!),
    "Edot;":Character(Unicode.Scalar(0x116)!),"eDot;":Character(Unicode.Scalar(0x2251)!),"edot;":Character(Unicode.Scalar(0x117)!),"ee;":Character(Unicode.Scalar(0x2147)!),
    "efDot;":Character(Unicode.Scalar(0x2252)!),"Efr;":Character(Unicode.Scalar(0x1D508)!),"efr;":Character(Unicode.Scalar(0x1D522)!),"eg;":Character(Unicode.Scalar(0x2A9A)!),
    "Egrave;":Character(Unicode.Scalar(0xC8)!),"egrave;":Character(Unicode.Scalar(0xE8)!),"egs;":Character(Unicode.Scalar(0x2A96)!),"egsdot;":Character(Unicode.Scalar(0x2A98)!),
    "el;":Character(Unicode.Scalar(0x2A99)!),"Element;":Character(Unicode.Scalar(0x2208)!),"elinters;":Character(Unicode.Scalar(0x23E7)!),"ell;":Character(Unicode.Scalar(0x2113)!),
    "els;":Character(Unicode.Scalar(0x2A95)!),"elsdot;":Character(Unicode.Scalar(0x2A97)!),"Emacr;":Character(Unicode.Scalar(0x112)!),"emacr;":Character(Unicode.Scalar(0x113)!),
    "empty;":Character(Unicode.Scalar(0x2205)!),"emptyset;":Character(Unicode.Scalar(0x2205)!),"EmptySmallSquare;":Character(Unicode.Scalar(0x25FB)!),"emptyv;":Character(Unicode.Scalar(0x2205)!),
    "EmptyVerySmallSquare;":Character(Unicode.Scalar(0x25AB)!),"emsp;":Character(Unicode.Scalar(0x2003)!),"emsp13;":Character(Unicode.Scalar(0x2004)!),"emsp14;":Character(Unicode.Scalar(0x2005)!),
    "ENG;":Character(Unicode.Scalar(0x14A)!),"eng;":Character(Unicode.Scalar(0x14B)!),"ensp;":Character(Unicode.Scalar(0x2002)!),"Eogon;":Character(Unicode.Scalar(0x118)!),
    "eogon;":Character(Unicode.Scalar(0x119)!),"Eopf;":Character(Unicode.Scalar(0x1D53C)!),"eopf;":Character(Unicode.Scalar(0x1D556)!),"epar;":Character(Unicode.Scalar(0x22D5)!),
    "eparsl;":Character(Unicode.Scalar(0x29E3)!),"eplus;":Character(Unicode.Scalar(0x2A71)!),"epsi;":Character(Unicode.Scalar(0x3B5)!),"Epsilon;":Character(Unicode.Scalar(0x395)!),
    "epsilon;":Character(Unicode.Scalar(0x3B5)!),"epsiv;":Character(Unicode.Scalar(0x3F5)!),"eqcirc;":Character(Unicode.Scalar(0x2256)!),"eqcolon;":Character(Unicode.Scalar(0x2255)!),
    "eqsim;":Character(Unicode.Scalar(0x2242)!),"eqslantgtr;":Character(Unicode.Scalar(0x2A96)!),"eqslantless;":Character(Unicode.Scalar(0x2A95)!),"Equal;":Character(Unicode.Scalar(0x2A75)!),
    "equals;":Character(Unicode.Scalar(0x3D)!),"EqualTilde;":Character(Unicode.Scalar(0x2242)!),"equest;":Character(Unicode.Scalar(0x225F)!),"Equilibrium;":Character(Unicode.Scalar(0x21CC)!),
    "equiv;":Character(Unicode.Scalar(0x2261)!),"equivDD;":Character(Unicode.Scalar(0x2A78)!),"eqvparsl;":Character(Unicode.Scalar(0x29E5)!),"erarr;":Character(Unicode.Scalar(0x2971)!),
    "erDot;":Character(Unicode.Scalar(0x2253)!),"Escr;":Character(Unicode.Scalar(0x2130)!),"escr;":Character(Unicode.Scalar(0x212F)!),"esdot;":Character(Unicode.Scalar(0x2250)!),
    "Esim;":Character(Unicode.Scalar(0x2A73)!),"esim;":Character(Unicode.Scalar(0x2242)!),"Eta;":Character(Unicode.Scalar(0x397)!),"eta;":Character(Unicode.Scalar(0x3B7)!),
    "ETH;":Character(Unicode.Scalar(0xD0)!),"eth;":Character(Unicode.Scalar(0xF0)!),"Euml;":Character(Unicode.Scalar(0xCB)!),"euml;":Character(Unicode.Scalar(0xEB)!),
    "euro;":Character(Unicode.Scalar(0x20AC)!),"excl;":Character(Unicode.Scalar(0x21)!),"exist;":Character(Unicode.Scalar(0x2203)!),"Exists;":Character(Unicode.Scalar(0x2203)!),
    "expectation;":Character(Unicode.Scalar(0x2130)!),"ExponentialE;":Character(Unicode.Scalar(0x2147)!),"exponentiale;":Character(Unicode.Scalar(0x2147)!),"fallingdotseq;":Character(Unicode.Scalar(0x2252)!),
    "Fcy;":Character(Unicode.Scalar(0x424)!),"fcy;":Character(Unicode.Scalar(0x444)!),"female;":Character(Unicode.Scalar(0x2640)!),"ffilig;":Character(Unicode.Scalar(0xFB03)!),
    "fflig;":Character(Unicode.Scalar(0xFB00)!),"ffllig;":Character(Unicode.Scalar(0xFB04)!),"Ffr;":Character(Unicode.Scalar(0x1D509)!),"ffr;":Character(Unicode.Scalar(0x1D523)!),
    "filig;":Character(Unicode.Scalar(0xFB01)!),"FilledSmallSquare;":Character(Unicode.Scalar(0x25FC)!),"FilledVerySmallSquare;":Character(Unicode.Scalar(0x25AA)!),

    // Skip "fjlig;" due to Swift not recognizing it as a single grapheme cluster
    // "fjlig;":Character(Unicode.Scalar(0x66}\u{6A)!),

    "flat;":Character(Unicode.Scalar(0x266D)!),"fllig;":Character(Unicode.Scalar(0xFB02)!),"fltns;":Character(Unicode.Scalar(0x25B1)!),"fnof;":Character(Unicode.Scalar(0x192)!),
    "Fopf;":Character(Unicode.Scalar(0x1D53D)!),"fopf;":Character(Unicode.Scalar(0x1D557)!),"ForAll;":Character(Unicode.Scalar(0x2200)!),"forall;":Character(Unicode.Scalar(0x2200)!),
    "fork;":Character(Unicode.Scalar(0x22D4)!),"forkv;":Character(Unicode.Scalar(0x2AD9)!),"Fouriertrf;":Character(Unicode.Scalar(0x2131)!),"fpartint;":Character(Unicode.Scalar(0x2A0D)!),
    "frac12;":Character(Unicode.Scalar(0xBD)!),"frac13;":Character(Unicode.Scalar(0x2153)!),"frac14;":Character(Unicode.Scalar(0xBC)!),"frac15;":Character(Unicode.Scalar(0x2155)!),
    "frac16;":Character(Unicode.Scalar(0x2159)!),"frac18;":Character(Unicode.Scalar(0x215B)!),"frac23;":Character(Unicode.Scalar(0x2154)!),"frac25;":Character(Unicode.Scalar(0x2156)!),
    "frac34;":Character(Unicode.Scalar(0xBE)!),"frac35;":Character(Unicode.Scalar(0x2157)!),"frac38;":Character(Unicode.Scalar(0x215C)!),"frac45;":Character(Unicode.Scalar(0x2158)!),
    "frac56;":Character(Unicode.Scalar(0x215A)!),"frac58;":Character(Unicode.Scalar(0x215D)!),"frac78;":Character(Unicode.Scalar(0x215E)!),"frasl;":Character(Unicode.Scalar(0x2044)!),
    "frown;":Character(Unicode.Scalar(0x2322)!),"Fscr;":Character(Unicode.Scalar(0x2131)!),"fscr;":Character(Unicode.Scalar(0x1D4BB)!),"gacute;":Character(Unicode.Scalar(0x1F5)!),
    "Gamma;":Character(Unicode.Scalar(0x393)!),"gamma;":Character(Unicode.Scalar(0x3B3)!),"Gammad;":Character(Unicode.Scalar(0x3DC)!),"gammad;":Character(Unicode.Scalar(0x3DD)!),
    "gap;":Character(Unicode.Scalar(0x2A86)!),"Gbreve;":Character(Unicode.Scalar(0x11E)!),"gbreve;":Character(Unicode.Scalar(0x11F)!),"Gcedil;":Character(Unicode.Scalar(0x122)!),
    "Gcirc;":Character(Unicode.Scalar(0x11C)!),"gcirc;":Character(Unicode.Scalar(0x11D)!),"Gcy;":Character(Unicode.Scalar(0x413)!),"gcy;":Character(Unicode.Scalar(0x433)!),
    "Gdot;":Character(Unicode.Scalar(0x120)!),"gdot;":Character(Unicode.Scalar(0x121)!),"gE;":Character(Unicode.Scalar(0x2267)!),"ge;":Character(Unicode.Scalar(0x2265)!),
    "gEl;":Character(Unicode.Scalar(0x2A8C)!),"gel;":Character(Unicode.Scalar(0x22DB)!),"geq;":Character(Unicode.Scalar(0x2265)!),"geqq;":Character(Unicode.Scalar(0x2267)!),
    "geqslant;":Character(Unicode.Scalar(0x2A7E)!),"ges;":Character(Unicode.Scalar(0x2A7E)!),"gescc;":Character(Unicode.Scalar(0x2AA9)!),"gesdot;":Character(Unicode.Scalar(0x2A80)!),
    "gesdoto;":Character(Unicode.Scalar(0x2A82)!),"gesdotol;":Character(Unicode.Scalar(0x2A84)!),"gesl;":"\u{22DB}\u{FE00}","gesles;":Character(Unicode.Scalar(0x2A94)!),
    "Gfr;":Character(Unicode.Scalar(0x1D50A)!),"gfr;":Character(Unicode.Scalar(0x1D524)!),"Gg;":Character(Unicode.Scalar(0x22D9)!),"gg;":Character(Unicode.Scalar(0x226B)!),
    "ggg;":Character(Unicode.Scalar(0x22D9)!),"gimel;":Character(Unicode.Scalar(0x2137)!),"GJcy;":Character(Unicode.Scalar(0x403)!),"gjcy;":Character(Unicode.Scalar(0x453)!),
    "gl;":Character(Unicode.Scalar(0x2277)!),"gla;":Character(Unicode.Scalar(0x2AA5)!),"glE;":Character(Unicode.Scalar(0x2A92)!),"glj;":Character(Unicode.Scalar(0x2AA4)!),
    "gnap;":Character(Unicode.Scalar(0x2A8A)!),"gnapprox;":Character(Unicode.Scalar(0x2A8A)!),"gnE;":Character(Unicode.Scalar(0x2269)!),"gne;":Character(Unicode.Scalar(0x2A88)!),
    "gneq;":Character(Unicode.Scalar(0x2A88)!),"gneqq;":Character(Unicode.Scalar(0x2269)!),"gnsim;":Character(Unicode.Scalar(0x22E7)!),"Gopf;":Character(Unicode.Scalar(0x1D53E)!),
    "gopf;":Character(Unicode.Scalar(0x1D558)!),"grave;":Character(Unicode.Scalar(0x60)!),"GreaterEqual;":Character(Unicode.Scalar(0x2265)!),"GreaterEqualLess;":Character(Unicode.Scalar(0x22DB)!),
    "GreaterFullEqual;":Character(Unicode.Scalar(0x2267)!),"GreaterGreater;":Character(Unicode.Scalar(0x2AA2)!),"GreaterLess;":Character(Unicode.Scalar(0x2277)!),"GreaterSlantEqual;":Character(Unicode.Scalar(0x2A7E)!),
    "GreaterTilde;":Character(Unicode.Scalar(0x2273)!),"Gscr;":Character(Unicode.Scalar(0x1D4A2)!),"gscr;":Character(Unicode.Scalar(0x210A)!),"gsim;":Character(Unicode.Scalar(0x2273)!),
    "gsime;":Character(Unicode.Scalar(0x2A8E)!),"gsiml;":Character(Unicode.Scalar(0x2A90)!),"GT;":Character(Unicode.Scalar(0x3E)!),"Gt;":Character(Unicode.Scalar(0x226B)!),
    "gt;":Character(Unicode.Scalar(0x3E)!),"gtcc;":Character(Unicode.Scalar(0x2AA7)!),"gtcir;":Character(Unicode.Scalar(0x2A7A)!),"gtdot;":Character(Unicode.Scalar(0x22D7)!),
    "gtlPar;":Character(Unicode.Scalar(0x2995)!),"gtquest;":Character(Unicode.Scalar(0x2A7C)!),"gtrapprox;":Character(Unicode.Scalar(0x2A86)!),"gtrarr;":Character(Unicode.Scalar(0x2978)!),
    "gtrdot;":Character(Unicode.Scalar(0x22D7)!),"gtreqless;":Character(Unicode.Scalar(0x22DB)!),"gtreqqless;":Character(Unicode.Scalar(0x2A8C)!),"gtrless;":Character(Unicode.Scalar(0x2277)!),
    "gtrsim;":Character(Unicode.Scalar(0x2273)!),"gvertneqq;":"\u{2269}\u{FE00}","gvnE;":"\u{2269}\u{FE00}","Hacek;":Character(Unicode.Scalar(0x2C7)!),
    "hairsp;":Character(Unicode.Scalar(0x200A)!),"half;":Character(Unicode.Scalar(0xBD)!),"hamilt;":Character(Unicode.Scalar(0x210B)!),"HARDcy;":Character(Unicode.Scalar(0x42A)!),
    "hardcy;":Character(Unicode.Scalar(0x44A)!),"hArr;":Character(Unicode.Scalar(0x21D4)!),"harr;":Character(Unicode.Scalar(0x2194)!),"harrcir;":Character(Unicode.Scalar(0x2948)!),
    "harrw;":Character(Unicode.Scalar(0x21AD)!),"Hat;":Character(Unicode.Scalar(0x5E)!),"hbar;":Character(Unicode.Scalar(0x210F)!),"Hcirc;":Character(Unicode.Scalar(0x124)!),
    "hcirc;":Character(Unicode.Scalar(0x125)!),"hearts;":Character(Unicode.Scalar(0x2665)!),"heartsuit;":Character(Unicode.Scalar(0x2665)!),"hellip;":Character(Unicode.Scalar(0x2026)!),
    "hercon;":Character(Unicode.Scalar(0x22B9)!),"Hfr;":Character(Unicode.Scalar(0x210C)!),"hfr;":Character(Unicode.Scalar(0x1D525)!),"HilbertSpace;":Character(Unicode.Scalar(0x210B)!),
    "hksearow;":Character(Unicode.Scalar(0x2925)!),"hkswarow;":Character(Unicode.Scalar(0x2926)!),"hoarr;":Character(Unicode.Scalar(0x21FF)!),"homtht;":Character(Unicode.Scalar(0x223B)!),
    "hookleftarrow;":Character(Unicode.Scalar(0x21A9)!),"hookrightarrow;":Character(Unicode.Scalar(0x21AA)!),"Hopf;":Character(Unicode.Scalar(0x210D)!),"hopf;":Character(Unicode.Scalar(0x1D559)!),
    "horbar;":Character(Unicode.Scalar(0x2015)!),"HorizontalLine;":Character(Unicode.Scalar(0x2500)!),"Hscr;":Character(Unicode.Scalar(0x210B)!),"hscr;":Character(Unicode.Scalar(0x1D4BD)!),
    "hslash;":Character(Unicode.Scalar(0x210F)!),"Hstrok;":Character(Unicode.Scalar(0x126)!),"hstrok;":Character(Unicode.Scalar(0x127)!),"HumpDownHump;":Character(Unicode.Scalar(0x224E)!),
    "HumpEqual;":Character(Unicode.Scalar(0x224F)!),"hybull;":Character(Unicode.Scalar(0x2043)!),"hyphen;":Character(Unicode.Scalar(0x2010)!),"Iacute;":Character(Unicode.Scalar(0xCD)!),
    "iacute;":Character(Unicode.Scalar(0xED)!),"ic;":Character(Unicode.Scalar(0x2063)!),"Icirc;":Character(Unicode.Scalar(0xCE)!),"icirc;":Character(Unicode.Scalar(0xEE)!),
    "Icy;":Character(Unicode.Scalar(0x418)!),"icy;":Character(Unicode.Scalar(0x438)!),"Idot;":Character(Unicode.Scalar(0x130)!),"IEcy;":Character(Unicode.Scalar(0x415)!),
    "iecy;":Character(Unicode.Scalar(0x435)!),"iexcl;":Character(Unicode.Scalar(0xA1)!),"iff;":Character(Unicode.Scalar(0x21D4)!),"Ifr;":Character(Unicode.Scalar(0x2111)!),
    "ifr;":Character(Unicode.Scalar(0x1D526)!),"Igrave;":Character(Unicode.Scalar(0xCC)!),"igrave;":Character(Unicode.Scalar(0xEC)!),"ii;":Character(Unicode.Scalar(0x2148)!),
    "iiiint;":Character(Unicode.Scalar(0x2A0C)!),"iiint;":Character(Unicode.Scalar(0x222D)!),"iinfin;":Character(Unicode.Scalar(0x29DC)!),"iiota;":Character(Unicode.Scalar(0x2129)!),
    "IJlig;":Character(Unicode.Scalar(0x132)!),"ijlig;":Character(Unicode.Scalar(0x133)!),"Im;":Character(Unicode.Scalar(0x2111)!),"Imacr;":Character(Unicode.Scalar(0x12A)!),
    "imacr;":Character(Unicode.Scalar(0x12B)!),"image;":Character(Unicode.Scalar(0x2111)!),"ImaginaryI;":Character(Unicode.Scalar(0x2148)!),"imagline;":Character(Unicode.Scalar(0x2110)!),
    "imagpart;":Character(Unicode.Scalar(0x2111)!),"imath;":Character(Unicode.Scalar(0x131)!),"imof;":Character(Unicode.Scalar(0x22B7)!),"imped;":Character(Unicode.Scalar(0x1B5)!),
    "Implies;":Character(Unicode.Scalar(0x21D2)!),"in;":Character(Unicode.Scalar(0x2208)!),"incare;":Character(Unicode.Scalar(0x2105)!),"infin;":Character(Unicode.Scalar(0x221E)!),
    "infintie;":Character(Unicode.Scalar(0x29DD)!),"inodot;":Character(Unicode.Scalar(0x131)!),"Int;":Character(Unicode.Scalar(0x222C)!),"int;":Character(Unicode.Scalar(0x222B)!),
    "intcal;":Character(Unicode.Scalar(0x22BA)!),"integers;":Character(Unicode.Scalar(0x2124)!),"Integral;":Character(Unicode.Scalar(0x222B)!),"intercal;":Character(Unicode.Scalar(0x22BA)!),
    "Intersection;":Character(Unicode.Scalar(0x22C2)!),"intlarhk;":Character(Unicode.Scalar(0x2A17)!),"intprod;":Character(Unicode.Scalar(0x2A3C)!),"InvisibleComma;":Character(Unicode.Scalar(0x2063)!),
    "InvisibleTimes;":Character(Unicode.Scalar(0x2062)!),"IOcy;":Character(Unicode.Scalar(0x401)!),"iocy;":Character(Unicode.Scalar(0x451)!),"Iogon;":Character(Unicode.Scalar(0x12E)!),
    "iogon;":Character(Unicode.Scalar(0x12F)!),"Iopf;":Character(Unicode.Scalar(0x1D540)!),"iopf;":Character(Unicode.Scalar(0x1D55A)!),"Iota;":Character(Unicode.Scalar(0x399)!),
    "iota;":Character(Unicode.Scalar(0x3B9)!),"iprod;":Character(Unicode.Scalar(0x2A3C)!),"iquest;":Character(Unicode.Scalar(0xBF)!),"Iscr;":Character(Unicode.Scalar(0x2110)!),
    "iscr;":Character(Unicode.Scalar(0x1D4BE)!),"isin;":Character(Unicode.Scalar(0x2208)!),"isindot;":Character(Unicode.Scalar(0x22F5)!),"isinE;":Character(Unicode.Scalar(0x22F9)!),
    "isins;":Character(Unicode.Scalar(0x22F4)!),"isinsv;":Character(Unicode.Scalar(0x22F3)!),"isinv;":Character(Unicode.Scalar(0x2208)!),"it;":Character(Unicode.Scalar(0x2062)!),
    "Itilde;":Character(Unicode.Scalar(0x128)!),"itilde;":Character(Unicode.Scalar(0x129)!),"Iukcy;":Character(Unicode.Scalar(0x406)!),"iukcy;":Character(Unicode.Scalar(0x456)!),
    "Iuml;":Character(Unicode.Scalar(0xCF)!),"iuml;":Character(Unicode.Scalar(0xEF)!),"Jcirc;":Character(Unicode.Scalar(0x134)!),"jcirc;":Character(Unicode.Scalar(0x135)!),
    "Jcy;":Character(Unicode.Scalar(0x419)!),"jcy;":Character(Unicode.Scalar(0x439)!),"Jfr;":Character(Unicode.Scalar(0x1D50D)!),"jfr;":Character(Unicode.Scalar(0x1D527)!),
    "jmath;":Character(Unicode.Scalar(0x237)!),"Jopf;":Character(Unicode.Scalar(0x1D541)!),"jopf;":Character(Unicode.Scalar(0x1D55B)!),"Jscr;":Character(Unicode.Scalar(0x1D4A5)!),
    "jscr;":Character(Unicode.Scalar(0x1D4BF)!),"Jsercy;":Character(Unicode.Scalar(0x408)!),"jsercy;":Character(Unicode.Scalar(0x458)!),"Jukcy;":Character(Unicode.Scalar(0x404)!),
    "jukcy;":Character(Unicode.Scalar(0x454)!),"Kappa;":Character(Unicode.Scalar(0x39A)!),"kappa;":Character(Unicode.Scalar(0x3BA)!),"kappav;":Character(Unicode.Scalar(0x3F0)!),
    "Kcedil;":Character(Unicode.Scalar(0x136)!),"kcedil;":Character(Unicode.Scalar(0x137)!),"Kcy;":Character(Unicode.Scalar(0x41A)!),"kcy;":Character(Unicode.Scalar(0x43A)!),
    "Kfr;":Character(Unicode.Scalar(0x1D50E)!),"kfr;":Character(Unicode.Scalar(0x1D528)!),"kgreen;":Character(Unicode.Scalar(0x138)!),"KHcy;":Character(Unicode.Scalar(0x425)!),
    "khcy;":Character(Unicode.Scalar(0x445)!),"KJcy;":Character(Unicode.Scalar(0x40C)!),"kjcy;":Character(Unicode.Scalar(0x45C)!),"Kopf;":Character(Unicode.Scalar(0x1D542)!),
    "kopf;":Character(Unicode.Scalar(0x1D55C)!),"Kscr;":Character(Unicode.Scalar(0x1D4A6)!),"kscr;":Character(Unicode.Scalar(0x1D4C0)!),"lAarr;":Character(Unicode.Scalar(0x21DA)!),
    "Lacute;":Character(Unicode.Scalar(0x139)!),"lacute;":Character(Unicode.Scalar(0x13A)!),"laemptyv;":Character(Unicode.Scalar(0x29B4)!),"lagran;":Character(Unicode.Scalar(0x2112)!),
    "Lambda;":Character(Unicode.Scalar(0x39B)!),"lambda;":Character(Unicode.Scalar(0x3BB)!),"Lang;":Character(Unicode.Scalar(0x27EA)!),"lang;":Character(Unicode.Scalar(0x27E8)!),
    "langd;":Character(Unicode.Scalar(0x2991)!),"langle;":Character(Unicode.Scalar(0x27E8)!),"lap;":Character(Unicode.Scalar(0x2A85)!),"Laplacetrf;":Character(Unicode.Scalar(0x2112)!),
    "laquo;":Character(Unicode.Scalar(0xAB)!),"Larr;":Character(Unicode.Scalar(0x219E)!),"lArr;":Character(Unicode.Scalar(0x21D0)!),"larr;":Character(Unicode.Scalar(0x2190)!),
    "larrb;":Character(Unicode.Scalar(0x21E4)!),"larrbfs;":Character(Unicode.Scalar(0x291F)!),"larrfs;":Character(Unicode.Scalar(0x291D)!),"larrhk;":Character(Unicode.Scalar(0x21A9)!),
    "larrlp;":Character(Unicode.Scalar(0x21AB)!),"larrpl;":Character(Unicode.Scalar(0x2939)!),"larrsim;":Character(Unicode.Scalar(0x2973)!),"larrtl;":Character(Unicode.Scalar(0x21A2)!),
    "lat;":Character(Unicode.Scalar(0x2AAB)!),"lAtail;":Character(Unicode.Scalar(0x291B)!),"latail;":Character(Unicode.Scalar(0x2919)!),"late;":Character(Unicode.Scalar(0x2AAD)!),
    "lates;":"\u{2AAD}\u{FE00}","lBarr;":Character(Unicode.Scalar(0x290E)!),"lbarr;":Character(Unicode.Scalar(0x290C)!),"lbbrk;":Character(Unicode.Scalar(0x2772)!),
    "lbrace;":Character(Unicode.Scalar(0x7B)!),"lbrack;":Character(Unicode.Scalar(0x5B)!),"lbrke;":Character(Unicode.Scalar(0x298B)!),"lbrksld;":Character(Unicode.Scalar(0x298F)!),
    "lbrkslu;":Character(Unicode.Scalar(0x298D)!),"Lcaron;":Character(Unicode.Scalar(0x13D)!),"lcaron;":Character(Unicode.Scalar(0x13E)!),"Lcedil;":Character(Unicode.Scalar(0x13B)!),
    "lcedil;":Character(Unicode.Scalar(0x13C)!),"lceil;":Character(Unicode.Scalar(0x2308)!),"lcub;":Character(Unicode.Scalar(0x7B)!),"Lcy;":Character(Unicode.Scalar(0x41B)!),
    "lcy;":Character(Unicode.Scalar(0x43B)!),"ldca;":Character(Unicode.Scalar(0x2936)!),"ldquo;":Character(Unicode.Scalar(0x201C)!),"ldquor;":Character(Unicode.Scalar(0x201E)!),
    "ldrdhar;":Character(Unicode.Scalar(0x2967)!),"ldrushar;":Character(Unicode.Scalar(0x294B)!),"ldsh;":Character(Unicode.Scalar(0x21B2)!),"lE;":Character(Unicode.Scalar(0x2266)!),
    "le;":Character(Unicode.Scalar(0x2264)!),"LeftAngleBracket;":Character(Unicode.Scalar(0x27E8)!),"LeftArrow;":Character(Unicode.Scalar(0x2190)!),"Leftarrow;":Character(Unicode.Scalar(0x21D0)!),
    "leftarrow;":Character(Unicode.Scalar(0x2190)!),"LeftArrowBar;":Character(Unicode.Scalar(0x21E4)!),"LeftArrowRightArrow;":Character(Unicode.Scalar(0x21C6)!),"leftarrowtail;":Character(Unicode.Scalar(0x21A2)!),
    "LeftCeiling;":Character(Unicode.Scalar(0x2308)!),"LeftDoubleBracket;":Character(Unicode.Scalar(0x27E6)!),"LeftDownTeeVector;":Character(Unicode.Scalar(0x2961)!),"LeftDownVector;":Character(Unicode.Scalar(0x21C3)!),
    "LeftDownVectorBar;":Character(Unicode.Scalar(0x2959)!),"LeftFloor;":Character(Unicode.Scalar(0x230A)!),"leftharpoondown;":Character(Unicode.Scalar(0x21BD)!),"leftharpoonup;":Character(Unicode.Scalar(0x21BC)!),
    "leftleftarrows;":Character(Unicode.Scalar(0x21C7)!),"LeftRightArrow;":Character(Unicode.Scalar(0x2194)!),"Leftrightarrow;":Character(Unicode.Scalar(0x21D4)!),"leftrightarrow;":Character(Unicode.Scalar(0x2194)!),
    "leftrightarrows;":Character(Unicode.Scalar(0x21C6)!),"leftrightharpoons;":Character(Unicode.Scalar(0x21CB)!),"leftrightsquigarrow;":Character(Unicode.Scalar(0x21AD)!),"LeftRightVector;":Character(Unicode.Scalar(0x294E)!),
    "LeftTee;":Character(Unicode.Scalar(0x22A3)!),"LeftTeeArrow;":Character(Unicode.Scalar(0x21A4)!),"LeftTeeVector;":Character(Unicode.Scalar(0x295A)!),"leftthreetimes;":Character(Unicode.Scalar(0x22CB)!),
    "LeftTriangle;":Character(Unicode.Scalar(0x22B2)!),"LeftTriangleBar;":Character(Unicode.Scalar(0x29CF)!),"LeftTriangleEqual;":Character(Unicode.Scalar(0x22B4)!),"LeftUpDownVector;":Character(Unicode.Scalar(0x2951)!),
    "LeftUpTeeVector;":Character(Unicode.Scalar(0x2960)!),"LeftUpVector;":Character(Unicode.Scalar(0x21BF)!),"LeftUpVectorBar;":Character(Unicode.Scalar(0x2958)!),"LeftVector;":Character(Unicode.Scalar(0x21BC)!),
    "LeftVectorBar;":Character(Unicode.Scalar(0x2952)!),"lEg;":Character(Unicode.Scalar(0x2A8B)!),"leg;":Character(Unicode.Scalar(0x22DA)!),"leq;":Character(Unicode.Scalar(0x2264)!),
    "leqq;":Character(Unicode.Scalar(0x2266)!),"leqslant;":Character(Unicode.Scalar(0x2A7D)!),"les;":Character(Unicode.Scalar(0x2A7D)!),"lescc;":Character(Unicode.Scalar(0x2AA8)!),
    "lesdot;":Character(Unicode.Scalar(0x2A7F)!),"lesdoto;":Character(Unicode.Scalar(0x2A81)!),"lesdotor;":Character(Unicode.Scalar(0x2A83)!),"lesg;":"\u{22DA}\u{FE00}",
    "lesges;":Character(Unicode.Scalar(0x2A93)!),"lessapprox;":Character(Unicode.Scalar(0x2A85)!),"lessdot;":Character(Unicode.Scalar(0x22D6)!),"lesseqgtr;":Character(Unicode.Scalar(0x22DA)!),
    "lesseqqgtr;":Character(Unicode.Scalar(0x2A8B)!),"LessEqualGreater;":Character(Unicode.Scalar(0x22DA)!),"LessFullEqual;":Character(Unicode.Scalar(0x2266)!),"LessGreater;":Character(Unicode.Scalar(0x2276)!),
    "lessgtr;":Character(Unicode.Scalar(0x2276)!),"LessLess;":Character(Unicode.Scalar(0x2AA1)!),"lesssim;":Character(Unicode.Scalar(0x2272)!),"LessSlantEqual;":Character(Unicode.Scalar(0x2A7D)!),
    "LessTilde;":Character(Unicode.Scalar(0x2272)!),"lfisht;":Character(Unicode.Scalar(0x297C)!),"lfloor;":Character(Unicode.Scalar(0x230A)!),"Lfr;":Character(Unicode.Scalar(0x1D50F)!),
    "lfr;":Character(Unicode.Scalar(0x1D529)!),"lg;":Character(Unicode.Scalar(0x2276)!),"lgE;":Character(Unicode.Scalar(0x2A91)!),"lHar;":Character(Unicode.Scalar(0x2962)!),
    "lhard;":Character(Unicode.Scalar(0x21BD)!),"lharu;":Character(Unicode.Scalar(0x21BC)!),"lharul;":Character(Unicode.Scalar(0x296A)!),"lhblk;":Character(Unicode.Scalar(0x2584)!),
    "LJcy;":Character(Unicode.Scalar(0x409)!),"ljcy;":Character(Unicode.Scalar(0x459)!),"Ll;":Character(Unicode.Scalar(0x22D8)!),"ll;":Character(Unicode.Scalar(0x226A)!),
    "llarr;":Character(Unicode.Scalar(0x21C7)!),"llcorner;":Character(Unicode.Scalar(0x231E)!),"Lleftarrow;":Character(Unicode.Scalar(0x21DA)!),"llhard;":Character(Unicode.Scalar(0x296B)!),
    "lltri;":Character(Unicode.Scalar(0x25FA)!),"Lmidot;":Character(Unicode.Scalar(0x13F)!),"lmidot;":Character(Unicode.Scalar(0x140)!),"lmoust;":Character(Unicode.Scalar(0x23B0)!),
    "lmoustache;":Character(Unicode.Scalar(0x23B0)!),"lnap;":Character(Unicode.Scalar(0x2A89)!),"lnapprox;":Character(Unicode.Scalar(0x2A89)!),"lnE;":Character(Unicode.Scalar(0x2268)!),
    "lne;":Character(Unicode.Scalar(0x2A87)!),"lneq;":Character(Unicode.Scalar(0x2A87)!),"lneqq;":Character(Unicode.Scalar(0x2268)!),"lnsim;":Character(Unicode.Scalar(0x22E6)!),
    "loang;":Character(Unicode.Scalar(0x27EC)!),"loarr;":Character(Unicode.Scalar(0x21FD)!),"lobrk;":Character(Unicode.Scalar(0x27E6)!),"LongLeftArrow;":Character(Unicode.Scalar(0x27F5)!),
    "Longleftarrow;":Character(Unicode.Scalar(0x27F8)!),"longleftarrow;":Character(Unicode.Scalar(0x27F5)!),"LongLeftRightArrow;":Character(Unicode.Scalar(0x27F7)!),"Longleftrightarrow;":Character(Unicode.Scalar(0x27FA)!),
    "longleftrightarrow;":Character(Unicode.Scalar(0x27F7)!),"longmapsto;":Character(Unicode.Scalar(0x27FC)!),"LongRightArrow;":Character(Unicode.Scalar(0x27F6)!),"Longrightarrow;":Character(Unicode.Scalar(0x27F9)!),
    "longrightarrow;":Character(Unicode.Scalar(0x27F6)!),"looparrowleft;":Character(Unicode.Scalar(0x21AB)!),"looparrowright;":Character(Unicode.Scalar(0x21AC)!),"lopar;":Character(Unicode.Scalar(0x2985)!),
    "Lopf;":Character(Unicode.Scalar(0x1D543)!),"lopf;":Character(Unicode.Scalar(0x1D55D)!),"loplus;":Character(Unicode.Scalar(0x2A2D)!),"lotimes;":Character(Unicode.Scalar(0x2A34)!),
    "lowast;":Character(Unicode.Scalar(0x2217)!),"lowbar;":Character(Unicode.Scalar(0x5F)!),"LowerLeftArrow;":Character(Unicode.Scalar(0x2199)!),"LowerRightArrow;":Character(Unicode.Scalar(0x2198)!),
    "loz;":Character(Unicode.Scalar(0x25CA)!),"lozenge;":Character(Unicode.Scalar(0x25CA)!),"lozf;":Character(Unicode.Scalar(0x29EB)!),"lpar;":Character(Unicode.Scalar(0x28)!),
    "lparlt;":Character(Unicode.Scalar(0x2993)!),"lrarr;":Character(Unicode.Scalar(0x21C6)!),"lrcorner;":Character(Unicode.Scalar(0x231F)!),"lrhar;":Character(Unicode.Scalar(0x21CB)!),
    "lrhard;":Character(Unicode.Scalar(0x296D)!),"lrm;":Character(Unicode.Scalar(0x200E)!),"lrtri;":Character(Unicode.Scalar(0x22BF)!),"lsaquo;":Character(Unicode.Scalar(0x2039)!),
    "Lscr;":Character(Unicode.Scalar(0x2112)!),"lscr;":Character(Unicode.Scalar(0x1D4C1)!),"Lsh;":Character(Unicode.Scalar(0x21B0)!),"lsh;":Character(Unicode.Scalar(0x21B0)!),
    "lsim;":Character(Unicode.Scalar(0x2272)!),"lsime;":Character(Unicode.Scalar(0x2A8D)!),"lsimg;":Character(Unicode.Scalar(0x2A8F)!),"lsqb;":Character(Unicode.Scalar(0x5B)!),
    "lsquo;":Character(Unicode.Scalar(0x2018)!),"lsquor;":Character(Unicode.Scalar(0x201A)!),"Lstrok;":Character(Unicode.Scalar(0x141)!),"lstrok;":Character(Unicode.Scalar(0x142)!),
    "LT;":Character(Unicode.Scalar(0x3C)!),"Lt;":Character(Unicode.Scalar(0x226A)!),"lt;":Character(Unicode.Scalar(0x3C)!),"ltcc;":Character(Unicode.Scalar(0x2AA6)!),
    "ltcir;":Character(Unicode.Scalar(0x2A79)!),"ltdot;":Character(Unicode.Scalar(0x22D6)!),"lthree;":Character(Unicode.Scalar(0x22CB)!),"ltimes;":Character(Unicode.Scalar(0x22C9)!),
    "ltlarr;":Character(Unicode.Scalar(0x2976)!),"ltquest;":Character(Unicode.Scalar(0x2A7B)!),"ltri;":Character(Unicode.Scalar(0x25C3)!),"ltrie;":Character(Unicode.Scalar(0x22B4)!),
    "ltrif;":Character(Unicode.Scalar(0x25C2)!),"ltrPar;":Character(Unicode.Scalar(0x2996)!),"lurdshar;":Character(Unicode.Scalar(0x294A)!),"luruhar;":Character(Unicode.Scalar(0x2966)!),
    "lvertneqq;":"\u{2268}\u{FE00}","lvnE;":"\u{2268}\u{FE00}","macr;":Character(Unicode.Scalar(0xAF)!),"male;":Character(Unicode.Scalar(0x2642)!),
    "malt;":Character(Unicode.Scalar(0x2720)!),"maltese;":Character(Unicode.Scalar(0x2720)!),"Map;":Character(Unicode.Scalar(0x2905)!),"map;":Character(Unicode.Scalar(0x21A6)!),
    "mapsto;":Character(Unicode.Scalar(0x21A6)!),"mapstodown;":Character(Unicode.Scalar(0x21A7)!),"mapstoleft;":Character(Unicode.Scalar(0x21A4)!),"mapstoup;":Character(Unicode.Scalar(0x21A5)!),
    "marker;":Character(Unicode.Scalar(0x25AE)!),"mcomma;":Character(Unicode.Scalar(0x2A29)!),"Mcy;":Character(Unicode.Scalar(0x41C)!),"mcy;":Character(Unicode.Scalar(0x43C)!),
    "mdash;":Character(Unicode.Scalar(0x2014)!),"mDDot;":Character(Unicode.Scalar(0x223A)!),"measuredangle;":Character(Unicode.Scalar(0x2221)!),"MediumSpace;":Character(Unicode.Scalar(0x205F)!),
    "Mellintrf;":Character(Unicode.Scalar(0x2133)!),"Mfr;":Character(Unicode.Scalar(0x1D510)!),"mfr;":Character(Unicode.Scalar(0x1D52A)!),"mho;":Character(Unicode.Scalar(0x2127)!),
    "micro;":Character(Unicode.Scalar(0xB5)!),"mid;":Character(Unicode.Scalar(0x2223)!),"midast;":Character(Unicode.Scalar(0x2A)!),"midcir;":Character(Unicode.Scalar(0x2AF0)!),
    "middot;":Character(Unicode.Scalar(0xB7)!),"minus;":Character(Unicode.Scalar(0x2212)!),"minusb;":Character(Unicode.Scalar(0x229F)!),"minusd;":Character(Unicode.Scalar(0x2238)!),
    "minusdu;":Character(Unicode.Scalar(0x2A2A)!),"MinusPlus;":Character(Unicode.Scalar(0x2213)!),"mlcp;":Character(Unicode.Scalar(0x2ADB)!),"mldr;":Character(Unicode.Scalar(0x2026)!)
]

let namedCharactersDecodeMap2: [String: Character] = [
    "mnplus;":Character(Unicode.Scalar(0x2213)!),"models;":Character(Unicode.Scalar(0x22A7)!),"Mopf;":Character(Unicode.Scalar(0x1D544)!),"mopf;":Character(Unicode.Scalar(0x1D55E)!),
    "mp;":Character(Unicode.Scalar(0x2213)!),"Mscr;":Character(Unicode.Scalar(0x2133)!),"mscr;":Character(Unicode.Scalar(0x1D4C2)!),"mstpos;":Character(Unicode.Scalar(0x223E)!),
    "Mu;":Character(Unicode.Scalar(0x39C)!),"mu;":Character(Unicode.Scalar(0x3BC)!),"multimap;":Character(Unicode.Scalar(0x22B8)!),"mumap;":Character(Unicode.Scalar(0x22B8)!),
    "nabla;":Character(Unicode.Scalar(0x2207)!),"Nacute;":Character(Unicode.Scalar(0x143)!),"nacute;":Character(Unicode.Scalar(0x144)!),"nang;":"\u{2220}\u{20D2}",
    "nap;":Character(Unicode.Scalar(0x2249)!),"napE;":"\u{2A70}\u{338}","napid;":"\u{224B}\u{338}","napos;":Character(Unicode.Scalar(0x149)!),
    "napprox;":Character(Unicode.Scalar(0x2249)!),"natur;":Character(Unicode.Scalar(0x266E)!),"natural;":Character(Unicode.Scalar(0x266E)!),"naturals;":Character(Unicode.Scalar(0x2115)!),
    "nbsp;":Character(Unicode.Scalar(0xA0)!),"nbump;":"\u{224E}\u{338}","nbumpe;":"\u{224F}\u{338}","ncap;":Character(Unicode.Scalar(0x2A43)!),
    "Ncaron;":Character(Unicode.Scalar(0x147)!),"ncaron;":Character(Unicode.Scalar(0x148)!),"Ncedil;":Character(Unicode.Scalar(0x145)!),"ncedil;":Character(Unicode.Scalar(0x146)!),
    "ncong;":Character(Unicode.Scalar(0x2247)!),"ncongdot;":"\u{2A6D}\u{338}","ncup;":Character(Unicode.Scalar(0x2A42)!),"Ncy;":Character(Unicode.Scalar(0x41D)!),
    "ncy;":Character(Unicode.Scalar(0x43D)!),"ndash;":Character(Unicode.Scalar(0x2013)!),"ne;":Character(Unicode.Scalar(0x2260)!),"nearhk;":Character(Unicode.Scalar(0x2924)!),
    "neArr;":Character(Unicode.Scalar(0x21D7)!),"nearr;":Character(Unicode.Scalar(0x2197)!),"nearrow;":Character(Unicode.Scalar(0x2197)!),"nedot;":"\u{2250}\u{338}",
    "NegativeMediumSpace;":Character(Unicode.Scalar(0x200B)!),"NegativeThickSpace;":Character(Unicode.Scalar(0x200B)!),"NegativeThinSpace;":Character(Unicode.Scalar(0x200B)!),"NegativeVeryThinSpace;":Character(Unicode.Scalar(0x200B)!),
    "nequiv;":Character(Unicode.Scalar(0x2262)!),"nesear;":Character(Unicode.Scalar(0x2928)!),"nesim;":"\u{2242}\u{338}","NestedGreaterGreater;":Character(Unicode.Scalar(0x226B)!),
    "NestedLessLess;":Character(Unicode.Scalar(0x226A)!),"NewLine;":Character(Unicode.Scalar(0xA)!),"nexist;":Character(Unicode.Scalar(0x2204)!),"nexists;":Character(Unicode.Scalar(0x2204)!),
    "Nfr;":Character(Unicode.Scalar(0x1D511)!),"nfr;":Character(Unicode.Scalar(0x1D52B)!),"ngE;":"\u{2267}\u{338}","nge;":Character(Unicode.Scalar(0x2271)!),
    "ngeq;":Character(Unicode.Scalar(0x2271)!),"ngeqq;":"\u{2267}\u{338}","ngeqslant;":"\u{2A7E}\u{338}","nges;":"\u{2A7E}\u{338}",
    "nGg;":"\u{22D9}\u{338}","ngsim;":Character(Unicode.Scalar(0x2275)!),"nGt;":"\u{226B}\u{20D2}","ngt;":Character(Unicode.Scalar(0x226F)!),
    "ngtr;":Character(Unicode.Scalar(0x226F)!),"nGtv;":"\u{226B}\u{338}","nhArr;":Character(Unicode.Scalar(0x21CE)!),"nharr;":Character(Unicode.Scalar(0x21AE)!),
    "nhpar;":Character(Unicode.Scalar(0x2AF2)!),"ni;":Character(Unicode.Scalar(0x220B)!),"nis;":Character(Unicode.Scalar(0x22FC)!),"nisd;":Character(Unicode.Scalar(0x22FA)!),
    "niv;":Character(Unicode.Scalar(0x220B)!),"NJcy;":Character(Unicode.Scalar(0x40A)!),"njcy;":Character(Unicode.Scalar(0x45A)!),"nlArr;":Character(Unicode.Scalar(0x21CD)!),
    "nlarr;":Character(Unicode.Scalar(0x219A)!),"nldr;":Character(Unicode.Scalar(0x2025)!),"nlE;":"\u{2266}\u{338}","nle;":Character(Unicode.Scalar(0x2270)!),
    "nLeftarrow;":Character(Unicode.Scalar(0x21CD)!),"nleftarrow;":Character(Unicode.Scalar(0x219A)!),"nLeftrightarrow;":Character(Unicode.Scalar(0x21CE)!),"nleftrightarrow;":Character(Unicode.Scalar(0x21AE)!),
    "nleq;":Character(Unicode.Scalar(0x2270)!),"nleqq;":"\u{2266}\u{338}","nleqslant;":"\u{2A7D}\u{338}","nles;":"\u{2A7D}\u{338}",
    "nless;":Character(Unicode.Scalar(0x226E)!),"nLl;":"\u{22D8}\u{338}","nlsim;":Character(Unicode.Scalar(0x2274)!),"nLt;":"\u{226A}\u{338}",
    "nlt;":Character(Unicode.Scalar(0x226E)!),"nltri;":Character(Unicode.Scalar(0x22EA)!),"nltrie;":Character(Unicode.Scalar(0x22EC)!),"nLtv;":"\u{226A}\u{338}",
    "nmid;":Character(Unicode.Scalar(0x2224)!),"NoBreak;":Character(Unicode.Scalar(0x2060)!),"NonBreakingSpace;":Character(Unicode.Scalar(0xA0)!),"Nopf;":Character(Unicode.Scalar(0x2115)!),
    "nopf;":Character(Unicode.Scalar(0x1D55F)!),"Not;":Character(Unicode.Scalar(0x2AEC)!),"not;":Character(Unicode.Scalar(0xAC)!),"NotCongruent;":Character(Unicode.Scalar(0x2262)!),
    "NotCupCap;":Character(Unicode.Scalar(0x226D)!),"NotDoubleVerticalBar;":Character(Unicode.Scalar(0x2226)!),"NotElement;":Character(Unicode.Scalar(0x2209)!),"NotEqual;":Character(Unicode.Scalar(0x2260)!),
    "NotEqualTilde;":"\u{2242}\u{338}","NotExists;":Character(Unicode.Scalar(0x2204)!),"NotGreater;":Character(Unicode.Scalar(0x226F)!),"NotGreaterEqual;":Character(Unicode.Scalar(0x2271)!),
    "NotGreaterFullEqual;":"\u{2267}\u{338}","NotGreaterGreater;":"\u{226B}\u{338}","NotGreaterLess;":Character(Unicode.Scalar(0x2279)!),"NotGreaterSlantEqual;":"\u{2A7E}\u{338}",
    "NotGreaterTilde;":Character(Unicode.Scalar(0x2275)!),"NotHumpDownHump;":"\u{224E}\u{338}","NotHumpEqual;":"\u{224F}\u{338}","notin;":Character(Unicode.Scalar(0x2209)!),
    "notindot;":"\u{22F5}\u{338}","notinE;":"\u{22F9}\u{338}","notinva;":Character(Unicode.Scalar(0x2209)!),"notinvb;":Character(Unicode.Scalar(0x22F7)!),
    "notinvc;":Character(Unicode.Scalar(0x22F6)!),"NotLeftTriangle;":Character(Unicode.Scalar(0x22EA)!),"NotLeftTriangleBar;":"\u{29CF}\u{338}","NotLeftTriangleEqual;":Character(Unicode.Scalar(0x22EC)!),
    "NotLess;":Character(Unicode.Scalar(0x226E)!),"NotLessEqual;":Character(Unicode.Scalar(0x2270)!),"NotLessGreater;":Character(Unicode.Scalar(0x2278)!),"NotLessLess;":"\u{226A}\u{338}",
    "NotLessSlantEqual;":"\u{2A7D}\u{338}","NotLessTilde;":Character(Unicode.Scalar(0x2274)!),"NotNestedGreaterGreater;":"\u{2AA2}\u{338}","NotNestedLessLess;":"\u{2AA1}\u{338}",
    "notni;":Character(Unicode.Scalar(0x220C)!),"notniva;":Character(Unicode.Scalar(0x220C)!),"notnivb;":Character(Unicode.Scalar(0x22FE)!),"notnivc;":Character(Unicode.Scalar(0x22FD)!),
    "NotPrecedes;":Character(Unicode.Scalar(0x2280)!),"NotPrecedesEqual;":"\u{2AAF}\u{338}","NotPrecedesSlantEqual;":Character(Unicode.Scalar(0x22E0)!),"NotReverseElement;":Character(Unicode.Scalar(0x220C)!),
    "NotRightTriangle;":Character(Unicode.Scalar(0x22EB)!),"NotRightTriangleBar;":"\u{29D0}\u{338}","NotRightTriangleEqual;":Character(Unicode.Scalar(0x22ED)!),"NotSquareSubset;":"\u{228F}\u{338}",
    "NotSquareSubsetEqual;":Character(Unicode.Scalar(0x22E2)!),"NotSquareSuperset;":"\u{2290}\u{338}","NotSquareSupersetEqual;":Character(Unicode.Scalar(0x22E3)!),"NotSubset;":"\u{2282}\u{20D2}",
    "NotSubsetEqual;":Character(Unicode.Scalar(0x2288)!),"NotSucceeds;":Character(Unicode.Scalar(0x2281)!),"NotSucceedsEqual;":"\u{2AB0}\u{338}","NotSucceedsSlantEqual;":Character(Unicode.Scalar(0x22E1)!),
    "NotSucceedsTilde;":"\u{227F}\u{338}","NotSuperset;":"\u{2283}\u{20D2}","NotSupersetEqual;":Character(Unicode.Scalar(0x2289)!),"NotTilde;":Character(Unicode.Scalar(0x2241)!),
    "NotTildeEqual;":Character(Unicode.Scalar(0x2244)!),"NotTildeFullEqual;":Character(Unicode.Scalar(0x2247)!),"NotTildeTilde;":Character(Unicode.Scalar(0x2249)!),"NotVerticalBar;":Character(Unicode.Scalar(0x2224)!),
    "npar;":Character(Unicode.Scalar(0x2226)!),"nparallel;":Character(Unicode.Scalar(0x2226)!),"nparsl;":"\u{2AFD}\u{20E5}","npart;":"\u{2202}\u{338}",
    "npolint;":Character(Unicode.Scalar(0x2A14)!),"npr;":Character(Unicode.Scalar(0x2280)!),"nprcue;":Character(Unicode.Scalar(0x22E0)!),"npre;":"\u{2AAF}\u{338}",
    "nprec;":Character(Unicode.Scalar(0x2280)!),"npreceq;":"\u{2AAF}\u{338}","nrArr;":Character(Unicode.Scalar(0x21CF)!),"nrarr;":Character(Unicode.Scalar(0x219B)!),
    "nrarrc;":"\u{2933}\u{338}","nrarrw;":"\u{219D}\u{338}","nRightarrow;":Character(Unicode.Scalar(0x21CF)!),"nrightarrow;":Character(Unicode.Scalar(0x219B)!),
    "nrtri;":Character(Unicode.Scalar(0x22EB)!),"nrtrie;":Character(Unicode.Scalar(0x22ED)!),"nsc;":Character(Unicode.Scalar(0x2281)!),"nsccue;":Character(Unicode.Scalar(0x22E1)!),
    "nsce;":"\u{2AB0}\u{338}","Nscr;":Character(Unicode.Scalar(0x1D4A9)!),"nscr;":Character(Unicode.Scalar(0x1D4C3)!),"nshortmid;":Character(Unicode.Scalar(0x2224)!),
    "nshortparallel;":Character(Unicode.Scalar(0x2226)!),"nsim;":Character(Unicode.Scalar(0x2241)!),"nsime;":Character(Unicode.Scalar(0x2244)!),"nsimeq;":Character(Unicode.Scalar(0x2244)!),
    "nsmid;":Character(Unicode.Scalar(0x2224)!),"nspar;":Character(Unicode.Scalar(0x2226)!),"nsqsube;":Character(Unicode.Scalar(0x22E2)!),"nsqsupe;":Character(Unicode.Scalar(0x22E3)!),
    "nsub;":Character(Unicode.Scalar(0x2284)!),"nsubE;":"\u{2AC5}\u{338}","nsube;":Character(Unicode.Scalar(0x2288)!),"nsubset;":"\u{2282}\u{20D2}",
    "nsubseteq;":Character(Unicode.Scalar(0x2288)!),"nsubseteqq;":"\u{2AC5}\u{338}","nsucc;":Character(Unicode.Scalar(0x2281)!),"nsucceq;":"\u{2AB0}\u{338}",
    "nsup;":Character(Unicode.Scalar(0x2285)!),"nsupE;":"\u{2AC6}\u{338}","nsupe;":Character(Unicode.Scalar(0x2289)!),"nsupset;":"\u{2283}\u{20D2}",
    "nsupseteq;":Character(Unicode.Scalar(0x2289)!),"nsupseteqq;":"\u{2AC6}\u{338}","ntgl;":Character(Unicode.Scalar(0x2279)!),"Ntilde;":Character(Unicode.Scalar(0xD1)!),
    "ntilde;":Character(Unicode.Scalar(0xF1)!),"ntlg;":Character(Unicode.Scalar(0x2278)!),"ntriangleleft;":Character(Unicode.Scalar(0x22EA)!),"ntrianglelefteq;":Character(Unicode.Scalar(0x22EC)!),
    "ntriangleright;":Character(Unicode.Scalar(0x22EB)!),"ntrianglerighteq;":Character(Unicode.Scalar(0x22ED)!),"Nu;":Character(Unicode.Scalar(0x39D)!),"nu;":Character(Unicode.Scalar(0x3BD)!),
    "num;":Character(Unicode.Scalar(0x23)!),"numero;":Character(Unicode.Scalar(0x2116)!),"numsp;":Character(Unicode.Scalar(0x2007)!),"nvap;":"\u{224D}\u{20D2}",
    "nVDash;":Character(Unicode.Scalar(0x22AF)!),"nVdash;":Character(Unicode.Scalar(0x22AE)!),"nvDash;":Character(Unicode.Scalar(0x22AD)!),"nvdash;":Character(Unicode.Scalar(0x22AC)!),
    "nvge;":"\u{2265}\u{20D2}","nvgt;":"\u{3E}\u{20D2}","nvHarr;":Character(Unicode.Scalar(0x2904)!),"nvinfin;":Character(Unicode.Scalar(0x29DE)!),
    "nvlArr;":Character(Unicode.Scalar(0x2902)!),"nvle;":"\u{2264}\u{20D2}","nvlt;":"\u{3C}\u{20D2}","nvltrie;":"\u{22B4}\u{20D2}",
    "nvrArr;":Character(Unicode.Scalar(0x2903)!),"nvrtrie;":"\u{22B5}\u{20D2}","nvsim;":"\u{223C}\u{20D2}","nwarhk;":Character(Unicode.Scalar(0x2923)!),
    "nwArr;":Character(Unicode.Scalar(0x21D6)!),"nwarr;":Character(Unicode.Scalar(0x2196)!),"nwarrow;":Character(Unicode.Scalar(0x2196)!),"nwnear;":Character(Unicode.Scalar(0x2927)!),
    "Oacute;":Character(Unicode.Scalar(0xD3)!),"oacute;":Character(Unicode.Scalar(0xF3)!),"oast;":Character(Unicode.Scalar(0x229B)!),"ocir;":Character(Unicode.Scalar(0x229A)!),
    "Ocirc;":Character(Unicode.Scalar(0xD4)!),"ocirc;":Character(Unicode.Scalar(0xF4)!),"Ocy;":Character(Unicode.Scalar(0x41E)!),"ocy;":Character(Unicode.Scalar(0x43E)!),
    "odash;":Character(Unicode.Scalar(0x229D)!),"Odblac;":Character(Unicode.Scalar(0x150)!),"odblac;":Character(Unicode.Scalar(0x151)!),"odiv;":Character(Unicode.Scalar(0x2A38)!),
    "odot;":Character(Unicode.Scalar(0x2299)!),"odsold;":Character(Unicode.Scalar(0x29BC)!),"OElig;":Character(Unicode.Scalar(0x152)!),"oelig;":Character(Unicode.Scalar(0x153)!),
    "ofcir;":Character(Unicode.Scalar(0x29BF)!),"Ofr;":Character(Unicode.Scalar(0x1D512)!),"ofr;":Character(Unicode.Scalar(0x1D52C)!),"ogon;":Character(Unicode.Scalar(0x2DB)!),
    "Ograve;":Character(Unicode.Scalar(0xD2)!),"ograve;":Character(Unicode.Scalar(0xF2)!),"ogt;":Character(Unicode.Scalar(0x29C1)!),"ohbar;":Character(Unicode.Scalar(0x29B5)!),
    "ohm;":Character(Unicode.Scalar(0x3A9)!),"oint;":Character(Unicode.Scalar(0x222E)!),"olarr;":Character(Unicode.Scalar(0x21BA)!),"olcir;":Character(Unicode.Scalar(0x29BE)!),
    "olcross;":Character(Unicode.Scalar(0x29BB)!),"oline;":Character(Unicode.Scalar(0x203E)!),"olt;":Character(Unicode.Scalar(0x29C0)!),"Omacr;":Character(Unicode.Scalar(0x14C)!),
    "omacr;":Character(Unicode.Scalar(0x14D)!),"Omega;":Character(Unicode.Scalar(0x3A9)!),"omega;":Character(Unicode.Scalar(0x3C9)!),"Omicron;":Character(Unicode.Scalar(0x39F)!),
    "omicron;":Character(Unicode.Scalar(0x3BF)!),"omid;":Character(Unicode.Scalar(0x29B6)!),"ominus;":Character(Unicode.Scalar(0x2296)!),"Oopf;":Character(Unicode.Scalar(0x1D546)!),
    "oopf;":Character(Unicode.Scalar(0x1D560)!),"opar;":Character(Unicode.Scalar(0x29B7)!),"OpenCurlyDoubleQuote;":Character(Unicode.Scalar(0x201C)!),"OpenCurlyQuote;":Character(Unicode.Scalar(0x2018)!),
    "operp;":Character(Unicode.Scalar(0x29B9)!),"oplus;":Character(Unicode.Scalar(0x2295)!),"Or;":Character(Unicode.Scalar(0x2A54)!),"or;":Character(Unicode.Scalar(0x2228)!),
    "orarr;":Character(Unicode.Scalar(0x21BB)!),"ord;":Character(Unicode.Scalar(0x2A5D)!),"order;":Character(Unicode.Scalar(0x2134)!),"orderof;":Character(Unicode.Scalar(0x2134)!),
    "ordf;":Character(Unicode.Scalar(0xAA)!),"ordm;":Character(Unicode.Scalar(0xBA)!),"origof;":Character(Unicode.Scalar(0x22B6)!),"oror;":Character(Unicode.Scalar(0x2A56)!),
    "orslope;":Character(Unicode.Scalar(0x2A57)!),"orv;":Character(Unicode.Scalar(0x2A5B)!),"oS;":Character(Unicode.Scalar(0x24C8)!),"Oscr;":Character(Unicode.Scalar(0x1D4AA)!),
    "oscr;":Character(Unicode.Scalar(0x2134)!),"Oslash;":Character(Unicode.Scalar(0xD8)!),"oslash;":Character(Unicode.Scalar(0xF8)!),"osol;":Character(Unicode.Scalar(0x2298)!),
    "Otilde;":Character(Unicode.Scalar(0xD5)!),"otilde;":Character(Unicode.Scalar(0xF5)!),"Otimes;":Character(Unicode.Scalar(0x2A37)!),"otimes;":Character(Unicode.Scalar(0x2297)!),
    "otimesas;":Character(Unicode.Scalar(0x2A36)!),"Ouml;":Character(Unicode.Scalar(0xD6)!),"ouml;":Character(Unicode.Scalar(0xF6)!),"ovbar;":Character(Unicode.Scalar(0x233D)!),
    "OverBar;":Character(Unicode.Scalar(0x203E)!),"OverBrace;":Character(Unicode.Scalar(0x23DE)!),"OverBracket;":Character(Unicode.Scalar(0x23B4)!),"OverParenthesis;":Character(Unicode.Scalar(0x23DC)!),
    "par;":Character(Unicode.Scalar(0x2225)!),"para;":Character(Unicode.Scalar(0xB6)!),"parallel;":Character(Unicode.Scalar(0x2225)!),"parsim;":Character(Unicode.Scalar(0x2AF3)!),
    "parsl;":Character(Unicode.Scalar(0x2AFD)!),"part;":Character(Unicode.Scalar(0x2202)!),"PartialD;":Character(Unicode.Scalar(0x2202)!),"Pcy;":Character(Unicode.Scalar(0x41F)!),
    "pcy;":Character(Unicode.Scalar(0x43F)!),"percnt;":Character(Unicode.Scalar(0x25)!),"period;":Character(Unicode.Scalar(0x2E)!),"permil;":Character(Unicode.Scalar(0x2030)!),
    "perp;":Character(Unicode.Scalar(0x22A5)!),"pertenk;":Character(Unicode.Scalar(0x2031)!),"Pfr;":Character(Unicode.Scalar(0x1D513)!),"pfr;":Character(Unicode.Scalar(0x1D52D)!),
    "Phi;":Character(Unicode.Scalar(0x3A6)!),"phi;":Character(Unicode.Scalar(0x3C6)!),"phiv;":Character(Unicode.Scalar(0x3D5)!),"phmmat;":Character(Unicode.Scalar(0x2133)!),
    "phone;":Character(Unicode.Scalar(0x260E)!),"Pi;":Character(Unicode.Scalar(0x3A0)!),"pi;":Character(Unicode.Scalar(0x3C0)!),"pitchfork;":Character(Unicode.Scalar(0x22D4)!),
    "piv;":Character(Unicode.Scalar(0x3D6)!),"planck;":Character(Unicode.Scalar(0x210F)!),"planckh;":Character(Unicode.Scalar(0x210E)!),"plankv;":Character(Unicode.Scalar(0x210F)!),
    "plus;":Character(Unicode.Scalar(0x2B)!),"plusacir;":Character(Unicode.Scalar(0x2A23)!),"plusb;":Character(Unicode.Scalar(0x229E)!),"pluscir;":Character(Unicode.Scalar(0x2A22)!),
    "plusdo;":Character(Unicode.Scalar(0x2214)!),"plusdu;":Character(Unicode.Scalar(0x2A25)!),"pluse;":Character(Unicode.Scalar(0x2A72)!),"PlusMinus;":Character(Unicode.Scalar(0xB1)!),
    "plusmn;":Character(Unicode.Scalar(0xB1)!),"plussim;":Character(Unicode.Scalar(0x2A26)!),"plustwo;":Character(Unicode.Scalar(0x2A27)!),"pm;":Character(Unicode.Scalar(0xB1)!),
    "Poincareplane;":Character(Unicode.Scalar(0x210C)!),"pointint;":Character(Unicode.Scalar(0x2A15)!),"Popf;":Character(Unicode.Scalar(0x2119)!),"popf;":Character(Unicode.Scalar(0x1D561)!),
    "pound;":Character(Unicode.Scalar(0xA3)!),"Pr;":Character(Unicode.Scalar(0x2ABB)!),"pr;":Character(Unicode.Scalar(0x227A)!),"prap;":Character(Unicode.Scalar(0x2AB7)!),
    "prcue;":Character(Unicode.Scalar(0x227C)!),"prE;":Character(Unicode.Scalar(0x2AB3)!),"pre;":Character(Unicode.Scalar(0x2AAF)!),"prec;":Character(Unicode.Scalar(0x227A)!),
    "precapprox;":Character(Unicode.Scalar(0x2AB7)!),"preccurlyeq;":Character(Unicode.Scalar(0x227C)!),"Precedes;":Character(Unicode.Scalar(0x227A)!),"PrecedesEqual;":Character(Unicode.Scalar(0x2AAF)!),
    "PrecedesSlantEqual;":Character(Unicode.Scalar(0x227C)!),"PrecedesTilde;":Character(Unicode.Scalar(0x227E)!),"preceq;":Character(Unicode.Scalar(0x2AAF)!),"precnapprox;":Character(Unicode.Scalar(0x2AB9)!),
    "precneqq;":Character(Unicode.Scalar(0x2AB5)!),"precnsim;":Character(Unicode.Scalar(0x22E8)!),"precsim;":Character(Unicode.Scalar(0x227E)!),"Prime;":Character(Unicode.Scalar(0x2033)!),
    "prime;":Character(Unicode.Scalar(0x2032)!),"primes;":Character(Unicode.Scalar(0x2119)!),"prnap;":Character(Unicode.Scalar(0x2AB9)!),"prnE;":Character(Unicode.Scalar(0x2AB5)!),
    "prnsim;":Character(Unicode.Scalar(0x22E8)!),"prod;":Character(Unicode.Scalar(0x220F)!),"Product;":Character(Unicode.Scalar(0x220F)!),"profalar;":Character(Unicode.Scalar(0x232E)!),
    "profline;":Character(Unicode.Scalar(0x2312)!),"profsurf;":Character(Unicode.Scalar(0x2313)!),"prop;":Character(Unicode.Scalar(0x221D)!),"Proportion;":Character(Unicode.Scalar(0x2237)!),
    "Proportional;":Character(Unicode.Scalar(0x221D)!),"propto;":Character(Unicode.Scalar(0x221D)!),"prsim;":Character(Unicode.Scalar(0x227E)!),"prurel;":Character(Unicode.Scalar(0x22B0)!),
    "Pscr;":Character(Unicode.Scalar(0x1D4AB)!),"pscr;":Character(Unicode.Scalar(0x1D4C5)!),"Psi;":Character(Unicode.Scalar(0x3A8)!),"psi;":Character(Unicode.Scalar(0x3C8)!),
    "puncsp;":Character(Unicode.Scalar(0x2008)!),"Qfr;":Character(Unicode.Scalar(0x1D514)!),"qfr;":Character(Unicode.Scalar(0x1D52E)!),"qint;":Character(Unicode.Scalar(0x2A0C)!),
    "Qopf;":Character(Unicode.Scalar(0x211A)!),"qopf;":Character(Unicode.Scalar(0x1D562)!),"qprime;":Character(Unicode.Scalar(0x2057)!),"Qscr;":Character(Unicode.Scalar(0x1D4AC)!),
    "qscr;":Character(Unicode.Scalar(0x1D4C6)!),"quaternions;":Character(Unicode.Scalar(0x210D)!),"quatint;":Character(Unicode.Scalar(0x2A16)!),"quest;":Character(Unicode.Scalar(0x3F)!),
    "questeq;":Character(Unicode.Scalar(0x225F)!),"QUOT;":Character(Unicode.Scalar(0x22)!),"quot;":Character(Unicode.Scalar(0x22)!),"rAarr;":Character(Unicode.Scalar(0x21DB)!),
    "race;":"\u{223D}\u{331}","Racute;":Character(Unicode.Scalar(0x154)!),"racute;":Character(Unicode.Scalar(0x155)!),"radic;":Character(Unicode.Scalar(0x221A)!),
    "raemptyv;":Character(Unicode.Scalar(0x29B3)!),"Rang;":Character(Unicode.Scalar(0x27EB)!),"rang;":Character(Unicode.Scalar(0x27E9)!),"rangd;":Character(Unicode.Scalar(0x2992)!),
    "range;":Character(Unicode.Scalar(0x29A5)!),"rangle;":Character(Unicode.Scalar(0x27E9)!),"raquo;":Character(Unicode.Scalar(0xBB)!),"Rarr;":Character(Unicode.Scalar(0x21A0)!),
    "rArr;":Character(Unicode.Scalar(0x21D2)!),"rarr;":Character(Unicode.Scalar(0x2192)!),"rarrap;":Character(Unicode.Scalar(0x2975)!),"rarrb;":Character(Unicode.Scalar(0x21E5)!),
    "rarrbfs;":Character(Unicode.Scalar(0x2920)!),"rarrc;":Character(Unicode.Scalar(0x2933)!),"rarrfs;":Character(Unicode.Scalar(0x291E)!),"rarrhk;":Character(Unicode.Scalar(0x21AA)!),
    "rarrlp;":Character(Unicode.Scalar(0x21AC)!),"rarrpl;":Character(Unicode.Scalar(0x2945)!),"rarrsim;":Character(Unicode.Scalar(0x2974)!),"Rarrtl;":Character(Unicode.Scalar(0x2916)!),
    "rarrtl;":Character(Unicode.Scalar(0x21A3)!),"rarrw;":Character(Unicode.Scalar(0x219D)!),"rAtail;":Character(Unicode.Scalar(0x291C)!),"ratail;":Character(Unicode.Scalar(0x291A)!),
    "ratio;":Character(Unicode.Scalar(0x2236)!),"rationals;":Character(Unicode.Scalar(0x211A)!),"RBarr;":Character(Unicode.Scalar(0x2910)!),"rBarr;":Character(Unicode.Scalar(0x290F)!),
    "rbarr;":Character(Unicode.Scalar(0x290D)!),"rbbrk;":Character(Unicode.Scalar(0x2773)!),"rbrace;":Character(Unicode.Scalar(0x7D)!),"rbrack;":Character(Unicode.Scalar(0x5D)!),
    "rbrke;":Character(Unicode.Scalar(0x298C)!),"rbrksld;":Character(Unicode.Scalar(0x298E)!),"rbrkslu;":Character(Unicode.Scalar(0x2990)!),"Rcaron;":Character(Unicode.Scalar(0x158)!),
    "rcaron;":Character(Unicode.Scalar(0x159)!),"Rcedil;":Character(Unicode.Scalar(0x156)!),"rcedil;":Character(Unicode.Scalar(0x157)!),"rceil;":Character(Unicode.Scalar(0x2309)!),
    "rcub;":Character(Unicode.Scalar(0x7D)!),"Rcy;":Character(Unicode.Scalar(0x420)!),"rcy;":Character(Unicode.Scalar(0x440)!),"rdca;":Character(Unicode.Scalar(0x2937)!),
    "rdldhar;":Character(Unicode.Scalar(0x2969)!),"rdquo;":Character(Unicode.Scalar(0x201D)!),"rdquor;":Character(Unicode.Scalar(0x201D)!),"rdsh;":Character(Unicode.Scalar(0x21B3)!),
    "Re;":Character(Unicode.Scalar(0x211C)!),"real;":Character(Unicode.Scalar(0x211C)!),"realine;":Character(Unicode.Scalar(0x211B)!),"realpart;":Character(Unicode.Scalar(0x211C)!),
    "reals;":Character(Unicode.Scalar(0x211D)!),"rect;":Character(Unicode.Scalar(0x25AD)!),"REG;":Character(Unicode.Scalar(0xAE)!),"reg;":Character(Unicode.Scalar(0xAE)!),
    "ReverseElement;":Character(Unicode.Scalar(0x220B)!),"ReverseEquilibrium;":Character(Unicode.Scalar(0x21CB)!),"ReverseUpEquilibrium;":Character(Unicode.Scalar(0x296F)!),"rfisht;":Character(Unicode.Scalar(0x297D)!),
    "rfloor;":Character(Unicode.Scalar(0x230B)!),"Rfr;":Character(Unicode.Scalar(0x211C)!),"rfr;":Character(Unicode.Scalar(0x1D52F)!),"rHar;":Character(Unicode.Scalar(0x2964)!),
    "rhard;":Character(Unicode.Scalar(0x21C1)!),"rharu;":Character(Unicode.Scalar(0x21C0)!),"rharul;":Character(Unicode.Scalar(0x296C)!),"Rho;":Character(Unicode.Scalar(0x3A1)!),
    "rho;":Character(Unicode.Scalar(0x3C1)!),"rhov;":Character(Unicode.Scalar(0x3F1)!),"RightAngleBracket;":Character(Unicode.Scalar(0x27E9)!),"RightArrow;":Character(Unicode.Scalar(0x2192)!),
    "Rightarrow;":Character(Unicode.Scalar(0x21D2)!),"rightarrow;":Character(Unicode.Scalar(0x2192)!),"RightArrowBar;":Character(Unicode.Scalar(0x21E5)!),"RightArrowLeftArrow;":Character(Unicode.Scalar(0x21C4)!),
    "rightarrowtail;":Character(Unicode.Scalar(0x21A3)!),"RightCeiling;":Character(Unicode.Scalar(0x2309)!),"RightDoubleBracket;":Character(Unicode.Scalar(0x27E7)!),"RightDownTeeVector;":Character(Unicode.Scalar(0x295D)!),
    "RightDownVector;":Character(Unicode.Scalar(0x21C2)!),"RightDownVectorBar;":Character(Unicode.Scalar(0x2955)!),"RightFloor;":Character(Unicode.Scalar(0x230B)!),"rightharpoondown;":Character(Unicode.Scalar(0x21C1)!),
    "rightharpoonup;":Character(Unicode.Scalar(0x21C0)!),"rightleftarrows;":Character(Unicode.Scalar(0x21C4)!),"rightleftharpoons;":Character(Unicode.Scalar(0x21CC)!),"rightrightarrows;":Character(Unicode.Scalar(0x21C9)!),
    "rightsquigarrow;":Character(Unicode.Scalar(0x219D)!),"RightTee;":Character(Unicode.Scalar(0x22A2)!),"RightTeeArrow;":Character(Unicode.Scalar(0x21A6)!),"RightTeeVector;":Character(Unicode.Scalar(0x295B)!),
    "rightthreetimes;":Character(Unicode.Scalar(0x22CC)!),"RightTriangle;":Character(Unicode.Scalar(0x22B3)!),"RightTriangleBar;":Character(Unicode.Scalar(0x29D0)!),"RightTriangleEqual;":Character(Unicode.Scalar(0x22B5)!),
    "RightUpDownVector;":Character(Unicode.Scalar(0x294F)!),"RightUpTeeVector;":Character(Unicode.Scalar(0x295C)!),"RightUpVector;":Character(Unicode.Scalar(0x21BE)!),"RightUpVectorBar;":Character(Unicode.Scalar(0x2954)!),
    "RightVector;":Character(Unicode.Scalar(0x21C0)!),"RightVectorBar;":Character(Unicode.Scalar(0x2953)!),"ring;":Character(Unicode.Scalar(0x2DA)!),"risingdotseq;":Character(Unicode.Scalar(0x2253)!),
    "rlarr;":Character(Unicode.Scalar(0x21C4)!),"rlhar;":Character(Unicode.Scalar(0x21CC)!),"rlm;":Character(Unicode.Scalar(0x200F)!),"rmoust;":Character(Unicode.Scalar(0x23B1)!),
    "rmoustache;":Character(Unicode.Scalar(0x23B1)!),"rnmid;":Character(Unicode.Scalar(0x2AEE)!),"roang;":Character(Unicode.Scalar(0x27ED)!),"roarr;":Character(Unicode.Scalar(0x21FE)!),
    "robrk;":Character(Unicode.Scalar(0x27E7)!),"ropar;":Character(Unicode.Scalar(0x2986)!),"Ropf;":Character(Unicode.Scalar(0x211D)!),"ropf;":Character(Unicode.Scalar(0x1D563)!),
    "roplus;":Character(Unicode.Scalar(0x2A2E)!),"rotimes;":Character(Unicode.Scalar(0x2A35)!),"RoundImplies;":Character(Unicode.Scalar(0x2970)!),"rpar;":Character(Unicode.Scalar(0x29)!),
    "rpargt;":Character(Unicode.Scalar(0x2994)!),"rppolint;":Character(Unicode.Scalar(0x2A12)!),"rrarr;":Character(Unicode.Scalar(0x21C9)!),"Rrightarrow;":Character(Unicode.Scalar(0x21DB)!),
    "rsaquo;":Character(Unicode.Scalar(0x203A)!),"Rscr;":Character(Unicode.Scalar(0x211B)!),"rscr;":Character(Unicode.Scalar(0x1D4C7)!),"Rsh;":Character(Unicode.Scalar(0x21B1)!),
    "rsh;":Character(Unicode.Scalar(0x21B1)!),"rsqb;":Character(Unicode.Scalar(0x5D)!),"rsquo;":Character(Unicode.Scalar(0x2019)!),"rsquor;":Character(Unicode.Scalar(0x2019)!),
    "rthree;":Character(Unicode.Scalar(0x22CC)!),"rtimes;":Character(Unicode.Scalar(0x22CA)!),"rtri;":Character(Unicode.Scalar(0x25B9)!),"rtrie;":Character(Unicode.Scalar(0x22B5)!),
    "rtrif;":Character(Unicode.Scalar(0x25B8)!),"rtriltri;":Character(Unicode.Scalar(0x29CE)!),"RuleDelayed;":Character(Unicode.Scalar(0x29F4)!),"ruluhar;":Character(Unicode.Scalar(0x2968)!),
    "rx;":Character(Unicode.Scalar(0x211E)!),"Sacute;":Character(Unicode.Scalar(0x15A)!),"sacute;":Character(Unicode.Scalar(0x15B)!),"sbquo;":Character(Unicode.Scalar(0x201A)!),
    "Sc;":Character(Unicode.Scalar(0x2ABC)!),"sc;":Character(Unicode.Scalar(0x227B)!),"scap;":Character(Unicode.Scalar(0x2AB8)!),"Scaron;":Character(Unicode.Scalar(0x160)!),
    "scaron;":Character(Unicode.Scalar(0x161)!),"sccue;":Character(Unicode.Scalar(0x227D)!),"scE;":Character(Unicode.Scalar(0x2AB4)!),"sce;":Character(Unicode.Scalar(0x2AB0)!),
    "Scedil;":Character(Unicode.Scalar(0x15E)!),"scedil;":Character(Unicode.Scalar(0x15F)!),"Scirc;":Character(Unicode.Scalar(0x15C)!),"scirc;":Character(Unicode.Scalar(0x15D)!),
    "scnap;":Character(Unicode.Scalar(0x2ABA)!),"scnE;":Character(Unicode.Scalar(0x2AB6)!),"scnsim;":Character(Unicode.Scalar(0x22E9)!),"scpolint;":Character(Unicode.Scalar(0x2A13)!),
    "scsim;":Character(Unicode.Scalar(0x227F)!),"Scy;":Character(Unicode.Scalar(0x421)!),"scy;":Character(Unicode.Scalar(0x441)!),"sdot;":Character(Unicode.Scalar(0x22C5)!),
    "sdotb;":Character(Unicode.Scalar(0x22A1)!),"sdote;":Character(Unicode.Scalar(0x2A66)!),"searhk;":Character(Unicode.Scalar(0x2925)!),"seArr;":Character(Unicode.Scalar(0x21D8)!),
    "searr;":Character(Unicode.Scalar(0x2198)!),"searrow;":Character(Unicode.Scalar(0x2198)!),"sect;":Character(Unicode.Scalar(0xA7)!),"semi;":Character(Unicode.Scalar(0x3B)!),
    "seswar;":Character(Unicode.Scalar(0x2929)!),"setminus;":Character(Unicode.Scalar(0x2216)!),"setmn;":Character(Unicode.Scalar(0x2216)!),"sext;":Character(Unicode.Scalar(0x2736)!),
    "Sfr;":Character(Unicode.Scalar(0x1D516)!),"sfr;":Character(Unicode.Scalar(0x1D530)!),"sfrown;":Character(Unicode.Scalar(0x2322)!),"sharp;":Character(Unicode.Scalar(0x266F)!),
    "SHCHcy;":Character(Unicode.Scalar(0x429)!),"shchcy;":Character(Unicode.Scalar(0x449)!),"SHcy;":Character(Unicode.Scalar(0x428)!),"shcy;":Character(Unicode.Scalar(0x448)!),
    "ShortDownArrow;":Character(Unicode.Scalar(0x2193)!),"ShortLeftArrow;":Character(Unicode.Scalar(0x2190)!),"shortmid;":Character(Unicode.Scalar(0x2223)!),"shortparallel;":Character(Unicode.Scalar(0x2225)!),
    "ShortRightArrow;":Character(Unicode.Scalar(0x2192)!),"ShortUpArrow;":Character(Unicode.Scalar(0x2191)!),"shy;":Character(Unicode.Scalar(0xAD)!),"Sigma;":Character(Unicode.Scalar(0x3A3)!),
    "sigma;":Character(Unicode.Scalar(0x3C3)!),"sigmaf;":Character(Unicode.Scalar(0x3C2)!),"sigmav;":Character(Unicode.Scalar(0x3C2)!),"sim;":Character(Unicode.Scalar(0x223C)!),
    "simdot;":Character(Unicode.Scalar(0x2A6A)!),"sime;":Character(Unicode.Scalar(0x2243)!),"simeq;":Character(Unicode.Scalar(0x2243)!),"simg;":Character(Unicode.Scalar(0x2A9E)!),
    "simgE;":Character(Unicode.Scalar(0x2AA0)!),"siml;":Character(Unicode.Scalar(0x2A9D)!),"simlE;":Character(Unicode.Scalar(0x2A9F)!),"simne;":Character(Unicode.Scalar(0x2246)!),
    "simplus;":Character(Unicode.Scalar(0x2A24)!),"simrarr;":Character(Unicode.Scalar(0x2972)!),"slarr;":Character(Unicode.Scalar(0x2190)!),"SmallCircle;":Character(Unicode.Scalar(0x2218)!),
    "smallsetminus;":Character(Unicode.Scalar(0x2216)!),"smashp;":Character(Unicode.Scalar(0x2A33)!),"smeparsl;":Character(Unicode.Scalar(0x29E4)!),"smid;":Character(Unicode.Scalar(0x2223)!),
    "smile;":Character(Unicode.Scalar(0x2323)!),"smt;":Character(Unicode.Scalar(0x2AAA)!),"smte;":Character(Unicode.Scalar(0x2AAC)!),"smtes;":"\u{2AAC}\u{FE00}",
    "SOFTcy;":Character(Unicode.Scalar(0x42C)!),"softcy;":Character(Unicode.Scalar(0x44C)!),"sol;":Character(Unicode.Scalar(0x2F)!),"solb;":Character(Unicode.Scalar(0x29C4)!),
    "solbar;":Character(Unicode.Scalar(0x233F)!),"Sopf;":Character(Unicode.Scalar(0x1D54A)!),"sopf;":Character(Unicode.Scalar(0x1D564)!),"spades;":Character(Unicode.Scalar(0x2660)!),
    "spadesuit;":Character(Unicode.Scalar(0x2660)!),"spar;":Character(Unicode.Scalar(0x2225)!),"sqcap;":Character(Unicode.Scalar(0x2293)!),"sqcaps;":"\u{2293}\u{FE00}",
    "sqcup;":Character(Unicode.Scalar(0x2294)!),"sqcups;":"\u{2294}\u{FE00}","Sqrt;":Character(Unicode.Scalar(0x221A)!),"sqsub;":Character(Unicode.Scalar(0x228F)!),
    "sqsube;":Character(Unicode.Scalar(0x2291)!),"sqsubset;":Character(Unicode.Scalar(0x228F)!),"sqsubseteq;":Character(Unicode.Scalar(0x2291)!),"sqsup;":Character(Unicode.Scalar(0x2290)!),
    "sqsupe;":Character(Unicode.Scalar(0x2292)!),"sqsupset;":Character(Unicode.Scalar(0x2290)!),"sqsupseteq;":Character(Unicode.Scalar(0x2292)!),"squ;":Character(Unicode.Scalar(0x25A1)!),
    "Square;":Character(Unicode.Scalar(0x25A1)!),"square;":Character(Unicode.Scalar(0x25A1)!),"SquareIntersection;":Character(Unicode.Scalar(0x2293)!),"SquareSubset;":Character(Unicode.Scalar(0x228F)!),
    "SquareSubsetEqual;":Character(Unicode.Scalar(0x2291)!),"SquareSuperset;":Character(Unicode.Scalar(0x2290)!),"SquareSupersetEqual;":Character(Unicode.Scalar(0x2292)!),"SquareUnion;":Character(Unicode.Scalar(0x2294)!),
    "squarf;":Character(Unicode.Scalar(0x25AA)!),"squf;":Character(Unicode.Scalar(0x25AA)!),"srarr;":Character(Unicode.Scalar(0x2192)!),"Sscr;":Character(Unicode.Scalar(0x1D4AE)!),
    "sscr;":Character(Unicode.Scalar(0x1D4C8)!),"ssetmn;":Character(Unicode.Scalar(0x2216)!),"ssmile;":Character(Unicode.Scalar(0x2323)!),"sstarf;":Character(Unicode.Scalar(0x22C6)!),
    "Star;":Character(Unicode.Scalar(0x22C6)!),"star;":Character(Unicode.Scalar(0x2606)!),"starf;":Character(Unicode.Scalar(0x2605)!),"straightepsilon;":Character(Unicode.Scalar(0x3F5)!),
    "straightphi;":Character(Unicode.Scalar(0x3D5)!),"strns;":Character(Unicode.Scalar(0xAF)!),"Sub;":Character(Unicode.Scalar(0x22D0)!),"sub;":Character(Unicode.Scalar(0x2282)!),
    "subdot;":Character(Unicode.Scalar(0x2ABD)!),"subE;":Character(Unicode.Scalar(0x2AC5)!),"sube;":Character(Unicode.Scalar(0x2286)!),"subedot;":Character(Unicode.Scalar(0x2AC3)!),
    "submult;":Character(Unicode.Scalar(0x2AC1)!),"subnE;":Character(Unicode.Scalar(0x2ACB)!),"subne;":Character(Unicode.Scalar(0x228A)!),"subplus;":Character(Unicode.Scalar(0x2ABF)!),
    "subrarr;":Character(Unicode.Scalar(0x2979)!),"Subset;":Character(Unicode.Scalar(0x22D0)!),"subset;":Character(Unicode.Scalar(0x2282)!),"subseteq;":Character(Unicode.Scalar(0x2286)!),
    "subseteqq;":Character(Unicode.Scalar(0x2AC5)!),"SubsetEqual;":Character(Unicode.Scalar(0x2286)!),"subsetneq;":Character(Unicode.Scalar(0x228A)!),"subsetneqq;":Character(Unicode.Scalar(0x2ACB)!),
    "subsim;":Character(Unicode.Scalar(0x2AC7)!),"subsub;":Character(Unicode.Scalar(0x2AD5)!),"subsup;":Character(Unicode.Scalar(0x2AD3)!),"succ;":Character(Unicode.Scalar(0x227B)!),
    "succapprox;":Character(Unicode.Scalar(0x2AB8)!),"succcurlyeq;":Character(Unicode.Scalar(0x227D)!),"Succeeds;":Character(Unicode.Scalar(0x227B)!),"SucceedsEqual;":Character(Unicode.Scalar(0x2AB0)!),
    "SucceedsSlantEqual;":Character(Unicode.Scalar(0x227D)!),"SucceedsTilde;":Character(Unicode.Scalar(0x227F)!),"succeq;":Character(Unicode.Scalar(0x2AB0)!),"succnapprox;":Character(Unicode.Scalar(0x2ABA)!),
    "succneqq;":Character(Unicode.Scalar(0x2AB6)!),"succnsim;":Character(Unicode.Scalar(0x22E9)!),"succsim;":Character(Unicode.Scalar(0x227F)!),"SuchThat;":Character(Unicode.Scalar(0x220B)!),
    "Sum;":Character(Unicode.Scalar(0x2211)!),"sum;":Character(Unicode.Scalar(0x2211)!),"sung;":Character(Unicode.Scalar(0x266A)!),"Sup;":Character(Unicode.Scalar(0x22D1)!),
    "sup;":Character(Unicode.Scalar(0x2283)!),"sup1;":Character(Unicode.Scalar(0xB9)!),"sup2;":Character(Unicode.Scalar(0xB2)!),"sup3;":Character(Unicode.Scalar(0xB3)!),
    "supdot;":Character(Unicode.Scalar(0x2ABE)!),"supdsub;":Character(Unicode.Scalar(0x2AD8)!),"supE;":Character(Unicode.Scalar(0x2AC6)!),"supe;":Character(Unicode.Scalar(0x2287)!),
    "supedot;":Character(Unicode.Scalar(0x2AC4)!),"Superset;":Character(Unicode.Scalar(0x2283)!),"SupersetEqual;":Character(Unicode.Scalar(0x2287)!),"suphsol;":Character(Unicode.Scalar(0x27C9)!),
    "suphsub;":Character(Unicode.Scalar(0x2AD7)!),"suplarr;":Character(Unicode.Scalar(0x297B)!),"supmult;":Character(Unicode.Scalar(0x2AC2)!),"supnE;":Character(Unicode.Scalar(0x2ACC)!),
    "supne;":Character(Unicode.Scalar(0x228B)!),"supplus;":Character(Unicode.Scalar(0x2AC0)!),"Supset;":Character(Unicode.Scalar(0x22D1)!),"supset;":Character(Unicode.Scalar(0x2283)!),
    "supseteq;":Character(Unicode.Scalar(0x2287)!),"supseteqq;":Character(Unicode.Scalar(0x2AC6)!),"supsetneq;":Character(Unicode.Scalar(0x228B)!),"supsetneqq;":Character(Unicode.Scalar(0x2ACC)!),
    "supsim;":Character(Unicode.Scalar(0x2AC8)!),"supsub;":Character(Unicode.Scalar(0x2AD4)!),"supsup;":Character(Unicode.Scalar(0x2AD6)!),"swarhk;":Character(Unicode.Scalar(0x2926)!),
    "swArr;":Character(Unicode.Scalar(0x21D9)!),"swarr;":Character(Unicode.Scalar(0x2199)!),"swarrow;":Character(Unicode.Scalar(0x2199)!),"swnwar;":Character(Unicode.Scalar(0x292A)!),
    "szlig;":Character(Unicode.Scalar(0xDF)!),"Tab;":Character(Unicode.Scalar(0x9)!),"target;":Character(Unicode.Scalar(0x2316)!),"Tau;":Character(Unicode.Scalar(0x3A4)!),
    "tau;":Character(Unicode.Scalar(0x3C4)!),"tbrk;":Character(Unicode.Scalar(0x23B4)!),"Tcaron;":Character(Unicode.Scalar(0x164)!),"tcaron;":Character(Unicode.Scalar(0x165)!),
    "Tcedil;":Character(Unicode.Scalar(0x162)!),"tcedil;":Character(Unicode.Scalar(0x163)!),"Tcy;":Character(Unicode.Scalar(0x422)!),"tcy;":Character(Unicode.Scalar(0x442)!),
    "tdot;":Character(Unicode.Scalar(0x20DB)!),"telrec;":Character(Unicode.Scalar(0x2315)!),"Tfr;":Character(Unicode.Scalar(0x1D517)!),"tfr;":Character(Unicode.Scalar(0x1D531)!),
    "there4;":Character(Unicode.Scalar(0x2234)!),"Therefore;":Character(Unicode.Scalar(0x2234)!),"therefore;":Character(Unicode.Scalar(0x2234)!),"Theta;":Character(Unicode.Scalar(0x398)!),
    "theta;":Character(Unicode.Scalar(0x3B8)!),"thetasym;":Character(Unicode.Scalar(0x3D1)!),"thetav;":Character(Unicode.Scalar(0x3D1)!),"thickapprox;":Character(Unicode.Scalar(0x2248)!),
    "thicksim;":Character(Unicode.Scalar(0x223C)!),

    // Skip "ThickSpace;" due to Swift not recognizing it as a single grapheme cluster
    // "ThickSpace;":Character(Unicode.Scalar(0x205F}\u{200A)!),

    "thinsp;":Character(Unicode.Scalar(0x2009)!),"ThinSpace;":Character(Unicode.Scalar(0x2009)!),"thkap;":Character(Unicode.Scalar(0x2248)!),"thksim;":Character(Unicode.Scalar(0x223C)!),
    "THORN;":Character(Unicode.Scalar(0xDE)!),"thorn;":Character(Unicode.Scalar(0xFE)!),"Tilde;":Character(Unicode.Scalar(0x223C)!),"tilde;":Character(Unicode.Scalar(0x2DC)!),
    "TildeEqual;":Character(Unicode.Scalar(0x2243)!),"TildeFullEqual;":Character(Unicode.Scalar(0x2245)!),"TildeTilde;":Character(Unicode.Scalar(0x2248)!),"times;":Character(Unicode.Scalar(0xD7)!),
    "timesb;":Character(Unicode.Scalar(0x22A0)!),"timesbar;":Character(Unicode.Scalar(0x2A31)!),"timesd;":Character(Unicode.Scalar(0x2A30)!),"tint;":Character(Unicode.Scalar(0x222D)!),
    "toea;":Character(Unicode.Scalar(0x2928)!),"top;":Character(Unicode.Scalar(0x22A4)!),"topbot;":Character(Unicode.Scalar(0x2336)!),"topcir;":Character(Unicode.Scalar(0x2AF1)!),
    "Topf;":Character(Unicode.Scalar(0x1D54B)!),"topf;":Character(Unicode.Scalar(0x1D565)!),"topfork;":Character(Unicode.Scalar(0x2ADA)!),"tosa;":Character(Unicode.Scalar(0x2929)!),
    "tprime;":Character(Unicode.Scalar(0x2034)!),"TRADE;":Character(Unicode.Scalar(0x2122)!),"trade;":Character(Unicode.Scalar(0x2122)!),"triangle;":Character(Unicode.Scalar(0x25B5)!),
    "triangledown;":Character(Unicode.Scalar(0x25BF)!),"triangleleft;":Character(Unicode.Scalar(0x25C3)!),"trianglelefteq;":Character(Unicode.Scalar(0x22B4)!),"triangleq;":Character(Unicode.Scalar(0x225C)!),
    "triangleright;":Character(Unicode.Scalar(0x25B9)!),"trianglerighteq;":Character(Unicode.Scalar(0x22B5)!),"tridot;":Character(Unicode.Scalar(0x25EC)!),"trie;":Character(Unicode.Scalar(0x225C)!),
    "triminus;":Character(Unicode.Scalar(0x2A3A)!),"TripleDot;":Character(Unicode.Scalar(0x20DB)!),"triplus;":Character(Unicode.Scalar(0x2A39)!),"trisb;":Character(Unicode.Scalar(0x29CD)!),
    "tritime;":Character(Unicode.Scalar(0x2A3B)!),"trpezium;":Character(Unicode.Scalar(0x23E2)!),"Tscr;":Character(Unicode.Scalar(0x1D4AF)!),"tscr;":Character(Unicode.Scalar(0x1D4C9)!),
    "TScy;":Character(Unicode.Scalar(0x426)!),"tscy;":Character(Unicode.Scalar(0x446)!),"TSHcy;":Character(Unicode.Scalar(0x40B)!),"tshcy;":Character(Unicode.Scalar(0x45B)!),
    "Tstrok;":Character(Unicode.Scalar(0x166)!),"tstrok;":Character(Unicode.Scalar(0x167)!),"twixt;":Character(Unicode.Scalar(0x226C)!),"twoheadleftarrow;":Character(Unicode.Scalar(0x219E)!),
    "twoheadrightarrow;":Character(Unicode.Scalar(0x21A0)!),"Uacute;":Character(Unicode.Scalar(0xDA)!),"uacute;":Character(Unicode.Scalar(0xFA)!),"Uarr;":Character(Unicode.Scalar(0x219F)!),
    "uArr;":Character(Unicode.Scalar(0x21D1)!),"uarr;":Character(Unicode.Scalar(0x2191)!),"Uarrocir;":Character(Unicode.Scalar(0x2949)!),"Ubrcy;":Character(Unicode.Scalar(0x40E)!),
    "ubrcy;":Character(Unicode.Scalar(0x45E)!),"Ubreve;":Character(Unicode.Scalar(0x16C)!),"ubreve;":Character(Unicode.Scalar(0x16D)!),"Ucirc;":Character(Unicode.Scalar(0xDB)!),
    "ucirc;":Character(Unicode.Scalar(0xFB)!),"Ucy;":Character(Unicode.Scalar(0x423)!),"ucy;":Character(Unicode.Scalar(0x443)!),"udarr;":Character(Unicode.Scalar(0x21C5)!),
    "Udblac;":Character(Unicode.Scalar(0x170)!),"udblac;":Character(Unicode.Scalar(0x171)!),"udhar;":Character(Unicode.Scalar(0x296E)!),"ufisht;":Character(Unicode.Scalar(0x297E)!),
    "Ufr;":Character(Unicode.Scalar(0x1D518)!),"ufr;":Character(Unicode.Scalar(0x1D532)!),"Ugrave;":Character(Unicode.Scalar(0xD9)!),"ugrave;":Character(Unicode.Scalar(0xF9)!),
    "uHar;":Character(Unicode.Scalar(0x2963)!),"uharl;":Character(Unicode.Scalar(0x21BF)!),"uharr;":Character(Unicode.Scalar(0x21BE)!),"uhblk;":Character(Unicode.Scalar(0x2580)!),
    "ulcorn;":Character(Unicode.Scalar(0x231C)!),"ulcorner;":Character(Unicode.Scalar(0x231C)!),"ulcrop;":Character(Unicode.Scalar(0x230F)!),"ultri;":Character(Unicode.Scalar(0x25F8)!),
    "Umacr;":Character(Unicode.Scalar(0x16A)!),"umacr;":Character(Unicode.Scalar(0x16B)!),"uml;":Character(Unicode.Scalar(0xA8)!),"UnderBar;":Character(Unicode.Scalar(0x5F)!),
    "UnderBrace;":Character(Unicode.Scalar(0x23DF)!),"UnderBracket;":Character(Unicode.Scalar(0x23B5)!),"UnderParenthesis;":Character(Unicode.Scalar(0x23DD)!),"Union;":Character(Unicode.Scalar(0x22C3)!),
    "UnionPlus;":Character(Unicode.Scalar(0x228E)!),"Uogon;":Character(Unicode.Scalar(0x172)!),"uogon;":Character(Unicode.Scalar(0x173)!),"Uopf;":Character(Unicode.Scalar(0x1D54C)!),
    "uopf;":Character(Unicode.Scalar(0x1D566)!),"UpArrow;":Character(Unicode.Scalar(0x2191)!),"Uparrow;":Character(Unicode.Scalar(0x21D1)!),"uparrow;":Character(Unicode.Scalar(0x2191)!),
    "UpArrowBar;":Character(Unicode.Scalar(0x2912)!),"UpArrowDownArrow;":Character(Unicode.Scalar(0x21C5)!),"UpDownArrow;":Character(Unicode.Scalar(0x2195)!),"Updownarrow;":Character(Unicode.Scalar(0x21D5)!),
    "updownarrow;":Character(Unicode.Scalar(0x2195)!),"UpEquilibrium;":Character(Unicode.Scalar(0x296E)!),"upharpoonleft;":Character(Unicode.Scalar(0x21BF)!),"upharpoonright;":Character(Unicode.Scalar(0x21BE)!),
    "uplus;":Character(Unicode.Scalar(0x228E)!),"UpperLeftArrow;":Character(Unicode.Scalar(0x2196)!),"UpperRightArrow;":Character(Unicode.Scalar(0x2197)!),"Upsi;":Character(Unicode.Scalar(0x3D2)!),
    "upsi;":Character(Unicode.Scalar(0x3C5)!),"upsih;":Character(Unicode.Scalar(0x3D2)!),"Upsilon;":Character(Unicode.Scalar(0x3A5)!),"upsilon;":Character(Unicode.Scalar(0x3C5)!),
    "UpTee;":Character(Unicode.Scalar(0x22A5)!),"UpTeeArrow;":Character(Unicode.Scalar(0x21A5)!),"upuparrows;":Character(Unicode.Scalar(0x21C8)!),"urcorn;":Character(Unicode.Scalar(0x231D)!),
    "urcorner;":Character(Unicode.Scalar(0x231D)!),"urcrop;":Character(Unicode.Scalar(0x230E)!),"Uring;":Character(Unicode.Scalar(0x16E)!),"uring;":Character(Unicode.Scalar(0x16F)!),
    "urtri;":Character(Unicode.Scalar(0x25F9)!),"Uscr;":Character(Unicode.Scalar(0x1D4B0)!),"uscr;":Character(Unicode.Scalar(0x1D4CA)!),"utdot;":Character(Unicode.Scalar(0x22F0)!),
    "Utilde;":Character(Unicode.Scalar(0x168)!),"utilde;":Character(Unicode.Scalar(0x169)!),"utri;":Character(Unicode.Scalar(0x25B5)!),"utrif;":Character(Unicode.Scalar(0x25B4)!),
    "uuarr;":Character(Unicode.Scalar(0x21C8)!),"Uuml;":Character(Unicode.Scalar(0xDC)!),"uuml;":Character(Unicode.Scalar(0xFC)!),"uwangle;":Character(Unicode.Scalar(0x29A7)!),
    "vangrt;":Character(Unicode.Scalar(0x299C)!),"varepsilon;":Character(Unicode.Scalar(0x3F5)!),"varkappa;":Character(Unicode.Scalar(0x3F0)!),"varnothing;":Character(Unicode.Scalar(0x2205)!),
    "varphi;":Character(Unicode.Scalar(0x3D5)!),"varpi;":Character(Unicode.Scalar(0x3D6)!),"varpropto;":Character(Unicode.Scalar(0x221D)!),"vArr;":Character(Unicode.Scalar(0x21D5)!),
    "varr;":Character(Unicode.Scalar(0x2195)!),"varrho;":Character(Unicode.Scalar(0x3F1)!),"varsigma;":Character(Unicode.Scalar(0x3C2)!),"varsubsetneq;":"\u{228A}\u{FE00}",
    "varsubsetneqq;":"\u{2ACB}\u{FE00}","varsupsetneq;":"\u{228B}\u{FE00}","varsupsetneqq;":"\u{2ACC}\u{FE00}","vartheta;":Character(Unicode.Scalar(0x3D1)!),
    "vartriangleleft;":Character(Unicode.Scalar(0x22B2)!),"vartriangleright;":Character(Unicode.Scalar(0x22B3)!),"Vbar;":Character(Unicode.Scalar(0x2AEB)!),"vBar;":Character(Unicode.Scalar(0x2AE8)!),
    "vBarv;":Character(Unicode.Scalar(0x2AE9)!),"Vcy;":Character(Unicode.Scalar(0x412)!),"vcy;":Character(Unicode.Scalar(0x432)!),"VDash;":Character(Unicode.Scalar(0x22AB)!),
    "Vdash;":Character(Unicode.Scalar(0x22A9)!),"vDash;":Character(Unicode.Scalar(0x22A8)!),"vdash;":Character(Unicode.Scalar(0x22A2)!),"Vdashl;":Character(Unicode.Scalar(0x2AE6)!),
    "Vee;":Character(Unicode.Scalar(0x22C1)!),"vee;":Character(Unicode.Scalar(0x2228)!),"veebar;":Character(Unicode.Scalar(0x22BB)!),"veeeq;":Character(Unicode.Scalar(0x225A)!),
    "vellip;":Character(Unicode.Scalar(0x22EE)!),"Verbar;":Character(Unicode.Scalar(0x2016)!),"verbar;":Character(Unicode.Scalar(0x7C)!),"Vert;":Character(Unicode.Scalar(0x2016)!),
    "vert;":Character(Unicode.Scalar(0x7C)!),"VerticalBar;":Character(Unicode.Scalar(0x2223)!),"VerticalLine;":Character(Unicode.Scalar(0x7C)!),"VerticalSeparator;":Character(Unicode.Scalar(0x2758)!),
    "VerticalTilde;":Character(Unicode.Scalar(0x2240)!),"VeryThinSpace;":Character(Unicode.Scalar(0x200A)!),"Vfr;":Character(Unicode.Scalar(0x1D519)!),"vfr;":Character(Unicode.Scalar(0x1D533)!),
    "vltri;":Character(Unicode.Scalar(0x22B2)!),"vnsub;":"\u{2282}\u{20D2}","vnsup;":"\u{2283}\u{20D2}","Vopf;":Character(Unicode.Scalar(0x1D54D)!),
    "vopf;":Character(Unicode.Scalar(0x1D567)!),"vprop;":Character(Unicode.Scalar(0x221D)!),"vrtri;":Character(Unicode.Scalar(0x22B3)!),"Vscr;":Character(Unicode.Scalar(0x1D4B1)!),
    "vscr;":Character(Unicode.Scalar(0x1D4CB)!),"vsubnE;":"\u{2ACB}\u{FE00}","vsubne;":"\u{228A}\u{FE00}","vsupnE;":"\u{2ACC}\u{FE00}",
    "vsupne;":"\u{228B}\u{FE00}","Vvdash;":Character(Unicode.Scalar(0x22AA)!),"vzigzag;":Character(Unicode.Scalar(0x299A)!),"Wcirc;":Character(Unicode.Scalar(0x174)!),
    "wcirc;":Character(Unicode.Scalar(0x175)!),"wedbar;":Character(Unicode.Scalar(0x2A5F)!),"Wedge;":Character(Unicode.Scalar(0x22C0)!),"wedge;":Character(Unicode.Scalar(0x2227)!),
    "wedgeq;":Character(Unicode.Scalar(0x2259)!),"weierp;":Character(Unicode.Scalar(0x2118)!),"Wfr;":Character(Unicode.Scalar(0x1D51A)!),"wfr;":Character(Unicode.Scalar(0x1D534)!),
    "Wopf;":Character(Unicode.Scalar(0x1D54E)!),"wopf;":Character(Unicode.Scalar(0x1D568)!),"wp;":Character(Unicode.Scalar(0x2118)!),"wr;":Character(Unicode.Scalar(0x2240)!),
    "wreath;":Character(Unicode.Scalar(0x2240)!),"Wscr;":Character(Unicode.Scalar(0x1D4B2)!),"wscr;":Character(Unicode.Scalar(0x1D4CC)!),"xcap;":Character(Unicode.Scalar(0x22C2)!),
    "xcirc;":Character(Unicode.Scalar(0x25EF)!),"xcup;":Character(Unicode.Scalar(0x22C3)!),"xdtri;":Character(Unicode.Scalar(0x25BD)!),"Xfr;":Character(Unicode.Scalar(0x1D51B)!),
    "xfr;":Character(Unicode.Scalar(0x1D535)!),"xhArr;":Character(Unicode.Scalar(0x27FA)!),"xharr;":Character(Unicode.Scalar(0x27F7)!),"Xi;":Character(Unicode.Scalar(0x39E)!),
    "xi;":Character(Unicode.Scalar(0x3BE)!),"xlArr;":Character(Unicode.Scalar(0x27F8)!),"xlarr;":Character(Unicode.Scalar(0x27F5)!),"xmap;":Character(Unicode.Scalar(0x27FC)!),
    "xnis;":Character(Unicode.Scalar(0x22FB)!),"xodot;":Character(Unicode.Scalar(0x2A00)!),"Xopf;":Character(Unicode.Scalar(0x1D54F)!),"xopf;":Character(Unicode.Scalar(0x1D569)!),
    "xoplus;":Character(Unicode.Scalar(0x2A01)!),"xotime;":Character(Unicode.Scalar(0x2A02)!),"xrArr;":Character(Unicode.Scalar(0x27F9)!),"xrarr;":Character(Unicode.Scalar(0x27F6)!),
    "Xscr;":Character(Unicode.Scalar(0x1D4B3)!),"xscr;":Character(Unicode.Scalar(0x1D4CD)!),"xsqcup;":Character(Unicode.Scalar(0x2A06)!),"xuplus;":Character(Unicode.Scalar(0x2A04)!),
    "xutri;":Character(Unicode.Scalar(0x25B3)!),"xvee;":Character(Unicode.Scalar(0x22C1)!),"xwedge;":Character(Unicode.Scalar(0x22C0)!),"Yacute;":Character(Unicode.Scalar(0xDD)!),
    "yacute;":Character(Unicode.Scalar(0xFD)!),"YAcy;":Character(Unicode.Scalar(0x42F)!),"yacy;":Character(Unicode.Scalar(0x44F)!),"Ycirc;":Character(Unicode.Scalar(0x176)!),
    "ycirc;":Character(Unicode.Scalar(0x177)!),"Ycy;":Character(Unicode.Scalar(0x42B)!),"ycy;":Character(Unicode.Scalar(0x44B)!),"yen;":Character(Unicode.Scalar(0xA5)!),
    "Yfr;":Character(Unicode.Scalar(0x1D51C)!),"yfr;":Character(Unicode.Scalar(0x1D536)!),"YIcy;":Character(Unicode.Scalar(0x407)!),"yicy;":Character(Unicode.Scalar(0x457)!),
    "Yopf;":Character(Unicode.Scalar(0x1D550)!),"yopf;":Character(Unicode.Scalar(0x1D56A)!),"Yscr;":Character(Unicode.Scalar(0x1D4B4)!),"yscr;":Character(Unicode.Scalar(0x1D4CE)!),
    "YUcy;":Character(Unicode.Scalar(0x42E)!),"yucy;":Character(Unicode.Scalar(0x44E)!),"Yuml;":Character(Unicode.Scalar(0x178)!),"yuml;":Character(Unicode.Scalar(0xFF)!),
    "Zacute;":Character(Unicode.Scalar(0x179)!),"zacute;":Character(Unicode.Scalar(0x17A)!),"Zcaron;":Character(Unicode.Scalar(0x17D)!),"zcaron;":Character(Unicode.Scalar(0x17E)!),
    "Zcy;":Character(Unicode.Scalar(0x417)!),"zcy;":Character(Unicode.Scalar(0x437)!),"Zdot;":Character(Unicode.Scalar(0x17B)!),"zdot;":Character(Unicode.Scalar(0x17C)!),
    "zeetrf;":Character(Unicode.Scalar(0x2128)!),"ZeroWidthSpace;":Character(Unicode.Scalar(0x200B)!),"Zeta;":Character(Unicode.Scalar(0x396)!),"zeta;":Character(Unicode.Scalar(0x3B6)!),
    "Zfr;":Character(Unicode.Scalar(0x2128)!),"zfr;":Character(Unicode.Scalar(0x1D537)!),"ZHcy;":Character(Unicode.Scalar(0x416)!),"zhcy;":Character(Unicode.Scalar(0x436)!),
    "zigrarr;":Character(Unicode.Scalar(0x21DD)!),"Zopf;":Character(Unicode.Scalar(0x2124)!),"zopf;":Character(Unicode.Scalar(0x1D56B)!),"Zscr;":Character(Unicode.Scalar(0x1D4B5)!),
    "zscr;":Character(Unicode.Scalar(0x1D4CF)!),"zwj;":Character(Unicode.Scalar(0x200D)!),"zwnj;":Character(Unicode.Scalar(0x200C)!)
]
