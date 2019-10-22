//
//  Lexer.h
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#ifndef CIF_H
#define CIF_H

typedef enum CIFTokenType {
    CIFTokenUnknown = -1,
    CIFTokenNumericFloat = 0,
    CIFTokenNumericInteger,
    CIFTokenString,
    CIFTokenTextField,
    CIFTokenDot,
    CIFTokenQue,
    CIFTokenTypeCount
} CIFTokenType;


typedef struct CIFToken {
    CIFTokenType tokenType;
    const char *text;
    int len;
} CIFToken;

typedef struct CIFTag {
    const char *text;
    int len;
} CIFTag;

typedef struct CIFLoopHeader {
    CIFTag *list;
    int capacity;
    int count;
} CIFLoopHeader;

#endif /* cif_h */
