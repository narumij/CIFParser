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
#include "CIFTag.h"
#include "CIFLoopTag.h"

typedef struct CIFRawHandlers {
    void *ctx;
    void (*beginData)( void* ctx, const CIFLex* value );
    void (*item)( void *ctx, const CIFTag *tag, CIFLex *value );
    void (*beginLoop)( void *ctx, CIFLoopTag *tags );
    void (*loopItem)( void *ctx, CIFLoopTag *tags, size_t itemIndex, CIFLex *value );
    void (*loopItemTerm)( void *ctx );
    void (*endLoop)( void *ctx );
    void (*endData)( void *ctx );
} CIFRawHandlers;

CIFRawHandlers CIFMakeRawHandlers(void);

int CIFRawParse( FILE * fp, CIFRawHandlers *h );

#endif /* Parser_h */
