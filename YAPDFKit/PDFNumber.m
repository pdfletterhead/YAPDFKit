//
//  PDFNumber.m
//  YAPDFKit
//
//  Created by Aliona on 27.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import "PDFNumber.h"

@implementation PDFNumber
@synthesize real, intValue, realValue;
- (void) initWithInt:(NSInteger)i
{
    intValue = (int)i;
    real = NO;
}
- (void) initWithReal:(float)f
{
    realValue = f;
    real = YES;
}
- (NSString *)description
{
    NSString *desc = @"";
    if (real) {
        desc = [NSString stringWithFormat:@"%f",realValue];
    } else {
        desc = [NSString stringWithFormat:@"%d",intValue];
    }
    return desc;
}
@end
