//
//  YPObject.h
//  YAPDFKit
//
//  Created by Aliona on 19.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPObjectStream.h"
#import "YPDictionary.h"

@class YPDocument;

@interface YPObject : NSObject

@property NSInteger firstNumber;
@property NSInteger secondNumber;


@property YPObjectStream *stream;
@property YPDictionary *dictionary;


@property id value;

@property NSMutableDictionary *references;

- (id)initWithData :(NSData*)d first:(NSInteger*)first second:(NSInteger*)second;
- (NSString *)getObjectNumber;
- (id)getValueByName:(NSString *)n;
- (NSArray*)getContents;
- (YPObjectStream *)getStreamObject;
- (id)getObjectForKeyInDict:(NSString*)key;
- (NSData*) createObjectDataBlock;
- (void) setStreamContentsWithData:(NSData*)data;
- (void)setStreamContentsWithString:(NSString*)string;
- (NSString*)getUncompressedStreamContents;
- (NSData*)getUncompressedStreamContentsAsData;

@end
