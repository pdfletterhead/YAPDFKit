//
//  PDFPages.m
//  YAPDFKit
//
//  Created by Aliona on 28.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import "PDFPages.h"
#import "PDFDictionary.h"
#import "PDFObject.h"
#import "PDFObjectReference.h"

@implementation PDFPages
{
    PDFDocument* document;
}

@synthesize pageInfoObjectNum;

- (id)initWithDocument:(PDFDocument *)d
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
    PDFObjectReference *pageObjRef = [document getInfoForKey:@"Pages" inObject:catalogNum];
    pageInfoObjectNum = [pageObjRef getReferenceNumber];
}

- (int)getPageCount
{
    [self getPageObjectNum];
    NSString* pageCount = [document getInfoForKey:@"Count" inObject:pageInfoObjectNum];
    //NSLog(@"pages: %@ pages: %@",pageInfoObjectNum, pageCount);
    return [pageCount intValue];
}

- (id)getPagesTree
{
    id pageTree;
    [self getPageObjectNum];
    pageTree = [document getInfoForKey:@"Kids" inObject:pageInfoObjectNum];
    
    return pageTree;
}

- (id)getPageNumber:(PDFDocument *)d
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
