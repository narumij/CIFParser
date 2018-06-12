//
//  CIFLoop.h
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/10.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIFTag.h"
#import "CIFValue.h"

@interface CIFLoop : NSObject
@property(nonnull) NSArray<CIFTag *> *tags;
@property(nonnull) NSArray<CIFValue *> *values;
@property(nonnull,readonly) NSArray<NSString *> *tagNames;
@property(readonly) NSInteger length;
- (nullable NSDictionary<NSString *, CIFValue *> *)dictionaryAtIndex:(NSUInteger)idx;
- (nonnull NSArray<NSDictionary<NSString *, CIFValue *> *> *)all;
- (NSUInteger)namesCount:(nonnull NSArray<NSString *> *)names;
@end

