//
//  Handlers.h
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#ifndef Handlers_h
#define Handlers_h

#include "Parser.h"

typedef struct Handlers {
    void *ctx;
    void (*beginData)( void* ctx, const char* text, size_t len );
    void (*item)( void *ctx, const CIFTag *tag, Lex *value );
    void (*beginLoop)( void *ctx, CIFLoopTag *tags );
    void (*loopItem)( void *ctx, CIFLoopTag *tags, size_t itemIndex, Lex *value );
    void (*loopItemTerm)( void *ctx );
    void (*endLoop)( void *ctx );
    void (*endData)( void *ctx );
} Handlers;

#endif /* Handlers_h */
