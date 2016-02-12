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
        
        NSLog(@"info:\n%@",[document getPDFInfo]);
        //[document getInfoForKey:@"Type"];
        
        
        //PDFPages *pg = [[PDFPages alloc] initWithDocument:document];
        //[pg getPageCount];
        //[pg getPagesTree];

        /*
        if ([document errorMessage]) {
            NSLog(@"%@", [document errorMessage]);
        }
        else {
            NSLog(@"%@", [document version]);
        }
        */

     }
    return 0;
}
