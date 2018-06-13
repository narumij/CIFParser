//
//  Parser.h
//  CIFReader
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#ifndef Parser_h
#define Parser_h

#include <stdio.h>
#include "Lexer.h"
#include "TagString.h"

typedef struct Lex {
    CIFLexemeTag tag;
    char *text;
    size_t len;
} Lex;

typedef struct Handlers {
    void *ctx;
    void (*beginData)( void* ctx, const char* text, size_t len );
    void (*item)( void *ctx, const TagText *tag, Lex *value );
    void (*beginLoop)( void *ctx, TagList *tags );
    void (*loopItem)( void *ctx, TagList *tags, size_t itemIndex, Lex *value );
    void (*loopItemTerm)( void *ctx );
    void (*endLoop)( void *ctx );
    void (*endData)( void *ctx );
} Handlers;

int Parse( FILE * fp, Handlers *h );

#endif /* Parser_h */
