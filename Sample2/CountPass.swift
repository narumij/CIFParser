//
//  CounterPass.swift
//  Sample2
//
//  Created by Jun Narumi on 2018/06/14.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

import Foundation
import CIFParser

class CACount: ParseCIFFile {
    var count : Int = 0
    var atomCounting : Bool = false
    var idIndex: Int?
    func beginData(_ lex: CIFLex) {
    }
    func item(_ tag: CIFTag, _ lex: CIFLex) {
    }
    func beginLoop(_ tags: CIFLoopTag) {
        idIndex = tags.firstIndex(of: "_atom_site.label_atom_id")
    }
    func loopItem(_ tags: CIFLoopTag, _ tagIndex: Int, _ lex: CIFLex) {
        guard
            let idIndex = idIndex
            else { return }
        if idIndex == tagIndex && lex.isSame(as: "CA") {
            count += 1
        }
    }
    func loopItemTerm() {
    }
    func endLoop() {
    }
    #if true
    func prepareHandlers() -> CIFRawHandlers
    {
        var h = CIFMakeRawHandlers()
        h.beginLoop = { a,b in CACount.shared.beginLoop(b) }
        h.loopItem = { (a,b,c,d) in CACount.shared.loopItem(b,c,d) }
        return h
    }
    #endif

    static let shared: CACount = CACount()

    static func parse(_ fp: UnsafeMutablePointer<FILE>!) -> Int
    {
        CACount.shared.parse(fp)
        return CACount.shared.count
    }

}
