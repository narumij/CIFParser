//
//  TagString.h
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#ifndef TagString_h
#define TagString_h

#include <stdlib.h>

struct Lex;

struct CIFTag;
typedef struct CIFTag CIFTag;

typedef struct CIFLoopTag {
    CIFTag *list;
    int capacity;
    int count;
} CIFLoopTag;

void IncreaseCapacity( CIFLoopTag *xs );
void AppendTag( CIFLoopTag *stack, struct Lex *lex );
int CountTag( CIFLoopTag *stack );
void ClearTag( CIFLoopTag *stack );
const char *GetText( CIFLoopTag *stack, int idx );
size_t GetLen( CIFLoopTag *stack, int idx );

void DeleteTags( CIFLoopTag *stack );

// TODO: エラー処理

#endif /* TagString_h */



