//
//  Utilities.swift
//  CIFTest2
//
//  Created by Jun Narumi on 2017/12/12.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

import Foundation

func nub<T:Equatable>(_ array: [T] ) -> [T] {
    return array.reduce( [], { $0.contains($1) ? $0 : $0 + [$1] } )
}

func nub<T>(_ array: [T],_ isEquivalent: (T,T) -> Bool ) -> [T] {
    return array.reduce( [], {
        ( xs: [T], x: T ) -> [T] in
        xs.filter( { isEquivalent( $0, x ) } ).count != 0 ? xs : xs + [x]
    })
}

func catOptionals<T>(_ a: [T?] ) -> [T] {
    return a.filter({ $0 != nil }).map{ $0! }
}

func mapOptional<T,U>(_ a: [T],_ f: (T)->U? ) -> [U] {
    var result: [U] = []
    for i in a {
        if let j = f(i) {
            result.append(j)
        }
    }
    return result
}

func apply2<A,B,C>(_ p:(A,B) throws -> C,_ a:A,_ b:B) rethrows -> C {
    return try p(a,b)
}

func apply3<A,B,C,D>(_ p:(A,B,C) throws -> D,_ a:A,_ b:B,_ c:C) rethrows -> D {
    return try p(a,b,c)
}

func apply4<A,B,C,D,E>(_ p:(A,B,C,D) throws -> E,_ a:A,_ b:B,_ c:C,_ d:D) rethrows -> E {
    return try p(a,b,c,d)
}

func apply5<A,B,C,D,E,F>(_ p:(A,B,C,D,E) throws -> F,_ a:A,_ b:B,_ c:C,_ d:D,_ e:E) rethrows -> F {
    return try p(a,b,c,d,e)
}

func apply6<A,B,C,D,E,F,G>(_ p:(A,B,C,D,E,F) throws ->G,_ a:A,_ b:B,_ c:C,_ d:D,_ e:E,_ f:F) rethrows -> G {
    return try p(a,b,c,d,e,f)
}

func lift<A,B>(_ f:(A) throws -> B,_ a: A? ) rethrows -> B? {
    return try a.flatMap{ a in try f(a) }
}

func lift2<A,B,C>(_ f:(A,B) throws -> C,_ a: A?,_ b: B? ) rethrows -> C? {
    return try a.flatMap{ a in try b.flatMap{ b in try f(a,b) } }
}

func lift3<A,B,C,D>(_ f:(A,B,C) throws -> D,_ a: A?,_ b: B?,_ c: C? ) rethrows -> D? {
    return try a.flatMap{ a in try b.flatMap{ b in try c.map{ c in try f(a,b,c) } } }
}

func lift4<A,B,C,D,E>(_ f:(A,B,C,D) throws -> E,_ a: A?,_ b: B?,_ c: C?,_ d: D? ) rethrows -> E? {
    return try a.flatMap{ a in try b.flatMap{ b in try c.flatMap{ c in try d.map{ d in try f(a,b,c,d) } } } }
}

func lift5<A,B,C,D,E,F>(_ f:(A,B,C,D,E) throws -> F,_ a: A?,_ b: B?,_ c: C?,_ d: D?,_ e: E?) rethrows -> F? {
    return try a.flatMap{ a in try b.flatMap{ b in try c.flatMap{ c in try d.flatMap{ d in try e.map{ e in try f(a,b,c,d,e) } } } } }
}

func lift6<A,B,C,D,E,F,G>(_ p:(A,B,C,D,E,F) throws -> G,_ a: A?,_ b: B?,_ c: C?,_ d: D?,_ e: E?,_ f: F?) rethrows -> G? {
    return try a.flatMap{ a in try b.flatMap{ b in try c.flatMap{ c in try d.flatMap{ d in try e.flatMap{ e in try f.map{ f in try p(a,b,c,d,e,f) } } } } } }
}

func bind2<A,B,C>(_ f:(A,B) throws -> C?,_ a: A?,_ b: B?) rethrows -> C? {
    return try a.flatMap{ a in try b.flatMap{ b in try f(a,b) } }
}

func bind3<A,B,C,D>(_ f:(A,B,C) throws ->D?,_ a: A?,_ b: B?,_ c: C? ) rethrows -> D? {
    return try a.flatMap{ a in try b.flatMap{ b in try c.flatMap{ c in try f(a,b,c) } } }
}

func bind4<A,B,C,D,E>(_ f:(A,B,C,D) throws ->E?,_ a: A?,_ b: B?,_ c: C?,_ d: D? ) rethrows -> E? {
    return try a.flatMap{ a in try b.flatMap{ b in try c.flatMap{ c in try d.flatMap{ d in try f(a,b,c,d) } } } }
}

func bind5<A,B,C,D,E,F>(_ f:(A,B,C,D,E) throws -> F?,_ a: A?,_ b: B?,_ c: C?,_ d: D?,_ e: E?) rethrows -> F? {
    return try a.flatMap{ a in try b.flatMap{ b in try c.flatMap{ c in try d.flatMap{ d in try e.flatMap{ e in try f(a,b,c,d,e) } } } } }
}

func bind6<A,B,C,D,E,F,G>(_ p:(A,B,C,D,E,F) throws -> G?,_ a: A?,_ b: B?,_ c: C?,_ d: D?,_ e: E?,_ f: F?) rethrows -> G? {
    return try a.flatMap{ a in try b.flatMap{ b in try c.flatMap{ c in try d.flatMap{ d in try e.flatMap{ e in try f.flatMap{ f in try p(a,b,c,d,e,f) } } } } } }
}
