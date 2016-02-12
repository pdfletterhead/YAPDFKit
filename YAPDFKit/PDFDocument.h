//
//  PDFDocument.h
//  YAPDFKit
//
//  Created by Aliona on 10.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PDFObject;

@interface PDFDocument : NSObject
{
    NSString *_errorMessage;
    NSString *_version;
    //    NSMutableDictionary *_contents;
}

@property NSMutableDictionary* objects;
@property NSInteger docSize;
@property NSMutableArray* comments;

- (id)initWithData:(NSData*)data;

- (NSString*)version;
- (NSString*)errorMessage;
- (NSString*)getPDFInfo;
- (NSString *)getDocumentCatalog;
- (NSString*)getPDFMetaData;
- (NSDictionary*)getObjectsWithStreams;
- (NSArray*) getAllObjectsWithKey:(NSString *)key;
- (NSArray*)getAllObjectsWithKey:(NSString *)key value:(NSString *)value;
- (PDFObject*) getObjectByNumber:(NSString*)number;

- (BOOL)isBinary;

- (id) getInfoForKey:(NSString *)key;
- (id) getInfoForKey:(NSString *)key inObject:(NSString *)objectNumber;
- (NSString *)getObjectNumberForKey:(NSString *)key value:(NSString*)value;

- (NSDictionary*)allObjects;

@end
