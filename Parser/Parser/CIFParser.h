//
//  CIFParser.h
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/10.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CIF;

@interface CIFParser : NSObject
+ (CIF *)parseWithFilePath:(NSString*)path error:(NSError**)error;
+ (CIF *)parseWithFilePointer:(FILE *)filePtr error:(NSError **)error;
@end

