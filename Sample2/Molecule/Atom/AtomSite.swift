//
//  AtomSite.swift
//  CIFTest2
//
//  Created by Jun Narumi on 2017/12/12.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

import SceneKit
import CIFParser







enum GroupPDB {
    case atom
    case hetatm
}


enum SecondaryStructure {
    case none
    case helix
    case sheet
}


class AtomType: NSObject {
    init( symbol s: String ) {
        symbol = s
    }
    var symbol: String
}


struct LabelID {
    var atom: CIFValue_S = .unknown
    var alt: CIFValue_S = .unknown
    var comp: CIFValue_S = .unknown
    var asym: CIFValue_S = .unknown
    var entity: CIFValue_S = .unknown
    var seq: CIFValue_S = .unknown
}


struct AuthID {
    var seq: CIFValue_S = .unknown
    var comp: CIFValue_S = .unknown
    var asym: CIFValue_S = .unknown
    var atom: CIFValue_S = .unknown
}


class AtomSite {

    var id: CIFValue_S = .unknown
    var groupPDB: GroupPDB?
    var cartn: SCNVector3 = SCNVector3()
    var typeSymbol: CIFValue_S = .unknown
    var label: LabelID = LabelID()
    var auth: AuthID = AuthID()

    var rainbow: Double = 0.0

    var secondaryStructure: SecondaryStructure = .none

    init() {
    }

    init( id i: CIFValue_S, symbol s: CIFValue_S, label l: LabelID, auth a: AuthID ) {
        id = i
        typeSymbol = s
        label = l
        auth = a
    }
    
}


fileprivate func groupPDB(_ d:[String:CIFValue_S] ) ->GroupPDB? {
    let a = d["_atom_site.group_PDB"]
    func b(_ a: CIFValue_S ) -> GroupPDB? {
        if (a.contents) == "ATOM" {
            return .atom
        }
        if (a.contents) == "HETATM" {
            return .hetatm
        }
        return nil
    }
    return a.flatMap{ b( $0 ) }
}


func Cartn(_ x: CIFValue_S,_ y: CIFValue_S,_ z: CIFValue_S ) -> SCNVector3? {
    return bind3( SCNVector3.init, x.doubleValue, y.doubleValue, z.doubleValue )
}


fileprivate func makeLabel(_ d:[String:CIFValue_S],_ tags: [String] ) -> LabelID {
    func cifString(_ key: String ) -> CIFValue_S {
        return d[key] ?? .unknown
    }
    return apply6( LabelID.init,
                   cifString(tags[0]),
                   cifString(tags[1]),
                   cifString(tags[2]),
                   cifString(tags[3]),
                   cifString(tags[4]),
                   d[tags[5]]! )
}


fileprivate func makeAuth(_ d:[String:CIFValue_S],_ tags: [String] ) -> AuthID {
    func cifString(_ key: String ) -> CIFValue_S {
        return d[key] ?? .unknown
    }
    return apply4( AuthID.init,
                   d[tags[0]]!,
                   cifString(tags[1]),
                   cifString(tags[2]),
                   cifString(tags[3]))
}


fileprivate func atomSiteLabel(_ d: [String:CIFValue_S] ) -> LabelID {
    return makeLabel( d, ["_atom_site.label_atom_id",
                          "_atom_site.label_alt_id",
                          "_atom_site.label_comp_id",
                          "_atom_site.label_asym_id",
                          "_atom_site.label_entity_id",
                          "_atom_site.label_seq_id"] )
}


fileprivate func atomSiteAuthID(_ d: [String:CIFValue_S] ) -> AuthID {
    return makeAuth( d, ["_atom_site.auth_seq_id",
                         "_atom_site.auth_comp_id",
                         "_atom_site.auth_asym_id",
                         "_atom_site.auth_atom_id"] )
}


func makeAtomSite(_ d: [String:CIFValue_S] ) -> AtomSite? {
    let site = lift4( AtomSite.init, d["_atom_site.id"], d["_atom_site.type_symbol"], atomSiteLabel( d ), atomSiteAuthID( d ) )
    site?.groupPDB = groupPDB( d )
    bind3( Cartn, d["_atom_site.Cartn_x"], d["_atom_site.Cartn_y"], d["_atom_site.Cartn_z"] ).map{ site?.cartn = $0 }
    return site
}


func makeBackbone(_ a: [AtomSite] ) -> [[AtomSite]] {

    let b = a.filter{ $0.groupPDB == .atom }

    func cond( site: AtomSite ) -> Bool {
        return site.label.atom.stringValue.map( { $0 == "CA" } ) ?? false
    }

    let c = b.filter( cond )

    var e : [AtomSite] = []
    var d : [[AtomSite]] = []

    for atom in c {
        if e.isEmpty || e.last?.label.seq.integerValue.map({ $0 + 1 }) == atom.label.seq.integerValue {
            e.append(atom)
        } else {
            d.append(e)
            e = [atom]
        }
    }
    d.append(e)

//    _ = d.map{ debugPrint( $0.map{ $0.label.seq.integerValue! } ) }

    return d
}










