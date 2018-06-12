//
//  CIFDataRule.h
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/11.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIFParseRule.h"
#import "CIFData.h"

@interface CIFDataRule : NSObject<CIFLeafRule>
@property CIFData *contents;
@end
