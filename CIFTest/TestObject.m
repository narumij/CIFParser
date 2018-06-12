//
//  TestObject.m
//  CIFTest
//
//  Created by Jun Narumi on 2017/12/11.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import "TestObject.h"

#import <CIFReader/CIFReader.h>

@interface Dummy : NSObject<CIFParserProtocol>

-(void)nextLexeme:(void *)scanner
              tag:(CIFLexemeTag)tag
             text:(NSString*)text;

@end

@implementation TestObject

+ (void)test {
    CFTimeInterval start = CFAbsoluteTimeGetCurrent();
//        CIFParser *parser = [[CIFParser alloc] init];
//        NSString *path = @"/Users/jun/Xcode/Frameworks/CIFReader/CIFLexer/TestFiles/CaCuO2.cif";
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"CaCuO2" ofType:@"cif"];
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"1gof" ofType:@"cif"];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"3j3y" ofType:@"cif"];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"cif_core" ofType:@"dic"];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"cif_mm" ofType:@"dic"];

    id result = [CIFParser parseWithFilePath:path error:NULL];

    CFTimeInterval end = CFAbsoluteTimeGetCurrent();
    NSLog( @"parse result = %@", result );
    NSLog( @"%f", end - start );
}

+ (void)test2 {
    CFTimeInterval start = CFAbsoluteTimeGetCurrent();
    //        CIFParser *parser = [[CIFParser alloc] init];
    //        NSString *path = @"/Users/jun/Xcode/Frameworks/CIFReader/CIFLexer/TestFiles/CaCuO2.cif";
    //        NSString *path = [[NSBundle mainBundle] pathForResource:@"CaCuO2" ofType:@"cif"];
    //        NSString *path = [[NSBundle mainBundle] pathForResource:@"1gof" ofType:@"cif"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"3j3y" ofType:@"cif"];
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"cif_core" ofType:@"dic"];
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"cif_mm" ofType:@"dic"];

//    id result = [CIFParser parseWithFilePath:path error:NULL];
    id dummy = [[Dummy alloc] init];

    const char *file = [path cStringUsingEncoding:NSUTF8StringEncoding];
    FILE *fp = fopen( file, "r" );
    assert( fp );
    if ( fp == NULL ) {
        return;
    }
    CIFLexerWithFILE( fp, dummy);
    fclose(fp);

    CFTimeInterval end = CFAbsoluteTimeGetCurrent();
//    NSLog( @"parse result = %@", result );
    NSLog( @"%f", end - start );
}

@end



@implementation Dummy

-(void)nextLexeme:(void *)scanner
              tag:(CIFLexemeTag)tag
        textBytes:(const char*)textBytes
       textLength:(size_t)textLength
{
}

@end
