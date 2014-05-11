//
//  PDFDocument.h
//  Parser
//
//  Created by Aliona on 10.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFDocument : NSObject
{
    NSString *_errorMessage;
    NSString *_version;
}

- (id)initWithData:(NSData*)data;
- (NSString*)version;
- (NSString*)errorMessage;

@end
