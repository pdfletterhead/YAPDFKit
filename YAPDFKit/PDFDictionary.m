//
//  PDFDictionary.m
//  YAPDFKit
//
//  Created by Aliona on 26.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import "PDFDictionary.h"
#import "PDFObjectReference.h"

@implementation PDFDictionary

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
        else if([value isKindOfClass:[PDFObjectReference class]]) {
            blockString = (NSMutableString*)[blockString stringByAppendingFormat:@"%@ ",value];
        }
        else if([value isKindOfClass:[NSNumber class]]) {
            blockString = (NSMutableString*)[blockString stringByAppendingFormat:@"%@ ",value];
        }

        NSLog(@"dval: %@ :%@", value, [value class]);
    }
    
    blockString = (NSMutableString*)[blockString stringByAppendingString:@">>\n"];
    
    return (NSString*)blockString;
}

@end
