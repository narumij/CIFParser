//
//  CIFHandler.h
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CIFLex.h"
#import "CIFTag.h"
#import "CIFLoopTag.h"

@protocol CIFHandler
-(void)beginData:(const CIFLex *_Nonnull)lex;
-(void)item:(const CIFTag *_Nonnull)tag :(const CIFLex *_Nonnull)lex;
-(void)beginLoop:(const CIFLoopTag *_Nonnull)tags;
-(void)loopItem:(const CIFLoopTag *_Nonnull)tags :(size_t)tagIndex :(const CIFLex *_Nonnull)lex;
-(void)loopItemTerm;
-(void)endLoop;
@end

@interface CIFParser : NSObject
+(void)parse:(NSString*_Nonnull)path :(id<CIFHandler>_Nonnull)handler;
+(void)parseWithFILE:(FILE*_Nonnull)fp :(id<CIFHandler>_Nonnull)handler;
@end

//NSArray<NSString*>* __nonnull NSStringsFromLoopTag( const CIFLoopTag * _Nonnull tags );

