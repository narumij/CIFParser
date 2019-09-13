//
//  CIFTag.c
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/14.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "CIFTag.h"
#include "Debug.h"

void CIFTagAssignString( CIFTag* str, const char *text, size_t len ) {
    assert(len != 0);
    if ( str->capa == 0 || str->capa < len ) {
        if ( str->text != NULL ) {
            FREE((void*)str->text,0);
        }
        str->text = MALLOC( len + 1 , 0 );
    }
    str->len = len;
    str->capa = len;
    strcpy((void*)str->text,text);
}

void CIFTagClearString( CIFTag *str ) {
    str->len = 0;
}

void CIFTagDeepClearString( CIFTag *str ) {
    if ( str->text ) {
        FREE((void*)str->text,0);
        str->text = 0;
    }
    str->len = 0;
    str->capa = 0;
}
