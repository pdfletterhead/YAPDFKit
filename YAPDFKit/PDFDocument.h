//
//  PDFDocument.h
//  YAPDFKit
//
//  Created by Aliona on 10.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFDocument : NSObject
{
    NSString *_errorMessage;
    NSString *_version;
    NSMutableDictionary *_contents;
}
@property NSMutableDictionary* contents;

- (id)initWithData:(NSData*)data;
- (NSString*)version;
- (NSString*)errorMessage;

- (id) getInfoForKey:(NSString *)key;
- (id) getInfoForKey:(NSString *)key inObject:(NSString *)objectNumber;
- (NSString *)getObjectNumberForKey:(NSString *)key :(NSString*)value;

@end
