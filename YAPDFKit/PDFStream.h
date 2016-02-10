//
//  PDFStream.h
//  YAPDFKit
//
//  Created by Pim Snel on 10-02-16.
//  Copyright © 2016 Ptenster. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "pdf.h"

// Stream contents in PDFObject
@interface PDFStream : NSObject

@property NSData* rawData;

- (id)initWithData :(NSData*)data;
- (NSString *)getDecompressedDataAsString;

@end
