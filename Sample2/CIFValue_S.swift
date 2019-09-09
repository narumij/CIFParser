//
//  CIFValue_S.swift
//  Sample2
//
//  Created by Jun Narumi on 2019/09/09.
//  Copyright © 2019 Jun Narumi. All rights reserved.
//

import Cocoa
import CIFParser

class CIFValue_S {

    enum InternalType {
        case float(Double?)
        case integer(Int?)
        case string(String)
        case text(String)
        case inapplicable
        case unknown
    }

    var _type: InternalType = .unknown

    init() { }

    init( type t: InternalType)
    {
        _type = t
    }

    init( tag: CIFLexType, bytes: UnsafePointer<Int8>!, length: Int )
    {
        switch (tag) {
            case LNumericFloat:
                _type = .float((String(cString:bytes) as NSString?)?.doubleValue)
                break
            case LNumericInteger:
                _type = .integer((String(cString:bytes) as NSString?)?.integerValue)
                break
            case LUnquoteString1: fallthrough
            case LUnquoteString2: fallthrough
            case LQuoteString:
                _type = .string(String(cString:bytes))
                break
            case LTextField:
                _type = .text(String(cString:bytes))
                break
            case LDot:
                _type = .inapplicable
                break
            default:
                _type = .unknown
                break
        }
    }

}

#if false
enum CIFVal<Wrapped> : ExpressibleByNilLiteral {
    case unknown
    case inapplicable
    case some(Wrapped)
    init(_ some: Wrapped) {
        self = .some(some)
    }
    init(nilLiteral: ()) {
        self = .unknown
    }
    func map<U>(_ transform: (Wrapped) throws -> U) rethrows -> CIFVal<U> {
        switch self {
        case let .some(a):
            return .some( try transform(a) )
        case .inapplicable:
            return .inapplicable
        default:
            return .unknown
        }
    }
    public func flatMap<U>(_ transform: (Wrapped) throws -> CIFVal<U>) rethrows -> CIFVal<U> {
        return .unknown
    }
    var unsafelyUnwrapped: Wrapped {
        switch self {
        case let .some(a):
            return a
        default:
            abort()
        }
    }
    var optional: Wrapped? {
        switch self {
        case let .some(a):
            return a
        default:
            return nil
        }
    }
}
#endif

extension CIFValue_S {
    var doubleValue: Double? {
        if case .float(let f) = _type {
            return f
        }
        return nil
    }
    #if false
    var doubleVal: CIFVal<Double> {
        if _type == .float {
            if let d = (contents as NSString?)?.doubleValue {
                return .some(d)
            }
            return nil
        }
        return nil
    }
    #endif
    var integerValue: Int? {
        if case .integer(let num) = _type {
            return num
        }
        return nil
    }
    var stringValue: String? {
        switch _type {
        case .string(let str):
            return str
        case .text(let str):
            return str
        default:
            return nil
        }
    }
    static var inapplicable: CIFValue_S {
        return CIFValue_S(type:.inapplicable)
    }
    static var unknown: CIFValue_S {
        return CIFValue_S(type:.unknown)
    }

}

extension CIFValue_S {
    #if false
    var cifString: CIFVal<string> {
        switch _type {
        case InternalType.inapplicable:
            return .inapplicable
        case InternalType.string:
            fallthrough
        case InternalType.integer:
            return .some(contents!)
        default:
            return .unknown
        }
    }
    #endif
}


