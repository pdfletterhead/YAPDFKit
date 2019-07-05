//
//  PDFStream.m
//  YAPDFKit
//
//  Created by Pim Snel on 10-02-16.
//  Copyright © 2016-2019 Lingewoud. All rights reserved.
//  Modify by Liuqiang on 25-03-16.

#import "YPObjectStream.h"

@implementation YPObjectStream

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

- (id)initWithData:(NSData*)data andFilter:(NSString*)filter
{
    if (self = [super init]) {
        
        if([filter isEqualToString:@"FlateDecode"])
        {
            _rawData = inflateStringData(data);
        }
        else if([filter isEqualToString:@"None"])
        {
            _rawData = data;
        }
        else
        {
            _rawData = data;
        }
        
        return self;
    }
    
    return nil;
}




- (NSData*) getRawData
{
    return _rawData;
}

- (unsigned long) length
{
    return [_rawData length];
}

-(NSData*)getDecompressedData:(NSArray*)filter
{
    //filter may be array
    NSString *flateDecode = filter;
    if([flateDecode isEqualToString:@"FlateDecode"])
    {
        return deflateData(_rawData);
    }
    else if([flateDecode isEqualToString:@"None"])
    {
        return _rawData;
    }
    else
    {
        return _rawData;
    }
    return nil;
}


- (NSString *)getDecompressedDataAsString:(NSString*)filter
{
    if([filter isEqualToString:@"FlateDecode"])
    {
        return deflateDataAsString(_rawData);
    }
    else if([filter isEqualToString:@"None"])
    {
        NSString* plain = [[NSString alloc] initWithData:_rawData encoding:NSUTF8StringEncoding];
        
        return plain;
    }
    else
    {
        NSString* plain = [[NSString alloc] initWithData:_rawData encoding:NSUTF8StringEncoding];
        
        return plain;
    }
    return nil;
}

@end
