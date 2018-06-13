//
//  Debug.c
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#include "Debug.h"

#include <stdlib.h>

static size_t stats = 0;

void *DebugMalloc(size_t size) {
    stats += size;
    size_t *p = malloc(size+sizeof(size_t));
    *((size_t *)p) = size;
    return p + 1;
}

void DebugFree(void *ptr) {
    stats -= *((size_t *)ptr-1);
    free((size_t *)ptr-1);
}

size_t DebugStats() {
    return stats;
}

void ShowStats() {
    printf("* \n");
    printf("* DEBUG MALLOC STATS IS ... %zd\n",stats);
    printf("* \n");
}
