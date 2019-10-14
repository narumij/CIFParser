//
//  CIFParser+Utils.swift
//  Sample2
//
//  Created by Jun Narumi on 2019/09/14.
//  Copyright © 2019 Jun Narumi. All rights reserved.
//

import Foundation

import CIFParser

extension CIFLoopTag {
    var stringValues:[String] {
        return (0..<count).map{ String(cString:list[$0].text) }
    }
    func firstIndex(of str: String) -> Int? {
        for i in 0..<count {
            if strcmp(list[i].text,str) == 0 {
                return i
            }
        }
        return nil
    }
}

extension CIFLex {
    var stringValue: String {
        return String(cString:text)
    }
    var doubleValue: Double {
        return atof(text)
    }
    var CGFloatValue: CGFloat {
        return CGFloat(doubleValue)
    }
    var cifValue: CIFValue {
        return CIFValue(tag: tag, bytes: text, length: len)
    }
    private func compare(_ str: String) -> Int32 {
        return strcmp( text, str )
    }
    func isSame(as str: String) -> Bool {
        return compare(str) == 0
    }
}

protocol PrepareParseCIFFile {

    typealias BeginDataFuncType
        = @convention(c) (UnsafeMutableRawPointer?, CIFLex) -> Void

    typealias ItemFuncType
        = @convention(c) (UnsafeMutableRawPointer?, CIFTag, CIFLex) -> Void

    typealias BeginLoopFuncType
        = @convention(c) (UnsafeMutableRawPointer?, CIFLoopTag) -> Void

    typealias LoopItemFuncType
        = @convention(c) (UnsafeMutableRawPointer?, CIFLoopTag, Int, CIFLex) -> Void

    typealias LoopItemTermFuncType
        = @convention(c) (UnsafeMutableRawPointer?) -> Void

    typealias EndLoopFuncType
        = @convention(c) (UnsafeMutableRawPointer?) -> Void

    typealias EndDataFuncType
        = @convention(c) (UnsafeMutableRawPointer?) -> Void

    var pointer: UnsafeMutableRawPointer { get }
    var BeginDataFunc: BeginDataFuncType? { get }
    var ItemFunc: ItemFuncType? { get }
    var BeginLoopFunc: BeginLoopFuncType? { get }
    var LoopItemFunc: LoopItemFuncType? { get }
    var LoopItemTermFunc: LoopItemTermFuncType? { get }
    var EndLoopFunc: EndLoopFuncType? { get }
    var EndDataFunc: EndDataFuncType? { get }
}

extension PrepareParseCIFFile {

    internal var pointer: UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(unsafeBitCast(self, to: UnsafeMutablePointer<Self>.self))
    }

    func prepareHandlers() -> CIFRawHandlers
    {
        var handlers: CIFRawHandlers = CIFMakeRawHandlers()
        handlers.ctx = pointer
        if let _ = BeginDataFunc { handlers.beginData = BeginDataFunc }
        if let _ = ItemFunc { handlers.item = ItemFunc }
        if let _ = BeginLoopFunc { handlers.beginLoop = BeginLoopFunc }
        if let _ = LoopItemFunc { handlers.loopItem = LoopItemFunc }
        if let _ = LoopItemTermFunc { handlers.loopItemTerm = LoopItemTermFunc }
        if let _ = EndLoopFunc { handlers.endLoop = EndLoopFunc }
        if let _ = EndDataFunc { handlers.endData = EndDataFunc }
        return handlers
    }

}

protocol ParseCIFFile {
    func prepareHandlers() -> CIFRawHandlers
}

extension ParseCIFFile
{
    #if false
    func parse(_ path: String)
    {
        let fp = fopen(path, "r");
        parse(fp)
    }
    #else
    func parse(_ path: String)
    {
        let str = (try? String(contentsOfFile: path)) ?? ""
        var cstr = str.cString(using: .utf8) ?? []
        let count = cstr.count
        let fp = fmemopen(&cstr, count, "r")
        parse(fp)
    }
    #endif

    func parse(_ fp: UnsafeMutablePointer<FILE>!)
    {
        let handlers: CIFRawHandlers = prepareHandlers()
        CIFRawParse2( fp, handlers )
    }
}


enum CIFValue {

    case float(String)
    case integer(String)
    case string(String)
    case text(String)
    case inapplicable
    case unknown
    case unexpected(String)

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
                self = .unexpected( String(cString:bytes) )
                break
        }
    }

}

extension CIFValue {

    var doubleValue: Double? {
        if case .float(let s) = self {
            return (s as NSString?)?.doubleValue
        }
        return nil
    }

    var integerValue: Int? {
        if case .integer(let s) = self {
            return (s as NSString?)?.integerValue
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
