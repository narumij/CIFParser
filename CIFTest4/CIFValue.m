//
//  CIFValue.m
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/10.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import "CIFValue.h"
#import "CIFLexer.h"

NSString *hoge( CIFValueType type ) {
    switch (type) {
        case CIFValueFloat:
            return @"<F>";
            break;
        case CIFValueInteger:
            return @"<I>";
            break;
        case CIFValueString:
            return @"<S>";
            break;
        case CIFValueText:
            return @"<T>";
            break;
        case CIFValueInapplicable:
            return @"<.>";
            break;
        case CIFValueUknown:
            return @"<?>";
            break;
        default:
            break;
    }
    return @"";
}

@implementation CIFValue

- (NSInteger)hash {
    if ( [self.contents isKindOfClass:[NSString class]] ) {
        return [(NSString*)self.contents hash];
    }
    return (NSInteger)self.type;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@%@",hoge(self.type),self.contents];
}

@end

@implementation CIFValue(acceptScanner)

+(instancetype)valueWithTag:(CIFLexemeTag)tag bytes:(const char*)bytes length:(size_t)length
{
    NSString *str = [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
    return [self valueWithText:str tag:tag];
}

+(instancetype)valueWithText:(NSString*)text tag:(CIFLexemeTag)tag
{
    CIFValue *value = [[CIFValue alloc] init];
    switch (tag) {
        case LNumericFloat:
            value.type = CIFValueFloat;
            break;
        case LNumericInteger:
            value.type = CIFValueInteger;
            break;
        case LUnquoteString1:
        case LUnquoteString2:
        case LQuoteString:
            value.type = CIFValueString;
            break;
        case LTextField:
            value.type = CIFValueText;
            break;
        case LDot:
            value.type = CIFValueInapplicable;
            break;
        default:
            value.type = CIFValueUknown;
            break;
    }
    value.contents = text;
    return value;
}

@end
