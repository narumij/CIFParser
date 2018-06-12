//
//  CIFSaveRule.h
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/11.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIFParseRule.h"
#import "CIFSaveFrame.h"

@interface CIFSaveRule : NSObject<CIFLeafRule>
@property CIFSaveFrame *contents;
@end
