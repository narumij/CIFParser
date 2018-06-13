//
//  Lexer.h
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#ifndef Lexer_h
#define Lexer_h

#define CIF_LEXER_LOG 0
#include <stdlib.h>

enum CIFLexemeTag {
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
typedef enum CIFLexemeTag CIFLexemeTag;

void IssueLexeme( void *scanner, CIFLexemeTag tag, const char *text, size_t len );

#endif /* Lexer_h */
