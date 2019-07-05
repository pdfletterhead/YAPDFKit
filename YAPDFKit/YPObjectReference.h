//
//  YPObjectReference.h
//  YAPDFKit
//
//  Created by Aliona on 24.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//  Copyright © 2016-2019 Lingewoud. All rights reserved.

@class YPObject;

@interface YPObjectReference : NSObject
{
    NSInteger firstNumber;
    NSInteger secondNumber;
}

@property YPObject* link;

- (id)initWithNum :(NSString *)first :(NSString *)second;
- (id)initWithReferenceString:(NSString *)string;
- (NSString *)getReferenceNumber;
@end
