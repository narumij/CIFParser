//
//  CIFLoop.m
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/10.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import "CIFLoop.h"

@implementation CIFLoop

- (NSInteger)length {
    return self.values.count / self.tags.count;
}

- (NSArray<NSString*>*)tagNames
{
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    for ( CIFTag *t in self.tags ) {
        [mArray addObject:t.name];
    }
    return mArray;
}

- (NSDictionary<CIFTag*,CIFValue*>*)rawDictionayAtIndex:(NSUInteger)idx
{
    NSRange range = NSMakeRange(self.tags.count * idx, self.tags.count);
    NSArray *v = [self.values subarrayWithRange:range];
    return [NSDictionary dictionaryWithObjects:v forKeys:self.tags];
}

- (NSDictionary<NSString*,CIFValue*>*)dictionaryAtIndex:(NSUInteger)idx
{
    NSRange range = NSMakeRange(self.tags.count * idx, self.tags.count);
    NSArray *v = [self.values subarrayWithRange:range];
    return [NSDictionary dictionaryWithObjects:v forKeys:self.tagNames];
}

- (NSArray<NSDictionary<NSString *, CIFValue *> *> *)all
{
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    for ( NSInteger i = 0; i < self.length; ++i ) {
        [mArray addObject:[self dictionaryAtIndex:i]];
    }
    return mArray;
}

- (NSUInteger)namesCount:(NSArray<NSString *> *)names
{
    NSInteger n = 0;
    NSArray *tagNames = self.tagNames;
    for ( NSString *name in names ) {
        if ( [tagNames containsObject:name] ) {
            n += 1;
        }
    }
    return n;
}

@end
