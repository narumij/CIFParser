//
//  DummyHandler.m
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#import "DummyHandler.h"

NSArray<NSString*>* NSStringsFromLoopTag( const CIFLoopTag *tags ) {
    NSMutableArray *mArray = @[].mutableCopy;
    for ( int i = 0; i < tags->count; ++i) {
        NSString *str = [NSString stringWithUTF8String:tags->list[i].text];
        [mArray addObject:str];
    }
    return mArray;
}

@interface DummyHandler()
-(void)beginData:(const CIFLex *)lex;
-(void)item:(const CIFTag *)tag :(const CIFLex *)lex;
-(void)beginLoop:(const CIFLoopTag *)tags;
-(void)loopItem:(const CIFLoopTag *)tags :(size_t)tagIndex :(const CIFLex *)lex;
@end

void BeginData(void *ctx, CIFLex lex)
{
    [(__bridge DummyHandler *)ctx beginData:&lex];
}

void Item(void *ctx, CIFTag tag, CIFLex lex)
{
    [(__bridge DummyHandler *)ctx item:&tag :&lex];
}

void BeginLoop(void *ctx, CIFLoopTag tags)
{
    [(__bridge DummyHandler *)ctx beginLoop:&tags];
}

void LoopItem(void *ctx, CIFLoopTag tags, size_t tagIndex, CIFLex lex)
{
    [(__bridge DummyHandler *)ctx loopItem:&tags :tagIndex :&lex];
}

void DoNothing(void *ctx) {}

@implementation DummyHandler

-(void)beginData:(const CIFLex *)lex
{
    NSLog(@"begin data ** %s",lex->text);
}

-(void)item:(const CIFTag *)tag :(const CIFLex *)lex
{
    NSLog( @"item ( %s : %s )", tag->text, lex->text );
}

-(void)beginLoop:(const CIFLoopTag *)tags
{
    NSLog(@"begin loop %@",NSStringsFromLoopTag(tags));
}

-(void)loopItem:(const CIFLoopTag *)tags
               :(size_t)tagIndex
               :(const CIFLex *)lex
{
    NSLog(@"loop item [ %s : %s ]",tags->list[tagIndex].text,lex->text);
}

-(void)loopItemTerm
{
}

-(void)endLoop
{
}

-(CIFRawHandlers)parserHandler
{
    CIFRawHandlers h;
    h.ctx = (__bridge void *)self;
    h.beginData = BeginData;
    h.item = Item;
    h.beginLoop = BeginLoop;
    h.loopItem = LoopItem;
    h.loopItemTerm = DoNothing;
    h.endLoop = DoNothing;
    h.endData = DoNothing;
    return h;
}

@end





