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
            
            NSString *plainContent = [pageContentsObject getUncompressedStreamContents];
            
            NSLog(@"plain: %@", plainContent);
            
            NSString * newplain = [plainContent stringByReplacingOccurrencesOfString:@"0 0 595 842 re W n /Cs1 cs 1 1 1 sc"
                                                                          withString:@"0 0 000 000 re W n /Cs1 cs 1 1 1 sc"];
            [pageContentsObject setStreamContentsWithString:newplain];
            
            [document addObjectToUpdateQueue:pageContentsObject];
        }
        
        [document updateDocumentData];
        [[document modifiedPDFData] writeToFile:@"/Users/pim/Desktop/test.pdf" atomically:YES];
        
     }
    return 0;
}