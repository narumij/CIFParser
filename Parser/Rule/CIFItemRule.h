//
//  CIFItemRule.h
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/11.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIFParseRule.h"

@class CIFItem;

@interface CIFItemRule : NSObject<CIFLeafRule>
@property CIFItem *contents;
@end
