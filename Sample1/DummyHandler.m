//
//  DummyHandler.m
//  CIFParser
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#import "DummyHandler.h"

@implementation DummyHandler

-(void)beginData:(const CIFLex *)lex
{
    NSLog(@"begin data ** %s",lex->text);
}

-(void)item:(const CIFTag *)tag :(const CIFLex *)lex
{
    NSLog( @"item ( %s : %s )", tag->text, lex->text );
}

-(void)beginLoop:(const CIFLoopTag *)tags {
    NSLog(@"begin loop %@",StringsFromTagList(tags));
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

@end





