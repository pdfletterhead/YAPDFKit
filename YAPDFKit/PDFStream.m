//
//  PDFStream.m
//  YAPDFKit
//
//  Created by Pim Snel on 10-02-16.
//  Copyright © 2016 Lingewoud. All rights reserved.
//

#import "PDFStream.h"

@implementation PDFStream

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
    
    //printf("\n\nB--------\n");
    
    //dumpCharArray(data.bytes, data.length);
    NSString * decompressedString = convertStream(_rawData);
//    NSLog(@"string: %@", decompressedString);
    //printf("\nE--------\n\n");
    return decompressedString;
}




@end
