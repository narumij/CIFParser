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
    nextLexeme( cifget_extra(scanner), &lex );
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
    return result;
}


