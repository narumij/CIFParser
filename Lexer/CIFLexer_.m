//  Copyright © 2017年 Jun Narumi. All rights reserved.

#import "CIFLexer_.h"
#include "lex.cif.h"

// 使ってない、がmake testに使えるので残してある

struct CIFLexerExtra {
    void *ctx;
};
typedef struct CIFLexerExtra CIFLexerExtra;

static CIFLexerExtra *getExtra( yyscan_t scanner )
{
    return cifget_extra(scanner);
}

static id<CIFParserProtocol> getObjc( yyscan_t scanner )
{
    return (__bridge id<CIFParserProtocol>)getExtra(scanner)->ctx;
}

static void setObjc( yyscan_t scanner, id<CIFParserProtocol> obj )
{
    getExtra(scanner)->ctx = (__bridge_retained void *)obj;
}

static CIFLexemeTag CIFLexemeTagCheck( CIFLexemeTag tag, const char *textBytes, size_t len )
{
    if ( textBytes[0] == '.' && len == 1 )
        return LDot;
    if ( textBytes[0] == '?' && len == 1 )
        return LQue;
    return tag;
}

void IssueLexeme(yyscan_t scanner,CIFLexemeTag tag,const char *textBytes,size_t len)
{
    id<CIFParserProtocol> obj = getObjc(scanner);
    tag = CIFLexemeTagCheck( tag, textBytes, len );
    [obj nextLexeme:tag textBytes:textBytes textLength:len];
}

int CIFLexerWithFILE( FILE *fp, id<CIFParserProtocol> obj ) {
    yyscan_t scanner;
    CIFLexerExtra extra;
    ciflex_init_extra( &extra, &scanner );
    cifset_in(fp,scanner);
#ifndef NDEBUG
    cifset_debug(1,scanner);
#endif
    setObjc(scanner,obj);
    int result = ciflex( scanner );
    setObjc(scanner,nil);
    ciflex_destroy ( scanner );
    return result;
}

int CIFLexer( const char *filepath, id<CIFParserProtocol> obj )
{
#if 1
    FILE *fp = fopen( filepath, "r" );
    int result = CIFLexerWithFILE( fp, obj );
    fclose(fp);
    return result;
#else
    FILE *fp = fopen( filepath, "r" );
    yyscan_t scanner;
    CIFLexerExtra extra;
    ciflex_init_extra( &extra, &scanner );
    cifset_in(fp,scanner);
    cifset_debug(1,scanner);
    setObjc(scanner,obj);
    int result = ciflex( scanner );
    setObjc(scanner,nil);
    ciflex_destroy ( scanner );
    fclose(fp);
    return result;
#endif
}

size_t CIFLine( void *scanner )
{
    return cifget_lineno(scanner);
}

size_t CIFColumn( void *scanner )
{
    return cifget_column(scanner);
}


#define TAGSTRING(TAG) @#TAG

NSString *CIFLexemeTagName( CIFLexemeTag tag )
{
    NSString *tagName = @"";
    switch (tag) {
            case LexerError:
            tagName = TAGSTRING(LexerError);
            break;
            case LData_:
            tagName = TAGSTRING(LData_);
            break;
            case LLoop_:
            tagName = TAGSTRING(LLoop_);
            break;
            case LSaveBegin:
            tagName = TAGSTRING(LSaveBegin);
            break;
            case LSaveEnd:
            tagName = TAGSTRING(LSaveEnd);
            break;
            case LTag:
            tagName = TAGSTRING(LTag);
            break;
            case LNumericFloat:
            tagName = TAGSTRING(LNumericFloat);
            break;
            case LNumericInteger:
            tagName = TAGSTRING(LNumericInteger);
            break;
            case LQuoteString:
            tagName = TAGSTRING(LQuoteString);
            break;
            case LUnquoteString1:
            tagName = TAGSTRING(LUnquoteString1);
            break;
            case LUnquoteString2:
            tagName = TAGSTRING(LUnquoteString2);
            break;

            case LTextField:
            tagName = TAGSTRING(LTextField);
            break;
            case LDot:
            tagName = TAGSTRING(LDot);
            break;
            case LQue:
            tagName = TAGSTRING(LQue);
            break;
            case LEOF:
            tagName = TAGSTRING(LEOF);
            break;
        default:
            break;
    }
    return tagName;
}

NSString *CIFLexemeText( CIFLexemeTag tag, const char * textBytes, size_t length )
{
    NSString *text = [[NSString alloc] initWithBytes:textBytes length:length encoding:NSUTF8StringEncoding];

    while ( [text characterAtIndex:0] == ' ' ) {
        text = [text substringFromIndex:1];
    }

    while ( [text characterAtIndex:0] == 10 ||
           [text characterAtIndex:0] == 13 ) {
        text = [text substringFromIndex:1];
    }

    while ( [text characterAtIndex:text.length-1] == 10
           || [text characterAtIndex:text.length-1] == 13 ) {
        text = [text substringToIndex:text.length-1];
    }

    switch (tag) {
            case LQuoteString:
            case LTextField:
            text = [text substringWithRange:NSMakeRange(1,text.length-2)];
            break;
            case LData_:
            case LSaveBegin:
            text = [text substringFromIndex:5];
            break;
            case LEOF:
            text = nil;
            break;
        default:
            break;
    }
    return text;
}

#if MAIN
@interface TestObject : NSObject<NSObject,CIFParserProtocol>
@end

@implementation TestObject
-(void)nextLexeme:(void *)scanner
              tag:(CIFLexemeTag)tag
        textBytes:(const char*)textBytes
       textLength:(size_t)textLength
{
    [self nextLexeme:scanner tag:tag text:CIFLexemeText(tag,textBytes,textLength)];
}

-(void)nextLexeme:(void*)scanner tag:(CIFLexemeTag)tag text:(NSString*)text
{
    NSLog(@"[line:%d column:%d] Token (%@) -> (%@) ",
          cifget_lineno(scanner),
          cifget_column(scanner),
          CIFLexemeTagName(tag),
          text);
}
@end

int main ( int argc, char * argv[] )
{
    TestObject *obj = [[TestObject alloc] init];

    FILE *fp = NULL;
    yyscan_t scanner;
    CIFLexerExtra extra;
    ciflex_init_extra( &extra, &scanner );

    setObjc(scanner,obj);

    if ( argc == 2 )
    {
        fp = fopen(argv[1],"r");
        cifset_in(fp,scanner);
    }

    cifset_debug(1,scanner);

    ciflex( scanner );

    setObjc(scanner,nil);
    ciflex_destroy ( scanner );

    if ( fp != NULL )
    {
        fclose(fp);
    }

    return 0;
}
#endif


















