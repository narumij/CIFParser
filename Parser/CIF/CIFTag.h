//
//  CIFTag.h
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/11.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CIFTag : NSObject<NSCopying>
@property NSString *name;
@property(readonly) NSInteger hash;
@end
