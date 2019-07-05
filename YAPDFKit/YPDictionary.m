//
//  YPDictionary.m
//  YAPDFKit
//
//  Created by Aliona on 26.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//  Copyright © 2016-2019 Lingewoud. All rights reserved.

#import "YPDictionary.h"
#import "YPObjectReference.h"

@implementation YPDictionary

@synthesize nsdict;

-(id)initWithDictionary:(NSDictionary*) dict
{
    if (self = [super init]) {
        
        //self = [self initWithDictionary:dict];
        
        if(dict){
            
            nsdict = [NSMutableDictionary dictionaryWithDictionary:dict];
        }
        
        return self;
    }
    
    return nil;
}

-(id)objectForKey:(id)aKey
{
    return nsdict[aKey];
}

-(void)setObject:(id)anObject forKey:(id)aKey
{
    nsdict[aKey] = anObject;
}

-(void)removeObjectForKey:(id)aKey
{
    [nsdict removeObjectForKey:aKey];
}

-(id)description
{
    return nsdict;
}

-(NSString*) stringValue
{
    NSMutableString* blockString = (NSMutableString*)@"";
    blockString = (NSMutableString*)[blockString stringByAppendingString:@"<< "];
    
    for (NSString* key in nsdict ) {
        id value = [nsdict objectForKey:key];
        
        blockString = (NSMutableString*)[blockString stringByAppendingFormat:@"/%@ ",key];
        
        if ([value isKindOfClass:[NSString class]]) {
            
            blockString = (NSMutableString*)[blockString stringByAppendingFormat:@"/%@ ",value];
        }
        else if([value isKindOfClass:[YPObjectReference class]]) {
            blockString = (NSMutableString*)[blockString stringByAppendingFormat:@"%@ ",value];
        }
        else if([value isKindOfClass:[NSNumber class]]) {
            blockString = (NSMutableString*)[blockString stringByAppendingFormat:@"%@ ",value];
        }
    }
    
    blockString = (NSMutableString*)[blockString stringByAppendingString:@">>\n"];
    
    return (NSString*)blockString;
}

@end
