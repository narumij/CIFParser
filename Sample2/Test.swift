//
//  Test.swift
//  CIFTest2
//
//  Created by Jun Narumi on 2017/12/11.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

import SceneKit
import CIFParser

fileprivate let xKey = "_atom_site.Cartn_x"
fileprivate let yKey = "_atom_site.Cartn_y"
fileprivate let zKey = "_atom_site.Cartn_z"

let atom = "ATOM"
let hetatm = "HETATM"

fileprivate func groupPDB_(_ textBytes: UnsafePointer<Int8>!,_ textLength: Int) ->GroupPDB? {
    if strcmp( textBytes, (atom as NSString).utf8String ) == 0 {
        return .atom
    }
    if strcmp( textBytes, (hetatm as NSString).utf8String ) == 0 {
        return .hetatm
    }
    return nil
}

extension AtomSite {
    enum CIFKey {
        case atomID
        case seqID
        case cartX
        case cartY
        case cartZ
        case groupPDB
    }
    func loopItem( key: CIFKey, tag: CIFLexemeTag, textBytes: UnsafePointer<Int8>!, textLength: Int )
    {
        switch key {
        case .atomID:
            label.atom = CIFValue( tag: tag, bytes: textBytes, length: textLength )
        case .seqID:
            label.seq = CIFValue( tag: tag, bytes: textBytes, length: textLength )
        case .cartX:
            cartn.x = CGFloat( atof(textBytes) )
        case .cartY:
            cartn.y = CGFloat( atof(textBytes) )
        case .cartZ:
            cartn.z = CGFloat( atof(textBytes) )
        case .groupPDB:
            groupPDB = groupPDB_( textBytes, textLength )
        }
    }
}

class Simple: CIFHandler {

    func beginData(_ valueText: UnsafePointer<Int8>!, _ valueTextLen: Int) {
    }

    func item(_ tag: UnsafePointer<CIFTag>!, _ lex: UnsafePointer<Lex>!) {
    }

    enum LoopMode {
        case ignore
        case atom
        case helix
        case sheet
    }

    var mode: LoopMode = .ignore

    func beginLoop(_ tags: UnsafePointer<CIFLoopTag>!) {
        if let tags = StringsFromTagList(tags) {
            if tags.contains("_atom_site.Cartn_x") {
                
                mode = .atom
                atomKeyTable = [:]

                for (str,key) in [
                    ("_atom_site.label_atom_id",AtomSite.CIFKey.atomID),
                    ("_atom_site.label_seq_id",AtomSite.CIFKey.seqID),
                    (xKey,AtomSite.CIFKey.cartX),
                    (yKey,AtomSite.CIFKey.cartY),
                    (zKey,AtomSite.CIFKey.cartZ),
                    ("_atom_site.group_PDB",AtomSite.CIFKey.groupPDB)
                    ] {
                    if let idx = tags.index(of: str) {
                        atomKeyTable[idx] = key
                    }
                }

            } else if tags.contains("_struct_conf.id") {
                mode = .helix
            } else if tags.contains("_struct_sheet_range.id") {
                mode = .sheet
            } else {
                mode = .ignore
            }
            loopTags = tags
        }
    }

    var atomCount = 0
    var helixCount = 0
    var sheetCount = 0
    func beginData( name: String) -> Bool {
        return true
    }
    func item( itemTag: String, tag: CIFLexemeTag, textBytes: UnsafePointer<Int8>!, textLength: Int ) {
    }
    var atomKeyTable : [Int:AtomSite.CIFKey] = [:]

    var loopTags: [String] = []
    var loopValues: [TestValue] = []
    var atomSite: AtomSite = AtomSite()

    func appendLoopItem() {
        switch mode {
        case .atom:
            atomCount += 1
            if atomSite.label.atom.stringValue == "CA" {
                atomSites.append(atomSite)
            }
            atomSite = AtomSite()
        case .helix:
            helixCount += 1
            appendHelix(loopTags, loopValues)
        case .sheet:
            sheetCount += 1
            appendSheet(loopTags, loopValues)
        default:
            assert(false)
            break
        }
        loopValues = []
    }

    func loopItem( _ tags: UnsafePointer<CIFLoopTag>!, _ tagIndex: Int, _ lex: UnsafePointer<Lex>! ) {
        switch mode {
        case .helix:
            fallthrough
        case .sheet:
            loopValues.append( TestValue( tag: lex.pointee.tag, textBytes: lex.pointee.text, textLength: lex.pointee.len ) )
        case .atom:
            atomKeyTable[tagIndex].map{
                atomSite.loopItem(key: $0, tag: lex.pointee.tag, textBytes: lex.pointee.text, textLength: lex.pointee.len)
            }
        default:
            break
        }
    }

    func loopItemTerm() {
        switch mode {
        case .helix:
            fallthrough
        case .sheet:
            fallthrough
        case .atom:
            appendLoopItem()
        default:
            break
        }
    }

    func endLoop() {
        switch mode {
        case .atom:
            print("atom(\(atomSites.count))")
        case .helix:
            print("helix(\(helixCount))")
        case .sheet:
            print("sheet(\(sheetCount))")
        default:
            break
        }
        mode = .ignore
    }

    func endData() {
    }

    var atomSites: [AtomSite] = []

    var structConfs: [StructConf] = []
    func appendHelix(_ tags: [String],_ values: [TestValue] ) {
        let dict: [String:TestValue] = Dictionary(uniqueKeysWithValues: zip(tags, values) )
        let beg = dict["_struct_conf.beg_label_seq_id"].flatMap{ CIFValue( tag: $0.tag, bytes: $0.textBytes, length: $0.textLength ) }
        let end = dict["_struct_conf.end_label_seq_id"].flatMap{ CIFValue( tag: $0.tag, bytes: $0.textBytes, length: $0.textLength ) }
        let blabel = beg.flatMap{ seq in
                LabelID(atom: .unknown, alt: .unknown, comp: .unknown, asym: .unknown, entity: .unknown, seq: seq )
            }
        let elabel = end.flatMap{ seq in
            LabelID(atom: .unknown, alt: .unknown, comp: .unknown, asym: .unknown, entity: .unknown, seq: seq )
        }
        let auth = AuthID(seq: .unknown, comp: .unknown, asym: .unknown, atom: .unknown)
        let s = blabel.flatMap{ b in
            elabel.flatMap{ e in
                StructConf(confTypeID: .unknown, id: .unknown, begLabelID: b, endLabelID: e, begAuthID: auth, endAuthID: auth)
            }
        }
        s.map{ structConfs.append($0) }
    }

    var structSheet: [StructSheetRange] = []
    func appendSheet(_ tags: [String],_ values: [TestValue] ) {
        let dict: [String:TestValue] = Dictionary(uniqueKeysWithValues: zip(tags, values) )
        let beg = dict["_struct_sheet_range.beg_label_seq_id"].flatMap{ CIFValue( tag: $0.tag, bytes: $0.textBytes, length: $0.textLength ) }
        let end = dict["_struct_sheet_range.end_label_seq_id"].flatMap{ CIFValue( tag: $0.tag, bytes: $0.textBytes, length: $0.textLength ) }
        let blabel = beg.flatMap{ seq in
            LabelID(atom: .unknown, alt: .unknown, comp: .unknown, asym: .unknown, entity: .unknown, seq: seq )
        }
        let elabel = end.flatMap{ seq in
            LabelID(atom: .unknown, alt: .unknown, comp: .unknown, asym: .unknown, entity: .unknown, seq: seq )
        }
        let auth = AuthID(seq: .unknown, comp: .unknown, asym: .unknown, atom: .unknown)
        let s = blabel.flatMap{ b in
            elabel.flatMap{ e in
                StructSheetRange(sheetID: .unknown, id: .unknown, begLabelID: b, endLabelID: e, begAuthID: auth, endAuthID: auth)
            }
        }
        s.map{ structSheet.append($0) }
    }

}

class Test: NSObject {
    static func test() -> [AtomSite] {
//        let name = "3ixn"
        let name = "3j3y"
//        let name = "1wns"
//        let name = "1gof"
        let path = Bundle.main.path(forResource: name, ofType: "cif")
        let time0 = CFAbsoluteTimeGetCurrent()

        #if true

            let handler = Simple()
//            parser.root.handler = Simple()
//            path.map{ parser.parse(withFilePath: $0 ) }
            path.map{ NewParser.parse( $0, handler) }

            let time1 = CFAbsoluteTimeGetCurrent()
            let time_ = CFAbsoluteTimeGetCurrent()
            print("test parse = \(time_ - time0)")
//            abort()
            let atomSites = handler.atomSites
            let structConfs = handler.structConfs
            let structSheetRanges = handler.structSheet
        #else
            let result = try? CIFParser.parse(withFilePath: path)
//        result.map{ debugPrint( $0 ) }
            let time1 = CFAbsoluteTimeGetCurrent()
            let atomSiteLoop = (result?.contents.first as? CIFData)?.loop(forNames: [xKey,yKey,zKey])
//        let atomSites: [AtomSite] = atomSiteLoop.map{
//            (loop:CIFLoop) -> [AtomSite] in
//            let nums: [Int] = (0..<loop.length).map{$0}
//            return nums.map({ makeAtomSite2( loop[$0] ) }).filter({$0 != nil}).map{$0!}
//            } ?? []
            let atomSites = mapOptional( atomSiteLoop?.all() ?? [], makeAtomSite )
//        let atomSites = mapOptional( atomSiteLoop?.allDictionaries ?? [], makeAtomSite )
//        return mapOptional( a, { d in bind3( Cartn, d[xKey], d[yKey], d[zKey] ) } )
            let b = (result?.contents.first as? CIFData)?.loop(forNames: ["_struct_conf.id"] )?.all() ?? []
            let structConfs = mapOptional( b, makeStructConf )
            let c = (result?.contents.first as? CIFData)?.loop(forNames: ["_struct_sheet_range.id"] )?.all() ?? []
            let structSheetRanges = mapOptional( c, makeStructSheetRange )
        #endif
        let time2 = CFAbsoluteTimeGetCurrent()

        print("cif parse = \(time1-time0)")
        print("atom site loop = \(time2-time1)")

        var bDic: [Int:StructConf] = [:]
        for bb in structConfs {
            bb.begLabelID.seq.integerValue.map{ bDic[$0] = bb }
        }
        var cDic: [Int:StructSheetRange] = [:]
        for cc in structSheetRanges {
            cc.begLabelID.seq.integerValue.map{ cDic[$0] = cc }
        }

        var foundConf: StructConf?
        for atomSite in atomSites {
            if foundConf == nil {
//                foundConf = structConfs.filter({ $0.begLabelID.seq.integerValue == atomSite.label.seq.integerValue }).first
                foundConf = atomSite.label.seq.integerValue.flatMap{ bDic[$0] }
                if foundConf != nil {
//                    print("HELIX BEGIN - \(foundConf?.begLabelID.comp)")
                }
            }
            
            if foundConf != nil {
                atomSite.secondaryStructure = .helix
            }

            if atomSite.label.seq.integerValue == foundConf?.endLabelID.seq.integerValue {
//                print("HELIX END - \(foundConf?.endLabelID.comp)")
                foundConf = nil
            }
        }
        
        var foundSheet: StructSheetRange?
        for atomSite in atomSites {
            if foundSheet == nil {
//                foundSheet = structSheetRanges.filter({ $0.begLabelID.seq.integerValue == atomSite.label.seq.integerValue }).first
                foundSheet = atomSite.label.seq.integerValue.flatMap{ cDic[$0] }
                if foundSheet != nil {
//                    print("SHEET BEGIN - \(foundSheet?.begLabelID.comp)")
                }
            }

            if foundSheet != nil {
                atomSite.secondaryStructure = .sheet
            }

            if atomSite.label.seq.integerValue == foundSheet?.endLabelID.seq.integerValue {
//                print("SHEET END - \(foundSheet?.endLabelID.comp)")
                foundSheet = nil
            }
        }

        let time3 = CFAbsoluteTimeGetCurrent()

        print("atom site loop 2 = \(time3-time2)")

        return atomSites
    }
}
