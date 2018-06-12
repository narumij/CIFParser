//
//  TestParser.swift
//  CIFTest2
//
//  Created by Jun Narumi on 2017/12/16.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

import Cocoa
import CIFParser

protocol SimpleCIFAPI {
    func beginData( name: String) -> Bool
    func item( itemTag: String, tag: CIFLexemeTag, textBytes: UnsafePointer<Int8>!, textLength: Int )
    func beginLoop( tags: [String] ) -> Bool
    func loopItem_( isTerm: Bool, itemTag: String, tag: CIFLexemeTag, textBytes: UnsafePointer<Int8>!, textLength: Int )
    func endLoop()
    func endData()
}

//class TestParser: NSObject, CIFParserProtocol {
//    func parse(withFilePath filename: String) {
//        let fp = fopen(filename, "r")
//        fp.flatMap{ self.parse( withFilePointer: $0 ) }
//        fclose(fp)
//    }
//    func parse(withFilePointer fp: UnsafeMutablePointer<FILE> ) {
//        CIFLexerWithFILE(fp, self)
//    }
////    var handler: SimpleCIFAPI?
//    var str: [String] = []
//    var root = TestRoot()
//    @objc func nextLexeme(_ tag: CIFLexemeTag, textBytes: UnsafePointer<Int8>!, textLength: Int) {
//        _ = root.parse(tag, textBytes, textLength)
//    }
//}

enum TestParseResult {
    case unexpectedToken
    case `continue`
    case complete
    case shouldBack
}

protocol TestParseProtocol {
    var handler: SimpleCIFAPI? { get set }
    func parse(_ tag: CIFLexemeTag,_ textBytes: UnsafePointer<Int8>!,_ textLength: Int) -> TestParseResult
}

class TestRoot: TestParseProtocol {
    
    var handler: SimpleCIFAPI?
    var current: TestData?

    func parse(_ tag: CIFLexemeTag,_ textBytes: UnsafePointer<Int8>!,_ textLength: Int) -> TestParseResult
    {
        if let current = current {
            let code = current.parse(tag,textBytes,textLength)
            if code == .unexpectedToken {
                return code
            }
            if code == .complete {
                self.current = nil
                return .continue
            } else if code == .continue {
                return code
            }
        }

        if tag == LexerError {
            assert(false)
            return .unexpectedToken
        }

        if tag == LData_ {
            current = TestData()
            let name = NSString(bytes: textBytes, length: textLength, encoding: String.Encoding.utf8.rawValue) as String?
            if (name.map{ handler?.beginData(name: $0) } ?? false) == true {
                current?.handler = handler
            }
            return .continue
        }

        if tag == LEOF {
            handler?.endData()
            current = nil
            return .complete
        }

        assert(false)

        return .unexpectedToken
    }
}

class TestData: TestParseProtocol {
    var handler: SimpleCIFAPI?
    var current: TestParseProtocol?
    func parse(_ tag: CIFLexemeTag,_ textBytes: UnsafePointer<Int8>!,_ textLength: Int) -> TestParseResult
    {
        if let current = current {
            let code = current.parse(tag,textBytes,textLength)
            if code == .unexpectedToken {
                return code
            }
            if code == .complete || code == .shouldBack {
                self.current = nil
            } else if code == .complete || code == .continue {
                return .continue
            }
        }
        switch tag {
        case LexerError:
            assert(false)
            return .unexpectedToken
        case LData_:
            return .shouldBack
        case LEOF:
            return .complete
        case LTag:
            current = TestItem(tag,textBytes,textLength)
            current?.handler = handler
            return .continue
        case LLoop_:
            current = TestLoop()
            current?.handler = handler
            return .continue
        default:
            return .unexpectedToken
        }
    }
}

fileprivate func isValueTag(_ tag: CIFLexemeTag) -> Bool {
    return [LNumericFloat,
            LNumericInteger,
            LQuoteString,
            LUnquoteString1,
            LUnquoteString2,
            LTextField,
            LDot,
            LQue].contains(tag)
}

class TestItem: TestParseProtocol {
    var handler: SimpleCIFAPI?
    var itemTag: String
    init(_ tag: CIFLexemeTag,_ textBytes: UnsafePointer<Int8>!,_ textLength: Int) {
        itemTag = NSString(bytes: textBytes, length: textLength, encoding: String.Encoding.utf8.rawValue)! as String
    }
    func parse(_ tag: CIFLexemeTag,_ textBytes: UnsafePointer<Int8>!,_ textLength: Int) -> TestParseResult
    {
        if !isValueTag(tag) {
            return .unexpectedToken
        }
        handler?.item(itemTag: itemTag, tag: tag, textBytes: textBytes, textLength: textLength )
        return .complete
    }
}

struct TestValue {
    init( tag t: CIFLexemeTag, textBytes: UnsafePointer<Int8>, textLength: Int ) {
        tag = t
        bytes = (0..<textLength).map{ textBytes[$0] }
    }
    var tag: CIFLexemeTag
    var bytes: [Int8]
    var textBytes: UnsafePointer<Int8> {
        return UnsafePointer<Int8>(bytes)
    }
    var textLength: Int {
        return bytes.count
    }
}

class TestLoop: TestParseProtocol {
    var handler: SimpleCIFAPI?
    var valueNow: Bool = false
    var tags: [String] = []
    var values: [TestValue] = []
    var tagIndex = 0
    func parse(_ tag: CIFLexemeTag,_ textBytes: UnsafePointer<Int8>!,_ textLength: Int) -> TestParseResult
    {
        if tag == LEOF {
            return .shouldBack
        }
        if !valueNow {
            if tag == LTag {
                let text = NSString(bytes: textBytes, length: textLength, encoding: String.Encoding.utf8.rawValue) as String?
                text.map{ tags.append($0) }
            } else {
                valueNow = true
                // TODO SOMETHING
                if (handler?.beginLoop(tags: tags) ?? false) == false {
                    handler = nil
                }
            }
        }
        if valueNow {
            if isValueTag(tag) {
                handler?.loopItem_( isTerm: tagIndex + 1 == tags.count, itemTag: tags[tagIndex], tag: tag, textBytes: textBytes, textLength: textLength )
                tagIndex += 1
                if tagIndex == tags.count {
                    tagIndex = 0
                }
            } else {
                handler?.endLoop()
                // LOOP END
                return .shouldBack
            }
        }
        return .continue
    }
}
