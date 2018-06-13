//
//  TagString.c
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#include "TagString.h"
#include <string.h>
#include "ParserImpl.h"

#include "Debug.h"

void CopyString( TagText* str, const char *text, size_t len ) {
    if ( str->text != NULL ) {
        FREE(str->text);
    }
    str->text = MALLOC(len + 1);
    str->len = len;
    strcpy(str->text,text);
}

void ClearString( TagText *str ) {
    if ( str->text ) {
        FREE(str->text);
        str->text = 0;
    }
    str->len = 0;
}

void IncreaseCapacity( TagList *xs ) {
    int newCapacity = xs->capacity == 0 ? 8 : xs->capacity * 2;
    TagText *newList = MALLOC(newCapacity * sizeof(TagText));
    for (int i = 0; i < newCapacity; ++i ) {
        newList[i].text = 0;
    }
    for (int i = 0; i < xs->count; ++i) {
        CopyString( &newList[i], xs->list[i].text, xs->list[i].len );
    }
    if ( xs->list )
        FREE(xs->list);
    xs->list = newList;
    xs->capacity = newCapacity;
}

void AppendTag( TagList *stack, struct Lex *lex ) {
    if ( stack->capacity <= (stack->count + 1) )
        IncreaseCapacity(stack);
    CopyString( &stack->list[stack->count], lex->text, lex->len );
    stack->count += 1;
}

int CountTag( TagList *stack ) {
    return stack->count;
}

void ClearTag( TagList *stack ) {
    for (int i = 0; i < stack->capacity; ++i ) {
        ClearString(&stack->list[i]);
    }
    stack->count = 0;
}

const char *GetText( TagList *stack, int idx ) {
    return stack->list[idx].text;
}

size_t GetLen( TagList *stack, int idx ) {
    return stack->list[idx].len;
}

void DeleteTags( TagList *stack )
{
    for ( int i = 0; i < stack->capacity; ++i ) {
        ClearString(&stack->list[i]);
    }
    FREE(stack->list);
    stack->capacity = 0;
    stack->count = 0;
}



