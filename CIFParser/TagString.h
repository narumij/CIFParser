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

typedef struct TagText {
    char *text;
    size_t len;
} TagText;

void CopyString( TagText* str, const char *text, size_t len );
void ClearString( TagText *str );

typedef struct TagList {
    TagText *list;
    int capacity;
    int count;
} TagList;

void IncreaseCapacity( TagList *xs );
void AppendTag( TagList *stack, struct Lex *lex );
int CountTag( TagList *stack );
void ClearTag( TagList *stack );
const char *GetText( TagList *stack, int idx );
size_t GetLen( TagList *stack, int idx );

void DeleteTags( TagList *stack );

// TODO: エラー処理

#endif /* TagString_h */



