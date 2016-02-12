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
@property NSInteger docSize;
@property NSMutableArray* comments;

- (id)initWithData:(NSData*)data;

- (NSString*)version;
- (NSString*)errorMessage;
- (NSString*)getPDFInfo;
- (NSString*)getPDFMetaData;
- (NSDictionary*)getObjectWithStreams;
- (BOOL)isBinary;

- (id) getInfoForKey:(NSString *)key;
- (id) getInfoForKey:(NSString *)key inObject:(NSString *)objectNumber;
- (NSString *)getObjectNumberForKey:(NSString *)key :(NSString*)value;

- (NSDictionary*)allObjects;

@end
