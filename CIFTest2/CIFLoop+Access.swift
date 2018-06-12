//
//  CIFLoop+Access.swift
//  CIFTest2
//
//  Created by Jun Narumi on 2017/12/16.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

import CIFReader

//struct CIFLoopDictionary {
//    let loop: CIFLoop
//    let index: Int
//    subscript(key: String) -> CIFValue? {
//        return loop.index(of: key).map{ loop.item( of:$0, index: index) }
//    }
//}

extension CIFLoop {
//    func index(of tagName:String) -> Int? {
//        for i in 0..<tags.count {
//            if tags[i].name == tagName {
//                return i
//            }
//        }
//        return nil
//    }
//    func item(of tagIndex: Int, index: Int ) -> CIFValue {
//        return values[ index * tags.count + tagIndex ]
//    }
    subscript(index: Int) -> [String:CIFValue] {
        var d: [String:CIFValue] = [:]
        for i in 0..<tags.count {
            d[tags[i].name] = values[index * tags.count + i]
        }
        return d
    }
    var allDictionaries: [[String:CIFValue]] {
        return (0..<length).map{ self[$0] }
    }
}
