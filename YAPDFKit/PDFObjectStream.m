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

- (id)initWithString:(NSString*)string andFilter:(NSString*)filter
{
    if (self = [super init]) {
        
        if([filter isEqualToString:@"FlateDecode"])
        {
            _rawData = inflateStringToData(string);
        }
        else if([filter isEqualToString:@"None"])
        {
            _rawData = [string dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        return self;
    }
    
    return nil;
}

- (unsigned long) length
{
    return [_rawData length];
}

- (NSString *)getDecompressedDataAsString:(NSString*)filter
{
    if([filter isEqualToString:@"FlateDecode"])
    {
        return deflateData(_rawData);
    }
    else if([filter isEqualToString:@"None"])
    {
        NSString* plain = [[NSString alloc] initWithData:_rawData encoding:NSUTF8StringEncoding];
        
        return plain;
    }
    
    return nil;
}

@end
