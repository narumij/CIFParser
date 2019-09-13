//
//  Handlers.c
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/15.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#include <stdio.h>
#include "CIFRawParser.h"

static void beginData( void* ctx, const CIFLex value ) { }
static void item( void *ctx, const CIFTag tag, CIFLex value ) { }
static void beginLoop( void *ctx, CIFLoopTag tags ) { }
static void loopItem( void *ctx, CIFLoopTag tags, size_t itemIndex, CIFLex value ) { }
static void loopItemTerm( void *ctx ) { }
static void endLoop( void *ctx ) { }
static void endData( void *ctx ) { }

CIFRawHandlers CIFMakeRawHandlers() {
    CIFRawHandlers h;
    h.beginData = beginData;
    h.item = item;
    h.beginLoop = beginLoop;
    h.loopItem = loopItem;
    h.loopItemTerm = loopItemTerm;
    h.endLoop = endLoop;
    h.endData = endData;
    return h;
}
