//
//  Parser.c
//  CIFReader
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <assert.h>

#include "lex.cif.h"

#include "Parser.h"
#include "ParserObject.h"
#include "Lexer.h"
#include "Handlers.h"
#include "CIFTag.h"

#include "Debug.h"

/*
 
 internal headers

 */

//static void prepareItem( Ctx *ctx, Lex *lex );
//static void nextLexeme( void *ctx, Lex* lex );

static ParseState rootParse( ParserObject *ctx, Lex *lex );
static ParseState dataParse( ParserObject *ctx, Lex *lex );
static ParseState itemParse( ParserObject *ctx, Lex *lex );
static ParseState loopParse( ParserObject *ctx, Lex *lex );

void ctxCleanUp( ParserObject *ctx );

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

void IssueLexeme( void *scanner,CIFLexemeTag tag, const char *text, size_t len )
{
    assert(len != 0);
    Lex lex = { lexTypeCheck(tag,text,len), (char *)text, len };
    assert( lex.tag == lexTypeCheck(tag,text,len));
    assert( lex.text == text );
    assert( lex.len == len );
    ParseState result = rootParse( cifget_extra(scanner), &lex );
    assert( result != PSUnexpectedToken );
    if ( result == PSUnexpectedToken ) {
        // lexerを止めたい、がまだ方法が分からない
    }
}

int Parse( FILE * fp, Handlers *h )
{
    yyscan_t scanner;
    ParserObject ctx = {};
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

void ctxCleanUp( ParserObject *ctx ) {
    DeleteTags(&ctx->loopTag);
    DeepClearString(&ctx->itemTag);
}

/*

 implementation part 2

 */

//static void nextLexeme( void *ctx, Lex *lex ) {
//    rootParse( ctx, lex );
//}

ParseState rootParse( ParserObject *ctx, Lex *lex ) {
    if ( ctx->parseFuncInRoot != NULL ) {
        ParseState code = ctx->parseFuncInRoot(ctx,lex);
        if ( code == PSUnexpectedToken ) {
            return code;
        }
        if ( code == PSComplete ) {
            ctx->parseFuncInRoot = NULL;
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
        ctx->parseFuncInRoot = dataParse;
        ctx->handlers->beginData( ctx->handlers->ctx, lex->text, lex->len );
        return PSCarryOn;
    }

    if ( lex->tag == LEOF) {
        ctx->handlers->endData( ctx->handlers->ctx );
        ctx->parseFuncInRoot = NULL;
        return PSComplete;
    }

    assert(0);

    return PSUnexpectedToken;
}

ParseState dataParse( ParserObject *ctx, Lex *lex ) {
    if ( ctx->parseFuncInData != NULL ) {
        ParseState code = ctx->parseFuncInData( ctx, lex );
        if ( code == PSUnexpectedToken ) {
            assert(0);
            return code;
        }
        if ( code == PSComplete || code == PSShouldBack ) {
            ctx->parseFuncInData = NULL;
            ctx->loopParseState = 0;
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
            ctx->parseFuncInData = itemParse;
            CIFTagAssignString( &ctx->itemTag, lex->text, lex->len );
            return PSCarryOn;
        case LLoop_:
            ctx->parseFuncInData = loopParse;
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

ParseState itemParse( ParserObject *ctx, Lex *lex ) {
    if ( !isValueTag(lex) ) {
        assert(0);
        return PSUnexpectedToken;
    }
    CIFTag tag = { ctx->itemTag.text, ctx->itemTag.len };
    ctx->handlers->item( ctx->handlers->ctx, &tag, lex );
    return PSComplete;
}

ParseState loopParse( ParserObject *ctx, Lex *lex ) {
    if ( lex->tag == LEOF ) {
        return PSShouldBack;
    }
    if ( ctx->loopParseState == LPSTags )
    {
        if (lex->tag == LTag) {
            AppendTag( &ctx->loopTag, lex );
        } else {
            ctx->loopParseState = 1;
            ctx->handlers->beginLoop( ctx->handlers->ctx, &ctx->loopTag );
        }
    }
    // else にしてはいけない。Loop最初のValueは上のブロック実行後下のブロックで処理をする必要があるため。
    if ( ctx->loopParseState == LPSValues )
    {
        if (isValueTag(lex)) {
            ctx->handlers->loopItem(ctx->handlers->ctx, &ctx->loopTag, ctx->loopTagIndex, lex );
            ctx->loopTagIndex += 1;
            if ( ctx->loopTagIndex == CountTag( &ctx->loopTag ) ) {
                ctx->handlers->loopItemTerm(ctx->handlers->ctx);
                ctx->loopTagIndex = 0;
            }
        } else {
            ctx->handlers->endLoop( ctx->handlers->ctx );
            ctx->loopTagIndex = 0;
            ClearTag(&ctx->loopTag);
            return PSShouldBack;
        }
    }
    return PSCarryOn;
}




