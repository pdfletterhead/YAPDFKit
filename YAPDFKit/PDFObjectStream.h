//
//  PDFStream.m
//  YAPDFKit
//
//  Created by Pim Snel on 10-02-16.
//  Copyright © 2016 Lingewoud. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "pdfzlib.h"

// Stream contents in PDFObject
@interface PDFObjectStream : NSObject

@property NSData* rawData;

- (id)initWithData :(NSData*)data;
- (NSString *)getDecompressedDataAsString;

@end
