//
//  TestParser.swift
//  CIFTest2
//
//  Created by Jun Narumi on 2017/12/16.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

import Cocoa
import CIFParser

// Swiftでparser書いてみた名残

struct TestValue {
    init( tag t: CIFLexemeTag, textBytes: UnsafePointer<Int8>, textLength: Int ) {
        tag = t
        bytes = (0..<textLength).map{ textBytes[$0] }
    }
    var tag: CIFLexemeTag
    var bytes: [Int8]
    var textBytes: UnsafePointer<Int8> {
        return UnsafePointer<Int8>(bytes)
    }
    var textLength: Int {
        return bytes.count
    }
}

