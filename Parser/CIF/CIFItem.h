//
//  CIFItem.h
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/10.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIFTag.h"
#import "CIFValue.h"

@interface CIFItem : NSObject
@property CIFTag *tag;
@property CIFValue *value;
@end
