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
#include "CIFRawParser.h"
#include "ParserObject.h"
#include "Lexer.h"
#include "Debug.h"

/*
 
 internal headers

 */

static ParseState rootParse( ParserObject *ctx, CIFLex *lex );
static ParseState dataParse( ParserObject *ctx, CIFLex *lex );
static ParseState itemParse( ParserObject *ctx, CIFLex *lex );
static ParseState loopParse( ParserObject *ctx, CIFLex *lex );

/*

 implementation part 1

 */

static CIFLexType lexTypeCheck( CIFLexType tag, const char *textBytes, size_t len )
{
    // lexerで判別するように出来なかったので、代替でここで判別している
    if ( textBytes[0] == '.' && len == 1 )
        return LDot;
    if ( textBytes[0] == '?' && len == 1 )
        return LQue;
    return tag;
}

void IssueLexeme( void *scanner,CIFLexType tag, const char *text, size_t len )
{
    assert(len != 0);
    CIFLex lex = { lexTypeCheck(tag,text,len), (char *)text, len };
//    assert( lex.tag == lexTypeCheck(tag,text,len));
    assert( lex.text == text );
    assert( lex.len == len );
    ParseState result = rootParse( cifget_extra(scanner), &lex );
    assert( result != PSUnexpectedToken );
    if ( result == PSUnexpectedToken ) {
        // lexerを止めたい、がまだ方法が分からない
    }
}

int CIFRawParse( FILE * fp, CIFRawHandlers *h )
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
    ParseObjectTearDown(&ctx);
    SHOW_STATS();
    return result;
}


/*

 implementation part 2

 */

//static void nextLexeme( void *ctx, Lex *lex ) {
//    rootParse( ctx, lex );
//}

ParseState rootParse( ParserObject *ctx, CIFLex *lex ) {
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
        CallBacBeginData( ctx, lex );
        return PSCarryOn;
    }

    if ( lex->tag == LEOF) {
        CallBacEndData(ctx);
        ctx->parseFuncInRoot = NULL;
        return PSComplete;
    }

    assert(0);

    return PSUnexpectedToken;
}

ParseState dataParse( ParserObject *ctx, CIFLex *lex ) {
    if ( ctx->parseFuncInData != NULL ) {
        ParseState code = ctx->parseFuncInData( ctx, lex );
        if ( code == PSUnexpectedToken ) {
            assert(0);
            return code;
        }
        if ( code == PSComplete || code == PSShouldBack ) {
            ctx->parseFuncInData = NULL;
            ctx->loopParseState = LPSTags;
        } else if ( code == PSCarryOn ) {
            return PSCarryOn;
        }
        if ( code == PSComplete ) { // PSCompletはloopは返さない。itemが返す。
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


int isValueTag(CIFLex *lex ) {
    CIFLexType tags[] = {
        LNumericFloat,
        LNumericInteger,
        LQuoteString,
        LUnquoteString1,
        LUnquoteString2,
        LTextField,
        LDot,
        LQue};
    int tagsCount = sizeof(tags) / sizeof(CIFLexType);
    for ( int i = 0; i < tagsCount; ++i ) {
        if ( tags[i] == lex->tag )
            return 1;
    }
    return 0;
}

ParseState itemParse( ParserObject *ctx, CIFLex *lex ) {
    if ( !isValueTag(lex) ) {
        assert(0);
        return PSUnexpectedToken;
    }
    CallBackItem(ctx, lex);
    return PSComplete;
}

ParseState loopParse( ParserObject *ctx, CIFLex *lex ) {
    if ( lex->tag == LEOF ) {
        return PSShouldBack;
    }
    if ( ctx->loopParseState == LPSTags )
    {
        if (lex->tag == LTag) {
            CIFLoopTagAdd( &ctx->loopTag, lex );
        } else {
            ctx->loopParseState = LPSValues;
            CallBackBeginLoop(ctx);
        }
    }
    // else にしてはいけない。Loop最初のValueは上のブロック実行後下のブロックで処理をする必要があるため。
    if ( ctx->loopParseState == LPSValues )
    {
        if (isValueTag(lex)) {
            CallBackLoopItem( ctx, lex );
            ctx->loopTagIndex += 1;
            if ( ctx->loopTagIndex == CIFLoopTagCount( &ctx->loopTag ) ) {
                CallBackLoopItemTerm(ctx);
                ctx->loopTagIndex = 0;
            }
        } else {
            CallBacEndLoop(ctx);
            ResetLoopTag(ctx);
            return PSShouldBack;
        }
    }
    return PSCarryOn;
}




