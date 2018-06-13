//
//  CIFHandler.h
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Parser.h"
#import "TagString.h"

@protocol CIFHandler
-(void)beginData:(const char *)valueText :(size_t)valueTextLen;
-(void)item:(const CIFTag *)tag :(const Lex *)lex;
-(void)beginLoop:(const TagList *)tags;
-(void)loopItem:(const TagList *)tags :(size_t)tagIndex :(const Lex *)lex;
-(void)loopItemTerm;
-(void)endLoop;
@end

@interface NewParser : NSObject
+(void)parse:(NSString*)path :(id<CIFHandler>)handler;
+(void)parseWithFILE:(FILE*)fp :(id<CIFHandler>)handler;
@end

NSArray<NSString*>* StringsFromTagList( const TagList *tags );

