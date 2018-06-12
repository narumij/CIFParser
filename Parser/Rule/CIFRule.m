//
//  CIFRule.m
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/11.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import "CIFRule.h"

#import "CIFDataRule.h"
#import "CIFSaveRule.h"

NSArray *MutableAppend( NSArray *a, id obj );

NSString *PositionString( void* scanner ) {
    return [NSString stringWithFormat:@"line %zd, column %zd",CIFLine(scanner),CIFColumn(scanner)];
}

@implementation CIFRule

@synthesize current;

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(ResultCode)acceptScanner:(void *)scanner text:(NSString*)text tag:(CIFLexemeTag)tag {
    
    if ( current != nil ) {
        ResultCode code = [current acceptScanner:scanner text:text tag:tag];
        if ( code == UnexpeceteToken ) {
            assert(0);
            return code;
        }
        if (code == Complete) {
            self.cifRoot = MutableAppend( self.cifRoot, self.current.contents );
            self.current = nil;
            return Continue;
        } else if (code == Continue) {
            return code;
        }
    }

    if ( tag == LexerError ) {
        assert(0);
        return UnexpeceteToken;
    }

    if ( tag == LData_ ) {
        current = [[CIFDataRule alloc] initWithString:text tag:tag];
        return Continue;
    }

//    if ( tag == LSaveBegin ) {
//        current = [[CIFSaveRule alloc] initWithString:text tag:tag];
//        return Continue;
//    }

    if ( tag == LEOF ) {
        current = nil;
        return Complete;
    }

    assert("unexpected token.");

    return UnexpeceteToken;
}

@end
