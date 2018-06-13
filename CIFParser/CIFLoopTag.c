//
//  CIFLoopTag.c
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/14.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#include <stdlib.h>

#include "CIFLoopTag.h"
#include "CIFTag.h"
#include "Debug.h"
#include "Parser.h"

void IncreaseCapacity( CIFLoopTag *xs ) {
    int newCapacity = xs->capacity == 0 ? 8 : xs->capacity * 2;
    CIFTag *newList = MALLOC(newCapacity * sizeof(CIFTag),1);
    for (int i = 0; i < newCapacity; ++i ) {
        newList[i].text = 0;
        newList[i].len = 0;
        newList[i].capa = 0;
    }
    for (int i = 0; i < xs->count; ++i) {
        CIFTagAssignString( &newList[i], xs->list[i].text, xs->list[i].len );
    }
    if ( xs->list ) {
        for ( int i = 0; i < xs->capacity; ++i ) {
            DeepClearString(&xs->list[i]);
        }
        FREE(xs->list,1);
    }
    xs->list = newList;
    xs->capacity = newCapacity;
}

void AppendTag( CIFLoopTag *stack, Lex *lex ) {
    if ( stack->capacity <= (stack->count + 1) )
        IncreaseCapacity(stack);
    CIFTagAssignString( &stack->list[stack->count], lex->text, lex->len );
    stack->count += 1;
}

int CountTag( CIFLoopTag *stack ) {
    return stack->count;
}

void ClearTag( CIFLoopTag *stack ) {
    for (int i = 0; i < stack->capacity; ++i ) {
        ClearString(&stack->list[i]);
    }
    stack->count = 0;
}

const char *GetText( CIFLoopTag *stack, int idx ) {
    return stack->list[idx].text;
}

size_t GetLen( CIFLoopTag *stack, int idx ) {
    return stack->list[idx].len;
}

void DeleteTags( CIFLoopTag *stack )
{
    for ( int i = 0; i < stack->capacity; ++i ) {
        DeepClearString(&stack->list[i]);
    }
    FREE(stack->list,1);
    stack->capacity = 0;
    stack->count = 0;
}
