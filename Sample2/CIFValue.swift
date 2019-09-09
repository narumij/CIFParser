//
//  CIFValue_S.swift
//  Sample2
//
//  Created by Jun Narumi on 2019/09/09.
//  Copyright © 2019 Jun Narumi. All rights reserved.
//

import Cocoa
import CIFParser

enum CIFValue {

    case float(String)
    case integer(String)
    case string(String)
    case text(String)
    case inapplicable
    case unknown

    init( tag: CIFLexType, bytes: UnsafePointer<Int8>!, length: Int )
    {
        switch (tag) {
            case LNumericFloat:
                self = .float( String(cString:bytes) )
                break
            case LNumericInteger:
                self = .integer( String(cString:bytes) )
                break
            case LUnquoteString1: fallthrough
            case LUnquoteString2: fallthrough
            case LQuoteString:
                self = .string( String(cString:bytes) )
                break
            case LTextField:
                self = .text( String(cString:bytes) )
                break
            case LDot:
                self = .inapplicable
                break
            default:
                self = .unknown
                break
        }
    }

}

extension CIFValue {

    var doubleValue: Double? {
        if case .float(let f) = self {
            return Double(f)
        }
        return nil
    }

    var integerValue: Int? {
        if case .integer(let i) = self {
            return (i as NSString?)?.integerValue
        }
        return nil
    }

    var stringValue: String? {
        switch self {
        case .string(let s):
            return s
        case .text(let s):
            return s
        default:
            return nil
        }

    }

}

extension CIFValue {

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
