//
//  PDFStream.m
//  YAPDFKit
//
//  Created by Pim Snel on 10-02-16.
//  Copyright © 2016 Lingewoud. All rights reserved.
//

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
            _rawData = inflateStringToData(data);
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
        else
        {
            _rawData = [string dataUsingEncoding:NSUTF8StringEncoding];
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

-(NSData*)getDecompressedData:(NSString*)filter
{
    if([filter isEqualToString:@"FlateDecode"])
    {
        //NSLog(@"raw: %@",_rawData);
        return deflateData(_rawData);
    }
    else if([filter isEqualToString:@"None"])
    {
        return _rawData;
        //NSString* plain = [[NSString alloc] initWithData:_rawData encoding:NSUTF8StringEncoding];
        
        //return plain;
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
        //NSLog(@"raw: %@",_rawData);
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
