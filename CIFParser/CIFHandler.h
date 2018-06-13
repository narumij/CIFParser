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
-(void)beginLoop:(const CIFLoopTag *)tags;
-(void)loopItem:(const CIFLoopTag *)tags :(size_t)tagIndex :(const Lex *)lex;
-(void)loopItemTerm;
-(void)endLoop;
@end

@interface NewParser : NSObject
+(void)parse:(NSString*)path :(id<CIFHandler>)handler;
+(void)parseWithFILE:(FILE*)fp :(id<CIFHandler>)handler;
@end

NSArray<NSString*>* StringsFromTagList( const CIFLoopTag *tags );

