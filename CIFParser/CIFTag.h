//
//  CIFTag.h
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/14.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#ifndef CIFTag_h
#define CIFTag_h

#include <stdio.h>

typedef struct CIFTag {
    char *text;
    size_t len;
    size_t capa;
} CIFTag;

void CIFTagAssignString( CIFTag* str, const char *text, size_t len );
void CIFTagClearString( CIFTag *str );
void CIFTagDeepClearString( CIFTag *str );

#endif /* CIFTag_h */
