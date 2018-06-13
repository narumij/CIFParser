//
//  CIFLoopTag.h
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/14.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#ifndef CIFLoopTag_h
#define CIFLoopTag_h

#include "CIFLex.h"
#include "CIFTag.h"

typedef struct CIFLoopTag {
    CIFTag *list;
    int capacity;
    size_t count;
} CIFLoopTag;

void CIFLoopTagAdd( CIFLoopTag *stack, CIFLex *lex );
size_t CIFLoopTagCount( CIFLoopTag *stack );
void CIFLoopTagClear( CIFLoopTag *stack );
<<<<<<< HEAD
//const char *CIFLoopTagGetText( CIFLoopTag *stack, int idx );
//size_t CIFLoopTagGetLen( CIFLoopTag *stack, int idx );

=======
<<<<<<< HEAD
//const char *CIFLoopTagGetText( CIFLoopTag *stack, int idx );
//size_t CIFLoopTagGetLen( CIFLoopTag *stack, int idx );

=======
>>>>>>> work
>>>>>>> develop
void CIFLoopTagTearDown( CIFLoopTag *stack );

#endif /* CIFLoopTag_h */
