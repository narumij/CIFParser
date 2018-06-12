//
//  CIFParseRule.h
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/11.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIFLexer.h"

typedef enum ResultCode {
    UnexpeceteToken,
    Continue,
    Complete,
    ShouldBack,
} ResultCode;

@protocol CIFLeafRule;

@protocol CIFParseRule <NSObject>
@property id<CIFLeafRule> current;
-(ResultCode)acceptScanner:(void *)scanner text:(NSString*)text tag:(CIFLexemeTag)tag;
@end

@protocol CIFLeafRule <NSObject,CIFParseRule>
- (instancetype)initWithString:(NSString*)str tag:(CIFLexemeTag)tag;
@property id contents;
@end

NSString *PositionString( void* scanner );

BOOL CIFLexemeTagIsValue(CIFLexemeTag tag);

//NSArray<NSNumber*>* ValueTags(void);

