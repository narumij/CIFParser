// Copyright © 2016 zenithgear inc. All rights reserved.

#ifndef CIFLEXER_H_GUARD
#define CIFLEXER_H_GUARD
#define CIF_LEXER_LOG 0
#include <stdlib.h>

enum CIFLexemeTag {
    LexerError,
    LData_,
    LLoop_,
    LSaveBegin,
    LSaveEnd,
    LTag,
//    LNumeric,
    LNumericFloat,
    LNumericInteger,
    LQuoteString,
    LUnquoteString1,
    LUnquoteString2,
    LTextField,
    LDot,
    LQue,
    LEOF
};
typedef enum CIFLexemeTag CIFLexemeTag;

// lex向けのフック
void IssueLexeme(void *scanner,CIFLexemeTag tag,const char *text,size_t len);

#ifdef __OBJC__
#import <Foundation/Foundation.h>

@protocol CIFParserProtocol <NSObject>
-(void)nextLexeme:(CIFLexemeTag)tag
        textBytes:(const char*)textBytes
       textLength:(size_t)textLength;
@end

//int CIFLexer( const char *filepath, id<CIFParserProtocol> callbackObject );
extern int CIFLexerWithFILE( FILE * fp, id<CIFParserProtocol> callbackObject );

size_t CIFLine( void * scanner );
size_t CIFColumn( void * scanner );
NSString *CIFLexemeTagName( CIFLexemeTag tag );
NSString *CIFLexemeText( CIFLexemeTag tag, const char * textBytes, size_t length );

#endif

#endif
