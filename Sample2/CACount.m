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

size_t CACountParse( FILE *fp ) {
    CACount c = {};
    CIFRawHandlers h = CIFMakeRawHandlers();
    h.ctx = &c;
    h.beginLoop = (void(*)(void*,CIFLoopTag*))beginLoop;
    h.loopItem = (void(*)(void*,CIFLoopTag*,size_t,CIFLex*))loopItem;
    CIFRawParse(fp, &h);
    return c.count;
}

