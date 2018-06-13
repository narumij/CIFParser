//
//  Debug.h
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#ifndef Debug_h
#define Debug_h

#include <stdio.h>

void *DebugMalloc(size_t size,int idx);
void DebugFree(void *ptr,int idx);
size_t DebugStats(int idx);
void ShowStats(void);

#ifndef NDEBUG
#define MALLOC(a,b) DebugMalloc(a,b)
#define FREE(a,b) DebugFree(a,b)
#define SHOW_STATS() ShowStats()
#else
#define MALLOC(a,b) malloc(a)
#define FREE(a,b) free(a)
#define SHOW_STATS()
#endif

#endif /* Debug_h */
