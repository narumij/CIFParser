//
//  Parser.h
//  CIFReader
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//
#include "cif.h"
#include "cif.tab.h"
#include <stdio.h>

#ifndef Parser_h
#define Parser_h

typedef enum CIFDataInputError {
    CIFDataInputTokenizeError,
    CIFDataInputParseError
} CIFDataInputError;

typedef struct CIFDataConsumerCallbacks {
    void *ctx;
    void (*beginData)( void* ctx, CIFToken value );
    void (*item)( void *ctx, CIFTag tag, CIFToken value );
    void (*beginLoop)( void *ctx, CIFLoopHeader header );
    void (*loopItem)( void *ctx, CIFLoopHeader header, size_t itemIndex, CIFToken value );
    void (*loopItemTerm)( void *ctx );
    void (*endLoop)( void *ctx );
    void (*endData)( void *ctx );
    void (*error)(void *ctx, CIFDataInputError, const char *msg );
} CIFDataConsumerCallbacks;

extern int CIFRawParse2( FILE * fp, CIFDataConsumerCallbacks h );
extern int CIFRawParse( FILE * fp, CIFDataConsumerCallbacks *h );

#endif /* Parser_h */
