//
//  CIFHandler.m
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#import "CIFHandler.h"
#include "Handlers.h"
#include "Parser.h"
#import "CIFTag.h"

static void HandleBeginData( void *ctx, const CIFLex *lex )
{
    [(__bridge id<CIFHandler>)ctx beginData:lex];
}

static void HandleItem( void *ctx, const CIFTag *tag, CIFLex *lex )
{
    [(__bridge id<CIFHandler>)ctx item:tag :lex];
}

static void HandleBeginLoop( void *ctx, CIFLoopTag *tags )
{
    [(__bridge id<CIFHandler>)ctx beginLoop:tags];
}

static void HandleLoopItem( void *ctx, CIFLoopTag *tags, size_t tagIndex, CIFLex *lex )
{
    [(__bridge id<CIFHandler>)ctx loopItem:tags :tagIndex :lex];
}

static void HandleLoopItemTerm( void *ctx )
{
    [(__bridge id<CIFHandler>)ctx loopItemTerm];
}

static void HandleEndLoop( void *ctx )
{
    // 必ず呼ぶことを保証できてない
    [(__bridge id<CIFHandler>)ctx endLoop];
}

static void HandleEndData( void *ctx )
{
    // 必ず呼ぶことを保証できてない
    NSLog(@"end data");
}

static Handlers prepareHandlers( id<CIFHandler> handler ) {
    Handlers h;
    h.ctx = (__bridge void *)handler;
    h.item = HandleItem;
    h.beginData = HandleBeginData;
    h.beginLoop = HandleBeginLoop;
    h.loopItem = HandleLoopItem;
    h.loopItemTerm = HandleLoopItemTerm;
    h.endLoop = HandleEndLoop;
    h.endData = HandleEndData;
    return h;
}

@implementation CIFParser

+(void)parse:(NSString*)path :(id<CIFHandler>)handler
{
    FILE *fp = fopen( path.UTF8String, "r" );
    [self parseWithFILE:fp :handler];
    fclose(fp);

}

+(void)parseWithFILE:(FILE*)fp :(id<CIFHandler>)handler
{
    Handlers hh = prepareHandlers(handler);
    Parse(fp, &hh);
}

@end



NSArray<NSString*>* StringsFromTagList( const CIFLoopTag *tags ) {
    NSMutableArray *mArray = @[].mutableCopy;
    for ( int i = 0; i < tags->count; ++i) {
        NSString *str = [NSString stringWithUTF8String:tags->list[i].text];
        [mArray addObject:str];
    }
    return mArray;
}



