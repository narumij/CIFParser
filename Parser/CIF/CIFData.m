//
//  CIFData.m
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/10.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import "CIFData.h"

@implementation CIFData

- (CIFLoop*)loopForNames:(NSArray<NSString*>*)names
{
    for ( id item in self.items ) {
        if ( ![item isKindOfClass:[CIFLoop class]] ) {
            continue;
        }

        if ( [(CIFLoop*)item namesCount:names] > 0 ) {
            return item;
        }
    }
    return nil;
}

@end
