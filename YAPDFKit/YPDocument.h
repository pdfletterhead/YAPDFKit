//
//  YPDocument.h
//  YAPDFKit
//
//  Created by Aliona on 10.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//  Copyright © 2016-2019 Lingewoud. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YPObject.h"
#import "YPXref.h"
#import "YPPages.h"
#import "YPObjectReference.h"
#import "YPAttribute.h"
#import "Utils.h"

@class YPObject;

@interface YPDocument : NSObject
{
    NSString *_errorMessage;
    NSString *_version;
    //    NSMutableDictionary *_contents;
}

@property NSMutableData* modifiedPDFData;
@property NSMutableArray* updateObjectQueue;
@property NSInteger *lastTrailerOffset;

@property NSMutableDictionary* objects;
@property NSInteger docSize;
@property NSMutableArray* comments;

- (id)initWithData:(NSData*)data;

- (NSString*) version;
- (NSString*) errorMessage;
- (NSString*) getPDFInfo;
- (NSString*) getDocumentCatalog;
- (NSString*) getPDFMetaData;
- (NSDictionary*) getObjectsWithStreams;
- (NSArray*) getAllObjectsWithKey:(NSString *)key;
- (NSArray*) getAllObjectsWithKey:(NSString *)key value:(NSString *)value;
- (YPObject*) getObjectByNumber:(NSString*)number;

- (BOOL)isBinary;
- (id) getInfoForKey:(NSString *)key;
- (id) getInfoForKey:(NSString *)key inObject:(NSString *)objectNumber;

- (NSString *)getObjectNumberForKey:(NSString *)key value:(NSString*)value;
- (NSDictionary*)allObjects;

- (void) addObjectToUpdateQueue:(YPObject *)pdfObject;
- (void) updateDocumentData;
@end
