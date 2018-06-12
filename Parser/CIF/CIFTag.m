//
//  CIFTag.m
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/11.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import "CIFTag.h"

@implementation CIFTag

- (id)copyWithZone:(NSZone *)zone
{
    CIFTag *n = [[CIFTag alloc] init];
    n.name = self.name;
    return n;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@",self.name];
}

- (NSInteger)hash {
    return self.name.hash;
}

@end
