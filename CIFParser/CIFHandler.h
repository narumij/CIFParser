//
//  CIFHandler.h
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CIFLexer.h"
#import "CIFTag.h"
#import "CIFLoopTag.h"

@protocol CIFHandler
-(void)beginData:(const CIFLex *)lex;
-(void)item:(const CIFTag *)tag :(const CIFLex *)lex;
-(void)beginLoop:(const CIFLoopTag *)tags;
-(void)loopItem:(const CIFLoopTag *)tags :(size_t)tagIndex :(const CIFLex *)lex;
-(void)loopItemTerm;
-(void)endLoop;
@end

@interface CIFParser : NSObject
+(void)parse:(NSString*)path :(id<CIFHandler>)handler;
+(void)parseWithFILE:(FILE*)fp :(id<CIFHandler>)handler;
@end

NSArray<NSString*>* StringsFromTagList( const CIFLoopTag *tags );

