//
//  CIFValue_S.swift
//  Sample2
//
//  Created by Jun Narumi on 2019/09/09.
//  Copyright © 2019 Jun Narumi. All rights reserved.
//

import Cocoa
import CIFParser

class CIFValue_S {
    var type: CIFValueType = CIFValueUknown
    var contents: String? = nil
    init() { }
    init( tag: CIFLexType, bytes: UnsafePointer<Int8>!, length: Int )
    {
        let text: String = String(cString:bytes)
        switch (tag) {
            case LNumericFloat:
                type = CIFValueFloat
                break
            case LNumericInteger:
                type = CIFValueInteger
                break
            case LUnquoteString1: fallthrough
            case LUnquoteString2: fallthrough
            case LQuoteString:
                type = CIFValueString
                break
            case LTextField:
                type = CIFValueText
                break
            case LDot:
                type = CIFValueInapplicable
                break
            default:
                type = CIFValueUknown
                break
        }
        contents = text
    }

}

