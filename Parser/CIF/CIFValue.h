//
//  CIFValue.h
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/10.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum CIFValueType CIFValueType;
typedef enum CIFLexemeTag CIFLexemeTag;

typedef enum CIFValueType {
    CIFValueFloat,
    CIFValueInteger,
    CIFValueString,
    CIFValueText,
    CIFValueInapplicable,
    CIFValueUknown,
    CIFValueTypeCount
} CIFValueType;

@interface CIFValue : NSObject
@property(assign) CIFValueType type;
@property id contents;
@property(readonly) NSInteger hash;
@end

@interface CIFValue(acceptScanner)
+(instancetype)valueWithTag:(CIFLexemeTag)tag bytes:(const char*)bytes length:(size_t)length;
+(instancetype)valueWithText:(NSString*)text tag:(CIFLexemeTag)tag;
@end

