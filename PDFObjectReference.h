//
//  PDFObjectReference.h
//  Parser
//
//  Created by Aliona on 24.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

@class PDFObject;

@interface PDFObjectReference : NSObject
{
    NSInteger firstNumber;
    NSInteger secondNumber;
}

@property PDFObject* link;

- (id)initWithNum :(NSString *)first :(NSString *)second;
- (NSString *)getReferenceNumber;
@end