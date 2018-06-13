//
//  Lexer.h
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#ifndef Lexer_h
#define Lexer_h

#define CIF_LEXER_LOG 0
#include <stdlib.h>

#include "CIFLexer.h"

void IssueLexeme( void *scanner, CIFLexemeTag tag, const char *text, size_t len );

#endif /* Lexer_h */
