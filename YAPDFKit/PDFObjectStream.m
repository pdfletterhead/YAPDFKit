//
//  PDFStream.m
//  YAPDFKit
//
//  Created by Pim Snel on 10-02-16.
//  Copyright © 2016 Lingewoud. All rights reserved.
//

#import "PDFObjectStream.h"

@implementation PDFObjectStream

- (id)initWithData :(NSData*)data
{
    if (self = [super init]) {
    
        if(data){

            _rawData = data;
        }
        
        return self;
    }
    
    return nil;
}

- (NSString *)getDecompressedDataAsString
{
    NSString * decompressedString = deflateData(_rawData);
    return decompressedString;
}

@end
