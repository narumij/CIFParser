//
//  ParserImpl.h
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#ifndef ParserImpl_h
#define ParserImpl_h

#include "Lexer.h"
#include "Parser.h"
#include "TagString.h"



typedef enum ParseState {
    PSUnexpectedToken,
    PSCarryOn,
    PSComplete,
    PSShouldBack,
} ParseState;


struct Ctx;
typedef struct Ctx Ctx;

struct Ctx {
    int loopStateValueNow;
    Lex itemTag;
    int tagIndex;
//    int tagCount;
    ParseState (*rootCurrent)( Ctx *ctx, Lex *lex );
    ParseState (*dataCurrent)( Ctx *ctx, Lex *lex );
    Handlers *handlers;
    TagList tags;
};

ParseState rootParse( Ctx *ctx, Lex *lex );
ParseState dataParse( Ctx *ctx, Lex *lex );
ParseState itemParse( Ctx *ctx, Lex *lex );
ParseState loopParse( Ctx *ctx, Lex *lex );
void prepareItem( Ctx *ctx, Lex *lex );

void nextLexeme( void *ctx, Lex* lex );

#endif /* ParserImpl_h */
