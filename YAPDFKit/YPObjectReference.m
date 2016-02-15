//
//  YPObjectReference.m
//  YAPDFKit
//
//  Created by Aliona on 24.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import "YPObjectReference.h"
#import "YPObject.h"

@implementation YPObjectReference

@synthesize link;

- (id)initWithNum :(NSString *)first :(NSString *)second
{
    if (self = [super init]) {
        firstNumber = [first integerValue];
        secondNumber = [second integerValue];
        return self;
    }
    return nil;
}
- (NSString *)description
{
    NSString *desc = @"";
    NSString *first = [NSString stringWithFormat:@"%ld",(long)firstNumber];
    NSString *second = [NSString stringWithFormat:@"%ld",(long)secondNumber];
    desc = [desc stringByAppendingString:first];
    desc = [desc stringByAppendingString:@" "];
    desc = [desc stringByAppendingString:second];
    desc = [desc stringByAppendingString:@" R"];
    
    return desc;
}

- (NSString *)getReferenceNumber
{
    NSString *num = @"";
    
    NSString *first = [NSString stringWithFormat:@"%ld",(long)firstNumber];
    NSString *second = [NSString stringWithFormat:@"%ld",(long)secondNumber];
    num = [num stringByAppendingString:first];
    num = [num stringByAppendingString:@" "];
    num = [num stringByAppendingString:second];
    
    return num;
}

@end
