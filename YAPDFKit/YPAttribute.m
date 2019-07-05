//
//  YPAttribute.m
//  YAPDFKit
//
//  Created by Pim Snel on 16-02-16.
//  Copyright © 2016-2019 Lingewoud. All rights reserved.
//

#import "YPAttribute.h"

@implementation YPAttribute
@synthesize attributeAsString, attributeType;

- (id)initWithString:(NSString*)string
{
    if (self = [super init]) {
        
        attributeAsString = string;
        attributeType = [self determineAttributeType:string];
        
        return self;
    }
    
    return nil;
}

- (NSString*)determineAttributeType:(NSString*)string
{
    if([string isKindOfClass:[NSString class]])
    {
        
        const char *cstring = [string UTF8String];
        size_t len = strlen(cstring) + 1;
        
        char charString[len];
        memcpy(charString, cstring, len);
        
        //ISNUMBER
        if(charString[0] == '+' || charString[0] == '-' || isdigit(charString[0]))
        {
            
        }
        
        //ISREFERENCE
        if(isdigit(charString[0]))
        {
            if([self isObjectReference:string])
            {
                return @"reference";
            }
        }
        
        //ISDICT
        if(charString[0]=='<')
        {
            
        }
        
        //ISARRAY
        if(charString[0]=='[')
        {
            
        }
        
        //ISSTRING
        if(charString[0]=='(')
        {
            
        }
        
        //ISNAME
        if(charString[0]=='/')
        {
            
        }
        
        //ISBOOL
        if(charString[0]=='f' || charString[0]=='t')
        {
            
        }
        
        //ISBINARYSTRING
        
        
        return @"unknown";
    }
    else
    {
        return @"unknown";
    }
}

- (BOOL)isObjectReference:(NSString*)string
{
    NSArray *chunks = [string componentsSeparatedByString: @" "];
    if([chunks count] == 3)
    {
        if([chunks[0] intValue]> 0 && [chunks[1] intValue] > 0 && [chunks[2] isEqualToString: @"R"])
        {
            return YES;
        }
    }
    return NO;
}

@end
