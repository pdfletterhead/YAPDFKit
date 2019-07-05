//
//  PDFStream.m
//  YAPDFKit
//
//  Created by Pim Snel on 10-02-16.
//  Copyright © 2016-2019 Lingewoud. All rights reserved.

#import <Foundation/Foundation.h>
#include "pdfzlib.h"

// Stream contents in YPObject
@interface YPObjectStream : NSObject

@property NSData* rawData;

- (id)initWithData :(NSData*)data;
- (id)initWithData:(NSData*)data andFilter:(NSString*)filter;
- (NSData *)getDecompressedData:(NSString*)filter;
- (NSString *)getDecompressedDataAsString:(NSString*)filter;
- (unsigned long) length;
- (NSData*) getRawData;
@end
