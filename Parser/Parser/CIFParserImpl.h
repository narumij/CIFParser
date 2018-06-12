//
//  CIFParserImpl.h
//  CIFReader
//
//  Created by Jun Narumi on 2017/12/11.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIFLexer.h"
#import "CIF.h"

@interface CIFParserImpl : NSObject<CIFParserProtocol>

@property(assign) BOOL hasError;

-(void)nextLexeme:(void *)scanner
              tag:(CIFLexemeTag)tag
             text:(NSString*)text;

-(CIF*)getResult;

@end


