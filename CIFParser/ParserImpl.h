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

// 読んでいて辛いので、もう少しわかりやすくしたい
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
    ParseState (*rootCurrent)( Ctx *ctx, Lex *lex );
    ParseState (*dataCurrent)( Ctx *ctx, Lex *lex );
    Handlers *handlers;
    CIFLoopTag tags;
};

#endif /* ParserImpl_h */
