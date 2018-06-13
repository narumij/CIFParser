//
//  DummyHandler.m
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#import "DummyHandler.h"

#import "Parser.h"
#import "TagString.h"

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





