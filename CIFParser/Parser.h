//
//  Parser.h
//  CIFReader
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#ifndef Parser_h
#define Parser_h

#include <stdio.h>
#include "Lexer.h"
#include "CIFLoopTag.h"

typedef struct Lex {
    CIFLexemeTag tag;
    char *text;
    size_t len;
} Lex;

struct Handlers;
typedef struct Handlers Handlers;

int Parse( FILE * fp, Handlers *h );

#endif /* Parser_h */
