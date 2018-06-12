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
-(void)itemTag:(const char *)tagText
              :(size_t)tagLen
              :(CIFLexemeTag)valueType
              :(const char *)valueText
              :(size_t)valueTextLen
{
    NSLog(@"item ( %s : %s )",tagText,valueText);
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

-(void)loopItem:(BOOL)isTerm
               :(const char *)tagText
               :(size_t)tagLen
               :(CIFLexemeTag)valueType
               :(const char *)valueText
               :(size_t)valueTextLen
{
    NSLog(@"loop item [ %s : %s ]",tagText,valueText);
}
-(void)endLoop
{
}
@end

void HandleBeginData( void *ctx, const char* text, size_t len )
{
    [(__bridge id<CIFHandler>)ctx beginData:text :len];
}

void HandleItem( void *ctx, const char* itemTag, size_t itemLen, CIFLexemeTag tag, const char* text, size_t len )
{
//    [(__bridge id<CIFHandler>)ctx itemTag:itemTag :itemLen :tag :text :len];
}

void HandleBeginLoop( void *ctx, TagList *tags )
{
    [(__bridge id<CIFHandler>)ctx beginLoop:tags];
}

void HandleLoopItem( void *ctx, int isTerm, const char* itemTag, size_t itemLen, CIFLexemeTag tag, const char* text, size_t len )
{
    [(__bridge id<CIFHandler>)ctx loopItem:isTerm :itemTag :itemLen :tag :text :len];
}

void HandleEndLoop( void *ctx )
{
    // 必ず呼ぶことを保証できてない
    [(__bridge id<CIFHandler>)ctx endLoop];
}

void HandleEndData( void *ctx )
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


