//
//  YPObjectReference.h
//  YAPDFKit
//
//  Created by Aliona on 24.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

@class YPObject;

@interface YPObjectReference : NSObject
{
    NSInteger firstNumber;
    NSInteger secondNumber;
}

@property YPObject* link;

- (id)initWithNum :(NSString *)first :(NSString *)second;
- (NSString *)getReferenceNumber;
@end
