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
-(void)itemTag:(const char *)tagText :(size_t)tagLen :(CIFLexemeTag)valueType :(const char *)valueText :(size_t)valueTextLen;
-(void)beginLoop:(TagList *)tags;
-(void)loopItem:(BOOL)isTerm :(const char *)tagText :(size_t)tagLen :(CIFLexemeTag)valueType :(const char *)valueText :(size_t)valueTextLen;
-(void)endLoop;
@end

@interface DummyHandler : NSObject<CIFHandler>
@end

Handlers prepareHandlers( id<CIFHandler> handler );

@interface NewParser : NSObject
+(void)parse:(NSString*)path :(id<CIFHandler>)handler;
@end

NSArray<NSString*>* StringsFromTagList( TagList *tags );
