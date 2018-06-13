//
//  Parser.c
//  CIFReader
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#include "Parser.h"
#include "lex.cif.h"
#include <assert.h>
#import "ParserImpl.h"

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "Lexer.h"
#include "Handlers.h"
#include "TagString.h"

#include "Debug.h"

/*
 
 internal headers

 */

static void prepareItem( Ctx *ctx, Lex *lex );
//static void nextLexeme( void *ctx, Lex* lex );

static ParseState rootParse( Ctx *ctx, Lex *lex );
static ParseState dataParse( Ctx *ctx, Lex *lex );
static ParseState itemParse( Ctx *ctx, Lex *lex );
static ParseState loopParse( Ctx *ctx, Lex *lex );

void ctxCleanUp( Ctx *ctx );

/*

 implementation part 1

 */

static CIFLexemeTag lexTypeCheck( CIFLexemeTag tag, const char *textBytes, size_t len )
{
    if ( textBytes[0] == '.' && len == 1 )
        return LDot;
    if ( textBytes[0] == '?' && len == 1 )
        return LQue;
    return tag;
}

void IssueLexeme(void *scanner,CIFLexemeTag tag,const char *text,size_t len)
{
    Lex lex = { lexTypeCheck(tag,text,len), (char *)text, len };
    assert( lex.tag == lexTypeCheck(tag,text,len));
    assert( lex.text == text );
    assert( lex.len == len );
    ParseState result = rootParse( cifget_extra(scanner), &lex );
    assert( result != PSUnexpectedToken );
}

int Parse( FILE * fp, Handlers *h )
{
    yyscan_t scanner;
    Ctx ctx = {};
    ctx.handlers = h;
    ciflex_init_extra( &ctx, &scanner );
    cifset_in(fp,scanner);
#ifndef NDEBUG
    cifset_debug(1,scanner);
#endif
    int result = ciflex( scanner );
    ciflex_destroy ( scanner );
    ctxCleanUp(&ctx);
    SHOW_STATS();
    return result;
}

void ctxCleanUp( Ctx *ctx ) {
    DeleteTags(&ctx->tags);
    if ( ctx->itemTag.text ) {
        FREE(ctx->itemTag.text, 2);
        ctx->itemTag.len = 0;
        ctx->itemTag.tag = 0;
    }
}

/*

 implementation part 2

 */

//static void nextLexeme( void *ctx, Lex *lex ) {
//    rootParse( ctx, lex );
//}

ParseState rootParse( Ctx *ctx, Lex *lex ) {
    if ( ctx->rootCurrent != NULL ) {
        ParseState code = ctx->rootCurrent(ctx,lex);
        if ( code == PSUnexpectedToken ) {
            return code;
        }
        if ( code == PSComplete ) {
            ctx->rootCurrent = NULL;
            return PSCarryOn;
        } else if (code == PSCarryOn) {
            return code;
        }
    }

    if ( lex->tag == LexerError ) {
        assert(0);
        return PSUnexpectedToken;
    }

    if ( lex->tag == LData_ ) {
        ctx->rootCurrent = dataParse;
        ctx->handlers->beginData( ctx->handlers->ctx, lex->text, lex->len );
        return PSCarryOn;
    }

    if ( lex->tag == LEOF) {
        ctx->handlers->endData( ctx->handlers->ctx );
        ctx->rootCurrent = NULL;
        return PSComplete;
    }

    assert(0);

    return PSUnexpectedToken;
}

ParseState dataParse( Ctx *ctx, Lex *lex ) {
    if ( ctx->dataCurrent != NULL ) {
        ParseState code = ctx->dataCurrent( ctx, lex );
        if ( code == PSUnexpectedToken ) {
            assert(0);
            return code;
        }
        if ( code == PSComplete || code == PSShouldBack ) {
            ctx->dataCurrent = NULL;
            ctx->loopStateValueNow = 0;
        } else if ( code == PSCarryOn ) {
            return PSCarryOn;
        }
        if ( code == PSComplete ) {
            return PSCarryOn;
        }
    }
    switch (lex->tag) {
        case LexerError:
            assert(0);
            return PSUnexpectedToken;
        case LData_:
            return PSShouldBack;
        case LEOF:
            return PSComplete;
        case LTag:
            ctx->dataCurrent = itemParse;
            prepareItem( ctx, lex );
            return PSCarryOn;
        case LLoop_:
            ctx->dataCurrent = loopParse;
            return PSCarryOn;
        default:
            break;
    }
    return PSUnexpectedToken;
}


int isValueTag(Lex *lex ) {
    CIFLexemeTag tags[] = {
        LNumericFloat,
        LNumericInteger,
        LQuoteString,
        LUnquoteString1,
        LUnquoteString2,
        LTextField,
        LDot,
        LQue};
    int tagsCount = sizeof(tags) / sizeof(CIFLexemeTag);
    for ( int i = 0; i < tagsCount; ++i ) {
        if ( tags[i] == lex->tag ) {
            return 1;
        }
    }
    return 0;
}

void prepareItem( Ctx *ctx, Lex *lex ) {
    if (ctx->itemTag.text != NULL) {
        FREE(ctx->itemTag.text, 2);
        ctx->itemTag.text = 0;
    }
    ctx->itemTag.text = MALLOC( lex->len + 1, 2 );
    strcpy(ctx->itemTag.text, lex->text);
    ctx->itemTag.tag = lex->tag;
    ctx->itemTag.len = lex->len;
}

ParseState itemParse( Ctx *ctx, Lex *lex ) {
    if ( !isValueTag(lex) ) {
        assert(0);
        return PSUnexpectedToken;
    }
    TagText tag = { ctx->itemTag.text, ctx->itemTag.len };
    ctx->handlers->item( ctx->handlers->ctx, &tag, lex );
    return PSComplete;
}

ParseState loopParse( Ctx *ctx, Lex *lex ) {
    if ( lex->tag == LEOF ) {
        return PSShouldBack;
    }
    if (!ctx->loopStateValueNow)
    {
        if (lex->tag == LTag) {
            AppendTag( &ctx->tags, lex );
        } else {
            ctx->loopStateValueNow = 1;
            ctx->handlers->beginLoop( ctx->handlers->ctx, &ctx->tags );
        }
    }
    // else にしてはいけない。Loop最初のValueは上のブロック実行後下のブロックで処理をする必要があるため。
    if (ctx->loopStateValueNow)
    {
        if (isValueTag(lex)) {
            ctx->handlers->loopItem(ctx->handlers->ctx, &ctx->tags, ctx->tagIndex, lex );
            ctx->tagIndex += 1;
            if ( ctx->tagIndex == CountTag( &ctx->tags ) ) {
                ctx->handlers->loopItemTerm(ctx->handlers->ctx);
                ctx->tagIndex = 0;
            }
        } else {
            ctx->handlers->endLoop( ctx->handlers->ctx );
            ctx->tagIndex = 0;
            ClearTag(&ctx->tags);
            return PSShouldBack;
        }
    }
    return PSCarryOn;
}




