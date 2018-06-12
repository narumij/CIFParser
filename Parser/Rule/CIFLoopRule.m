//
//  CIFLoopRule.m
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/11.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import "CIFLoopRule.h"

#import "CIFLoop.h"
#import "CIFTag.h"
#import "CIFValue.h"

typedef enum Stage {
    Tags,
    Values,
} Stage;

NSArray *MutableAppend( NSArray *a, id obj ) {
    assert(obj);
    NSMutableArray *b = (NSMutableArray *)a;
    if ( b == nil ) {
        b = [[NSMutableArray alloc] init];
    }
    [b addObject:obj];
    return b;
}

@interface CIFLoopRule()
@property Stage stage;
@end

@implementation CIFLoopRule

@synthesize current;

- (instancetype)initWithString:(NSString*)str tag:(CIFLexemeTag)tag;
{
    assert( tag == LLoop_ );

    self = [super init];
    if (self) {
        self.contents = [[CIFLoop alloc] init];
    }

    return self;

}

- (void)appendTag:(NSString*)text tag:(CIFLexemeTag)tag {
    CIFTag *tagObject = [[CIFTag alloc] init];
    tagObject.name = text;
    self.contents.tags = MutableAppend( self.contents.tags, tagObject );
}

- (void)appendValue:(NSString*)text tag:(CIFLexemeTag)tag {
    CIFValue *value = [CIFValue valueWithText:text tag:tag];
    self.contents.values = MutableAppend( self.contents.values, value );
}

-(ResultCode)acceptScanner:(void *)scanner text:(NSString*)text tag:(CIFLexemeTag)tag {

    if ( tag == LEOF ) {
        return ShouldBack;
    }

    if ( self.stage == Tags ) {
        if ( tag == LTag ) {
            [self appendTag:text tag:tag];
        } else {
            self.stage = Values;
        }
    }

    if ( self.stage == Values ) {
        if ( CIFLexemeTagIsValue(tag) ) {
            [self appendValue:text tag:tag];
        } else {
            return ShouldBack;
        }
    }

    return Continue;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"([%@], [%@])",
            [self.contents.tags componentsJoinedByString:@", "],
            [self.contents.values componentsJoinedByString:@", "]];
}

@end




