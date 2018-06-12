//
//  CIFParser.m
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/10.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import "CIFParser.h"
#import "CIFParserImpl.h"

@implementation CIFParser

+ (CIF *)parseWithFilePath:(NSString*)path error:(NSError**)error
{
    const char *file = [path cStringUsingEncoding:NSUTF8StringEncoding];
    FILE *fp = fopen( file, "r" );
    assert( fp );
    if ( fp == NULL ) {
        // TODO: write error operation
        return nil;
    }
    id result = [self parseWithFilePointer:fp error:error];
    fclose(fp);
    return result;
}

+ (CIF *)parseWithFilePointer:(FILE *)filePtr error:(NSError**)error
{
    CIFParserImpl *impl = [[CIFParserImpl alloc] init];
    CIFLexerWithFILE(filePtr, impl);

    if ( impl.hasError ) {
        if ( error != nil ) {
            *error = [[NSError alloc] init];
        }
        return nil;
    }
    
    return impl.getResult;
}

@end














