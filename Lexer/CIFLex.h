//
//  CIFLexer.h
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/14.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#ifndef CIFLexer_h
#define CIFLexer_h

enum CIFLexType {
    LexerError,
    LData_,
    LLoop_,
    LSaveBegin,
    LSaveEnd,
    LTag,
    //    LNumeric,
    LNumericFloat,
    LNumericInteger,
    LQuoteString,
    LUnquoteString1,
    LUnquoteString2,
    LTextField,
    LDot,
    LQue,
    LEOF
};
typedef enum CIFLexType CIFLexType;


typedef struct CIFLex {
    CIFLexType tag;
    const char *text;
    size_t len;
} CIFLex;

#endif /* CIFLexer_h */
