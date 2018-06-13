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
#include "CIFTag.h"
#include "CIFLoopTag.h"

#include "Handlers.h"

// 読んでいて辛いので、もう少しわかりやすくしたい
typedef enum ParseState {
    PSUnexpectedToken,
    PSCarryOn,
    PSComplete,
    PSShouldBack,
} ParseState;

typedef enum LoopParseState {
    LPSTags,
    LPSValues,
} LoopParseState;

struct ParserObject;
typedef struct ParserObject ParserObject;

struct ParserObject {
    Handlers *handlers;
    ParseState (*parseFuncInRoot)( ParserObject *ctx, Lex *lex );
    ParseState (*parseFuncInData)( ParserObject *ctx, Lex *lex );
    LoopParseState loopParseState;
    CIFTag itemTag;
    CIFLoopTag loopTag;
    int loopTagIndex;
};

static inline void CallBackItem( ParserObject *ctx, Lex *value ) {
    ctx->handlers->item(ctx->handlers->ctx, &ctx->itemTag, value );
}

static inline void CallBackLoopItem( ParserObject *ctx, Lex *value ) {
    ctx->handlers->loopItem(ctx->handlers->ctx, &ctx->loopTag, ctx->loopTagIndex, value );
}

#endif /* ParserImpl_h */
