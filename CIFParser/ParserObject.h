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

<<<<<<< HEAD
// 読んでいて辛いので、もう少しわかりやすくしたい
=======
<<<<<<< HEAD
// 読んでいて辛いので、もう少しわかりやすくしたい
=======
>>>>>>> work
>>>>>>> develop
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
    ParseState (*parseFuncInRoot)( ParserObject *ctx, CIFLex *lex );
    ParseState (*parseFuncInData)( ParserObject *ctx, CIFLex *lex );
    LoopParseState loopParseState;
    CIFTag itemTag;
    CIFLoopTag loopTag;
    int loopTagIndex;
};

static inline void CallBacBeginData( ParserObject *ctx, CIFLex *value ) {
    ctx->handlers->beginData( ctx->handlers->ctx, value );
}
static inline void CallBackItem( ParserObject *ctx, CIFLex *value ) {
    ctx->handlers->item( ctx->handlers->ctx, &ctx->itemTag, value );
}
static inline void CallBackBeginLoop( ParserObject *ctx ) {
    ctx->handlers->beginLoop( ctx->handlers->ctx, &ctx->loopTag );
}
static inline void CallBackLoopItem( ParserObject *ctx, CIFLex *value ) {
    ctx->handlers->loopItem( ctx->handlers->ctx, &ctx->loopTag, ctx->loopTagIndex, value );
}
static inline void CallBackLoopItemTerm( ParserObject *ctx ) {
    ctx->handlers->loopItemTerm( ctx->handlers->ctx );
}
static inline void CallBacEndLoop( ParserObject *ctx ) {
    ctx->handlers->endLoop( ctx->handlers->ctx );
}
static inline void CallBacEndData( ParserObject *ctx ) {
    ctx->handlers->endData( ctx->handlers->ctx );
}
static inline void ResetLoopTag( ParserObject *ctx ) {
    ctx->loopTagIndex = 0;
    CIFLoopTagClear(&ctx->loopTag);
}
static inline void ParseObjectTearDown( ParserObject *ctx ) {
    CIFLoopTagTearDown(&ctx->loopTag);
    CIFTagDeepClearString(&ctx->itemTag);
}

#endif /* ParserImpl_h */
