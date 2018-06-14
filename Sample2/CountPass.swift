//
//  CounterPass.swift
//  Sample2
//
//  Created by Jun Narumi on 2018/06/14.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

import Foundation
import CIFParser

class CountPass : CIFHandler {
    var count : Int = 0
    var atomCounting : Bool = false
    var idIndex: Int?
    func beginData(_ lex: UnsafePointer<CIFLex>!) {
    }
    func item(_ tag: UnsafePointer<CIFTag>!, _ lex: UnsafePointer<CIFLex>!) {
    }
    func beginLoop(_ tags: UnsafePointer<CIFLoopTag>!) {
        let tags = NSStringsFromLoopTag(tags)
        idIndex = tags.index(of: "_atom_site.label_atom_id" )
    }
    func loopItem(_ tags: UnsafePointer<CIFLoopTag>!, _ tagIndex: Int, _ lex: UnsafePointer<CIFLex>!) {
        idIndex.map {
            if tagIndex == $0 && String(cString: lex.pointee.text) == "CA" {
                count += 1
            }
        }
    }
    func loopItemTerm() {
    }
    func endLoop() {
    }
    func parse( name: String ) {
        CIFParser.parse( name, self)
    }
    static func hh() -> CIFRawHandlers {
        var h = CIFRawHandlers()
        h.beginData = { (a,b) in }
        h.beginLoop = { (a,b) in CountPass.shared.beginLoop(b) }
        h.item = { (a,b,c) in }
        h.loopItem = { (a,b,c,d) in CountPass.shared.loopItem(b,c,d) }
        h.loopItemTerm = { (a) in }
        h.endLoop = { (a) in }
        return h
    }
    static let shared: CountPass = CountPass()
    static func parse( name: String ) {
        let fp = fopen(name, "r")
        var handlers = self.hh()
        CIFRawParse( fp, &handlers )
        fclose(fp)
    }
}
