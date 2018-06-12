//
//  CIFSaveRule.m
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/11.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import "CIFSaveRule.h"

#import "CIFItemRule.h"
#import "CIFLoopRule.h"

NSArray *MutableAppend( NSArray *a, id obj );

@implementation CIFSaveRule

@synthesize contents;
@synthesize current;

- (instancetype)initWithString:(NSString*)str tag:(CIFLexemeTag)tag;
{
    assert( tag == LSaveBegin );
    self = [super init];
    if (self) {
        self.contents = [[CIFSaveFrame alloc] init];
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

    if ( tag == LSaveEnd ) {
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
