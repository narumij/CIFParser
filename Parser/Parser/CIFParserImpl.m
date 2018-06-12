//
//  CIFParserImpl.m
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/11.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import "CIFParserImpl.h"

#import "CIFParseRule.h"
#import "CIFRule.h"

#import "lex.cif.h"

@interface CIFParserImpl()
@property CIFRule *rule;
@property id error;
@end

@implementation CIFParserImpl

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rule = [[CIFRule alloc] init];
    }
    return self;
}

-(void)nextLexeme:(CIFLexemeTag)tag
        textBytes:(const char*)textBytes
       textLength:(size_t)textLength
{
    NSString *text = CIFLexemeText( tag, textBytes, textLength );
    [self nextLexeme:NULL tag:tag text:text];
}

-(void)nextLexeme:(void *)scanner
              tag:(CIFLexemeTag)tag
             text:(NSString*)text
{
    if ( self.error != nil ) {
        return;
    }

    if ( tag == LexerError ) {
        self.error = @"error";
        return;
    }

    @autoreleasepool
    {
//        NSLog(@"token %@ (line %zd,column %zd)",CIFLexemeTagName(tag),CIFLine(scanner),CIFColumn(scanner));
        ResultCode result = [self.rule acceptScanner:scanner text:text tag:tag];
        if ( result == UnexpeceteToken ) {
            assert(0);
            self.error = @"error";
        }
    }
}

-(CIF*)getResult
{
    if ( self.error != nil ) {
        return nil;
    }
    CIF *cif = [[CIF alloc] init];
    cif.contents = self.rule.cifRoot;
    assert(cif.contents);
    return cif;
}

@end



