//
//  CIFLoopTag.h
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/14.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#ifndef CIFLoopTag_h
#define CIFLoopTag_h

#include <stdio.h>

struct Lex;

struct CIFTag;
typedef struct CIFTag CIFTag;

typedef struct CIFLoopTag {
    CIFTag *list;
    int capacity;
    size_t count;
} CIFLoopTag;

void CIFLoopTagAdd( CIFLoopTag *stack, struct Lex *lex );
size_t CIFLoopTagCount( CIFLoopTag *stack );
void CIFLoopTagClear( CIFLoopTag *stack );
const char *CIFLoopTagGetText( CIFLoopTag *stack, int idx );
//size_t CIFLoopTagGetLen( CIFLoopTag *stack, int idx );

void DeleteTags( CIFLoopTag *stack );

#endif /* CIFLoopTag_h */
