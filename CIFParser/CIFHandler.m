//
//  CIFHandler.m
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#import "CIFHandler.h"

@implementation DummyHandler
-(void)beginData:(const char *)valueText :(size_t)valueTextLen
{
    NSLog(@"begin data ** %s",valueText);
}
-(void)item:(const TagText *)tag :(const Lex *)lex
{
    NSLog( @"item ( %s : %s )", tag->text, lex->text );
}
NSArray<NSString*>* StringsFromTagList( TagList *tags ) {
    NSMutableArray *mArray = @[].mutableCopy;
    for ( int i = 0; i < tags->count; ++i) {
        NSString *str = [NSString stringWithUTF8String:tags->list[i].text];
        [mArray addObject:str];
    }
    return mArray;
}
-(void)beginLoop:(TagList *)tags {
    NSLog(@"begin loop %@",StringsFromTagList(tags));
}
-(void)loopItem:(TagList *)tags
               :(size_t)tagIndex
               :(const Lex *)lex
{
    NSLog(@"loop item [ %zd : %s ]",tagIndex,lex->text);
}
-(void)loopItemTerm
{
}
-(void)endLoop
{
}
@end

static void HandleBeginData( void *ctx, const char* text, size_t len )
{
    [(__bridge id<CIFHandler>)ctx beginData:text :len];
}

static void HandleItem( void *ctx, const TagText *tag, Lex *lex )
{
    [(__bridge id<CIFHandler>)ctx item:tag :lex];
}

static void HandleBeginLoop( void *ctx, TagList *tags )
{
    [(__bridge id<CIFHandler>)ctx beginLoop:tags];
}

static void HandleLoopItem( void *ctx, TagList *tags, size_t tagIndex, Lex *lex )
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

Handlers prepareHandlers( id<CIFHandler> handler ) {
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

@implementation NewParser

+(void)parse:(NSString*)path :(id<CIFHandler>)handler
{
    FILE *fp = fopen( path.UTF8String, "r" );
    Handlers hh = prepareHandlers(handler);
    Parse(fp, &hh);
    fclose(fp);

}

@end


