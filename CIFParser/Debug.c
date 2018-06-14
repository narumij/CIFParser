//
//  Debug.c
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#include "Debug.h"
#include <stdlib.h>

#define STATS_COUNT 3
static size_t stats[STATS_COUNT] = {0};

void *DebugMalloc(size_t size,int idx) {
    stats[idx] += size;
    size_t *p = malloc(size+sizeof(size_t));
    *((size_t *)p) = size;
    return p + 1;
}

void DebugFree(void *ptr,int idx) {
    stats[idx] -= *((size_t *)ptr-1);
    free((size_t *)ptr-1);
}

size_t DebugStats(int idx) {
    return stats[idx];
}

void ShowStats() {
    printf("* \n");
    for ( int i = 0; i < STATS_COUNT; ++i ) {
        printf("* DEBUG MALLOC STATS[%d] IS ... %zd [%s]\n",i,stats[i],stats[i] == 0 ? "OK" : "NG" );
    }
    printf("* \n");
}
