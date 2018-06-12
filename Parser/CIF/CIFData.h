//
//  CIFData.h
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/10.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIFLoop.h"

@interface CIFData : NSObject
@property NSString *name;
@property NSArray *items;
- (CIFLoop*)loopForNames:(NSArray<NSString*>*)names;
@end

