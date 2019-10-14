//
//  CACount.c
//  Sample2
//
//  Created by Jun Narumi on 2018/06/14.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#include "CACount.h"

#import <CIFParser/CIFParser.h>

#include <string.h>

typedef struct CACount {
    size_t count;
    int atomID;
} CACount;


void beginLoop( CACount *ctx, CIFLoopHeader tags ) {
    ctx->atomID = -1;
    for ( int i = 0; i < tags.count; ++i ) {
        if ( strncmp(tags.list[i].text, "_atom_site.label_atom_id",tags.list[i].len) == 0 ) {
            ctx->atomID = i;
            return;
        }
    }
}

void loopItem( CACount *ctx, CIFLoopHeader tags, size_t itemIndex, CIFToken value ) {
    if ( ctx->atomID == -1 || ctx->atomID != itemIndex )
        return;
    if ( strncmp(value.text, "CA", value.len) == 0 ) {
        ctx->count += 1;
    }
}

size_t CACountParse( FILE *fp ) {
#if 1
    CACount c = {};
    CIFDataConsumerCallbacks h = {};
    h.ctx = &c;
    h.beginLoop = (void(*)(void*,CIFLoopHeader))beginLoop;
    h.loopItem = (void(*)(void*,CIFLoopHeader,size_t,CIFToken))loopItem;
    CIFRawParse(fp, &h);
    return c.count;
#else
    return 0;
#endif
}

