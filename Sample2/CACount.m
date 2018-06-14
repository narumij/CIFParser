//
//  CACount.c
//  Sample2
//
//  Created by Jun Narumi on 2018/06/14.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#include "CACount.h"

#import <CIFParser/CIFParser.h>

typedef struct CACount {
    size_t count;
    int atomID;
} CACount;

void beginData( void* ctx, const CIFLex* value ) {
}
void item( void *ctx, const CIFTag *tag, CIFLex *value ) {
}
void beginLoop( CACount *ctx, CIFLoopTag *tags ) {
    ctx->atomID = -1;
    for ( int i = 0; i < tags->count; ++i ) {
        if ( strcmp(tags->list[i].text, "_atom_site.label_atom_id") ) {
            ctx->atomID = i;
            return;
        }
    }
}
void loopItem( CACount *ctx, CIFLoopTag *tags, size_t itemIndex, CIFLex *value ) {
    if ( ctx->atomID == -1 || ctx->atomID != itemIndex )
        return;
    if ( strcmp(value->text, "CA") ) {
        ctx->count += 1;
    }
}
void loopItemTerm( void *ctx ) {
}
void endLoop( void *ctx ) {
}
void endData( void *ctx ) {
}

size_t CACountParse( FILE *fp ) {
    CACount c = {};
    Handlers h;
    h.ctx = &c;
    h.beginData = beginData;
    h.item = item;
    h.beginLoop = (void(*)(void*,CIFLoopTag*))beginLoop;
    h.loopItem = (void(*)(void*,CIFLoopTag*,size_t,CIFLex*))loopItem;
    h.loopItemTerm = loopItemTerm;
    h.endLoop = endLoop;
    h.endData = endData;
    Parse(fp, &h);
    return c.count;
}

