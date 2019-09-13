//
//  CounterPass.swift
//  Sample2
//
//  Created by Jun Narumi on 2018/06/14.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

import Foundation
import CIFParser

class CACount: CIFHandlerImpl {
    var count : Int = 0
    var atomCounting : Bool = false
    var idIndex: Int?
    func beginData(_ lex: CIFLex) {
    }
    func item(_ tag: CIFTag, _ lex: CIFLex) {
    }
    func beginLoop(_ tags: CIFLoopTag) {
        idIndex = tags.find("_atom_site.label_atom_id")
    }
    func loopItem(_ tags: CIFLoopTag, _ tagIndex: Int, _ lex: CIFLex) {
        guard
            let idIndex = idIndex
            else { return }
        if idIndex == tagIndex && lex.compare("CA") == 0 {
            count += 1
        }
    }
    func loopItemTerm() {
    }
    func endLoop() {
    }
    func prepareHandlers() -> CIFRawHandlers
    {
        var h = CIFRawHandlers()
        h.beginData = { (a,b) in }
        h.beginLoop = { a,b in CACount.shared.beginLoop(b) }
        h.item = { (a,b,c) in }
        h.loopItem = { (a,b,c,d) in CACount.shared.loopItem(b,c,d) }
        h.loopItemTerm = { (a) in }
        h.endLoop = { (a) in }
        return h
    }

    static let shared: CACount = CACount()

    static func parse(_ fp: UnsafeMutablePointer<FILE>!) -> Int
    {
        CACount.shared.parse(fp)
        return CACount.shared.count
    }

}
