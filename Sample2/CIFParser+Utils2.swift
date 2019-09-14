//
//  CIFParser+Utils2.swift
//  Sample2
//
//  Created by Jun Narumi on 2019/09/14.
//  Copyright © 2019 Jun Narumi. All rights reserved.
//

import Foundation
import CIFParser

// 便利そうだけれども、性能は悪い

protocol CIFParseCallbacks : class, PrepareParseCIFFile, ParseCIFFile {
    func beginData(_ lex: CIFLex);
    func item(_ tag: CIFTag, _ lex: CIFLex);
    func beginLoop(_ tags: CIFLoopTag);
    func loopItem( _ tags: CIFLoopTag, _ tagIndex: Int, _ lex: CIFLex );
    func loopItemTerm();
    func endLoop();
    func endData();
}

extension CIFParseCallbacks {
    func beginData(_ lex: CIFLex) {}
    func item(_ tag: CIFTag, _ lex: CIFLex){}
    func beginLoop(_ tags: CIFLoopTag) {}
    func loopItem( _ tags: CIFLoopTag, _ tagIndex: Int, _ lex: CIFLex ) {}
    func loopItemTerm() {}
    func endLoop() {}
    func endData() {}
}

func ClassCallback<T>(_ ctx: UnsafeMutableRawPointer?, func function: (CIFParseCallbacks)->T) -> T?{
    if let instance = ctx.flatMap( { unsafeBitCast($0, to:AnyObject.self) as? CIFParseCallbacks } ) {
        return function(instance)
    }
    return nil;
}

extension CIFParseCallbacks {

    var pointer: UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(unsafeBitCast(self, to: UnsafeMutablePointer<CIFParseCallbacks>.self))
    }

    var BeginDataFunc: PrepareParseCIFFile.BeginDataFuncType?
    {
        { ctx, lex in ClassCallback(ctx) { $0.beginData(lex) } }
    }

    var ItemFunc: PrepareParseCIFFile.ItemFuncType?
    {
        { ctx, tag, lex in ClassCallback(ctx) { $0.item(tag,lex) } }
    }

    var BeginLoopFunc: PrepareParseCIFFile.BeginLoopFuncType?
    {
        { ctx, looptag in ClassCallback(ctx) { $0.beginLoop(looptag) } }
    }

    var LoopItemFunc: PrepareParseCIFFile.LoopItemFuncType?
    {
        { ctx, tag, idx, lex in ClassCallback(ctx) { $0.loopItem(tag,idx,lex) } }
    }

    var LoopItemTermFunc: PrepareParseCIFFile.LoopItemTermFuncType?
    {
        { ClassCallback($0) { $0.loopItemTerm() } }
    }

    var EndLoopFunc: PrepareParseCIFFile.EndLoopFuncType?
    {
        { ClassCallback($0) { $0.endLoop() } }
    }

    var EndDataFunc: PrepareParseCIFFile.EndDataFuncType?
    {
        { ClassCallback($0) { $0.endData() } }
    }

}
