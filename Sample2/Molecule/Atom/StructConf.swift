//
//  StructConf.swift
//  CIFTest2
//
//  Created by Jun Narumi on 2017/12/13.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

import Cocoa
import CIFParser


class StructConf: NSObject {
    var confTypeID: CIFValue
    var id: CIFValue
    var begLabelID: LabelID
    var endLabelID: LabelID
    var begAuthID: AuthID
    var endAuthID: AuthID
    init( confTypeID c: CIFValue, id i: CIFValue, begLabelID bl: LabelID, endLabelID el: LabelID, begAuthID ba: AuthID, endAuthID ea: AuthID ) {
        confTypeID = c
        id = i
        begLabelID = bl
        endLabelID = el
        begAuthID = ba
        endAuthID = ea
    }
}


fileprivate func makeLabel(_ d:[String:CIFValue],_ tags: [String] ) -> LabelID {
    func cifString(_ key: String ) -> CIFValue {
        return d[key] ?? .missing
    }
    return apply6( LabelID.init,
                   .inapplicable,
                   .inapplicable,
                   cifString( tags[0] ),
                   cifString( tags[1] ),
                   .inapplicable,
                   d[tags[2]]! )
}


fileprivate func makeAuth(_ d:[String:CIFValue],_ tags: [String] ) -> AuthID {
    func cifString(_ key: String ) -> CIFValue {
        return d[key] ?? .missing
    }
    return apply4( AuthID.init,
                   d[tags[0]]!,
                   cifString(tags[1]),
                   cifString(tags[2]),
                   .inapplicable )
}


func makeStructConf(_ d: [String:CIFValue] ) -> StructConf? {
    let bl = makeLabel( d, ["_struct_conf.beg_label_comp_id","_struct_conf.beg_label_asym_id","_struct_conf.beg_label_seq_id"] )
    let el = makeLabel( d, ["_struct_conf.end_label_comp_id","_struct_conf.end_label_asym_id","_struct_conf.end_label_seq_id"] )
    let ba = makeAuth( d, ["_struct_conf.beg_auth_seq_id","_struct_conf.beg_auth_comp_id","_struct_conf.beg_auth_asym_id"] )
    let ea = makeAuth( d, ["_struct_conf.end_auth_seq_id","_struct_conf.end_auth_comp_id","_struct_conf.end_auth_asym_id"] )
    return lift6( StructConf.init, d["_struct_conf.conf_type_id"], d["_struct_conf.id"], bl, el, ba, ea )
}

