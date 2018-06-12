//
//  CIFItemRule.m
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/11.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import "CIFItemRule.h"

#import "CIFItem.h"
#import "CIFTag.h"
#import "CIFValue.h"

BOOL CIFLexemeTagIsValue(CIFLexemeTag tag) {
    return tag == LNumericFloat
    || tag == LNumericInteger
    || tag == LQuoteString
    || tag == LUnquoteString1
    || tag == LUnquoteString2
    || tag == LTextField
    || tag == LDot
    || tag == LQue;
}

@implementation CIFItemRule

@synthesize current;

- (instancetype)initWithString:(NSString*)str tag:(CIFLexemeTag)tag;
{
    assert( tag == LTag );

    self = [super init];
    if (self) {
        self.contents = [[CIFItem alloc] init];
        CIFTag *tag = [[CIFTag alloc] init];
        tag.name = str;
        self.contents.tag = tag;
    }

    return self;

}

-(ResultCode)acceptScanner:(void *)scanner text:(NSString*)text tag:(CIFLexemeTag)tag {
    if ( !CIFLexemeTagIsValue(tag) ) {
        return UnexpeceteToken;
    }
    self.contents.value = [CIFValue valueWithText:text tag:tag];
    return Complete;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"( %@, %@ )",self.contents.tag.name,self.contents.value];
}

@end









