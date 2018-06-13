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

void *DebugMalloc(size_t size);
void DebugFree(void *ptr);
size_t DebugStats(void);
void ShowStats(void);

#if 1
#define MALLOC DebugMalloc
#define FREE DebugFree
#define SHOW_STATS() ShowStats()
#else
#define MALLOC malloc
#define FREE free
#define SHOW_STATS()
#endif

#endif /* Debug_h */
