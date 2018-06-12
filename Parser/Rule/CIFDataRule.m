//
//  CIFDataRule.m
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/11.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import "CIFDataRule.h"

#import "CIFItemRule.h"
#import "CIFLoopRule.h"

NSArray *MutableAppend( NSArray *a, id obj );

@implementation CIFDataRule

@synthesize contents;
@synthesize current;

- (instancetype)initWithString:(NSString*)str tag:(CIFLexemeTag)tag;
{
    assert( tag == LData_ );

    self = [super init];
    if (self) {
        self.contents = [[CIFData alloc] init];
        self.contents.name = str;
    }

    return self;

}

-(ResultCode)acceptScanner:(void *)scanner text:(NSString*)text tag:(CIFLexemeTag)tag {

    if ( current != nil ) {
        ResultCode code = [current acceptScanner:scanner text:text tag:tag];
        if ( code == UnexpeceteToken ) {
            return code;
        }
        if ( code == Complete || code == ShouldBack ) {
//            NSLog(@"%@",current);
            contents.items = MutableAppend( contents.items, current.contents );
            current = nil;
        }
        if ( code == Complete || code == Continue ) {
            return Continue;
        }
    }

    if ( tag == LData_ ) {
        return ShouldBack;
    }

    if ( tag == LSaveBegin ) {
        return ShouldBack;
    }

    if ( tag == LEOF ) {
        return Complete;
    }

    if ( tag == LTag ) {
        current = [[CIFItemRule alloc] initWithString:text tag:tag];
        return Continue;
    }

    if ( tag == LLoop_ ) {
        current = [[CIFLoopRule alloc] initWithString:text tag:tag];
        return Continue;
    }

    return UnexpeceteToken;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(DATA_%@)",self.contents.name];
}

@end
