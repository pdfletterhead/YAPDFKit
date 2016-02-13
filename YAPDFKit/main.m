//
//  main.m
//  YAPDFKit
//
//  Created by Aliona on 10.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>

#import "PDFDocument.h"
#import "PDFObject.h"
#import "PDFPages.h"
#import "PDFObjectReference.h"

enum ParserStates {
    BEGIN_STATE = 0,
    FILL_VERSION_STATE,
    DEFAULT_STATE,
};


int main(int argc, const char * argv[])
{
    @autoreleasepool {

        NSString *file2 = @"/Users/pim/RnD/Studies/PDF-transparant/pdfs/pages-multi-export-naar-pdf.pdf";
        NSData *fileData = [NSData dataWithContentsOfFile:file2];

        PDFDocument *document = [[PDFDocument alloc] initWithData:fileData];
        
        PDFPages *pg = [[PDFPages alloc] initWithDocument:document];
        NSLog(@"page count: %d", [pg getPageCount]);
        
        //All Pages unsorted
        NSArray * allPages = [document getAllObjectsWithKey:@"Type" value:@"Page"];
        NSLog(@"all: %@ ", allPages);
        
        for (PDFObject* page in allPages) {
            
            NSString *docContentNumber = [[document getInfoForKey:@"Contents" inObject:[page getObjectNumber]] getReferenceNumber];
            PDFObject * pageContentsObject = [document getObjectByNumber:docContentNumber];
            [pageContentsObject setStreamContentsWithString:@"BT\ /TT1 1 Tf\ 17 72 Td\ (Hello World!)Tj\n"];
            [document addObjectToUpdateQueue:pageContentsObject];
             //NSLog(@"block:\n\n%@\n\n",[pageContentsObject createObjectBlock]);
        }
        
        [document updateDocumentData];
        [[document modifiedPDFData] writeToFile:@"/Users/pim/Desktop/test.pdf" atomically:YES];
        
     }
    return 0;
}