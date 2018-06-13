//
//  ViewController.m
//  CIFTest3
//
//  Created by Jun Narumi on 2018/06/13.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

#import "ViewController.h"

#import <CIFParser/CIFParser.h>
#import "DummyHandler.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.

    [self test];
}

- (void)test {
    NSLog(@"start");
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"1wns" ofType:@"cif"];
    DummyHandler *h = [[DummyHandler alloc] init];
    [CIFParser parse:path :h];
    NSLog(@"done");
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end


