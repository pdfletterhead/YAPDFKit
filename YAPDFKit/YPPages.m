//
//  YPPages.m
//  YAPDFKit
//
//  Created by Aliona on 28.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//  Copyright © 2016-2019 Lingewoud. All rights reserved.

#import "YPPages.h"
#import "YPDictionary.h"
#import "YPObject.h"
#import "YPObjectReference.h"

@implementation YPPages
{
    YPDocument* document;
}

@synthesize pageInfoObjectNum;

- (id)initWithDocument:(YPDocument *)d
{
    if (self = [super init]) {
        document = d;
    }
    return self;
}

/*
- (NSString *)getDocumentCatalog
{
    NSString *catalogNum = [document getObjectNumberForKey:@"Type":@"Catalog"];
    return catalogNum;
}
*/

- (void)getPageObjectNum
{
    NSString *catalogNum = [document getDocumentCatalog];
    YPObjectReference *pageObjRef = [document getInfoForKey:@"Pages" inObject:catalogNum];
    pageInfoObjectNum = [pageObjRef getReferenceNumber];
}

- (int)getPageCount
{
    [self getPageObjectNum];
    NSString* pageCount = [document getInfoForKey:@"Count" inObject:pageInfoObjectNum];
    return [pageCount intValue];
}

- (id)getPagesTree
{
    id pageTree;
    [self getPageObjectNum];
    pageTree = [document getInfoForKey:@"Kids" inObject:pageInfoObjectNum];
    
    return pageTree;
}

- (id)getPageNumber:(YPDocument *)d
{
    id page;
    [self getPageObjectNum];
    
    if ([d getInfoForKey:@"Kids" inObject:pageInfoObjectNum]) {
        
    }
    
    return page;
}


//getPagesInfo
//getCount
//getPageNumber



@end
