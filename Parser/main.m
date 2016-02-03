//
//  main.m
//  Parser
//
//  Created by Aliona on 10.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>

#import "PDFDocument.h"
#import "PDFObject.h"
#import "PDFStreamDecoder.h"
#import "PDFPages.h"

#import "NSData+Compression.h"


enum ParserStates {
    BEGIN_STATE = 0,
    FILL_VERSION_STATE,
    DEFAULT_STATE,
};

int main(int argc, const char * argv[])
{
    @autoreleasepool {

        NSData *testComprData = [NSData dataWithContentsOfFile:@"/Users/pim/RnD/Studies/PDF-transparant/pdfs/1.compressed"];
        unsigned char *b1 = (unsigned char *)[testComprData bytes];
        unsigned char *b2 = (unsigned char *)[[testComprData zlibInflate] bytes];
        unsigned char *b3 = (unsigned char *)[[testComprData gzipDeflate] bytes];

        NSLog(@"%s", b1);
        NSLog(@"%s", b2);
        NSLog(@"%s", b3);
        
        
        
        
        //NSData *fileData = [NSData dataWithContentsOfFile:@"/Users/pim/RnD/Studies/PDF-transparant/pdfs/pages-multi-export-naar-pdf.pdf"];
        //NSData *fileData = [NSData dataWithContentsOfFile:@"/Users/pim/RnD/Studies/PDF-transparant/pdfs/test_in.pdf"];
        NSData *fileData = [NSData dataWithContentsOfFile:@"/Users/pim/RnD/Studies/PDF-transparant/pdfs/pages-export-naar-pdf.pdf"];
        
        //PDFStreamDecoder *p = [[PDFStreamDecoder alloc] initWithData:fileData];
        //NSData *u = [p getDecrypted];
        //NSLog(@"%@",u);
        
        PDFDocument *document = [[PDFDocument alloc] initWithData:fileData];
        [document getInfoForKey:@"Type"];
        
        //PDFPages *pg = [[PDFPages alloc] initWithDocument:document];
        //[pg getPageCount];
        //id tree = [pg getPagesTree];
        //NSLog(@"tree: %@",tree);
        
      if ([document errorMessage]) {
            NSLog(@"Error: %@", [document errorMessage]);
        }
        else {
          //  NSLog(@"PDF version: %@", [document version]);
        }
 
    }
    return 0;
}

/*
 make dict with content obj id per page
 
 
 
 
 
 
*/
