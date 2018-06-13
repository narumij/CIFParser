//
//  DummyHandler.swift
//  Sample3
//
//  Created by Jun Narumi on 2018/06/14.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

import Foundation
import CIFParser

class DummyHandler : NSObject, CIFHandler {
    
    func beginData(_ lex: UnsafePointer<CIFLex>!) {
        print("begin data ** \(String(cString: lex.pointee.text))")
    }

    func item(_ tag: UnsafePointer<CIFTag>!, _ lex: UnsafePointer<CIFLex>!) {
        print("item ( \(String(cString: tag.pointee.text)) : \(String(cString: lex.pointee.text)) )")
    }

    func beginLoop(_ tags: UnsafePointer<CIFLoopTag>!) {
        print("begin loop \(StringsFromTagList)")
    }

    func loopItem(_ tags: UnsafePointer<CIFLoopTag>!, _ tagIndex: Int, _ lex: UnsafePointer<CIFLex>!) {
        print("loop item [ \(String(cString: tags.pointee.list[tagIndex].text)) : \(String(cString: lex.pointee.text)) ]")
    }

    func loopItemTerm() {
    }

    func endLoop() {
    }

}
