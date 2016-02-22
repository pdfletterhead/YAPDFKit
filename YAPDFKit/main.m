//
//  main.m
//  YAPDFKit
//
//  Created by Aliona on 10.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPDocument.h"

enum ParserStates {
    BEGIN_STATE = 0,
    FILL_VERSION_STATE,
    DEFAULT_STATE,
};


int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        NSString *intro = @"\n"\
        "          __  _____       ____  ____  ______   __ __ _ __\n"\
        "          \\ \\/ /   |     / __ \\/ __ \\/ ____/  / //_/(_) /_\n"\
        "           \\  / /| |    / /_/ / / / / /_     / ,<  / / __/\n"\
        "           / / ___ |   / ____/ /_/ / __/    / /| |/ / /_\n"\
        "          /_/_/  |_|  /_/   /_____/_/      /_/ |_/_/\\__/\n"\
        "\n"\
        "\n"\
        "Main.c is shows an example usage of YAPDFKit.\n"\
        "\n"\
        "- It reads a two page PDF (/tmp/2-page-pages-export.pdf)\n"\
        "- iterates through all pages\n"\
        "- unpacks the content stream\n"\
        "- add's a purple rectangle at below the text\n"\
        "- updates the PDF by adding an updates object block and  writing a new xref\n"\
        "  table.\n"\
        "\n"\
        "You can see the result.\n"\
        "\n"\
        "open /tmp/2-page-pages-export-mod.pdf\n"\
        "\n"\
        "Enjoy using YAPDFKit\n";
        
        NSLog(@"%@\n",intro);
        
        
        NSString *file =@"/tmp/2-page-pages-export.pdf";
        
        NSData *fileData = [NSData dataWithContentsOfFile:file];

        YPDocument *document = [[YPDocument alloc] initWithData:fileData];

        YPPages *pg = [[YPPages alloc] initWithDocument:document];
        NSLog(@"page count: %d", [pg getPageCount]);
        
        //All Pages unsorted
        NSArray * allPages = [document getAllObjectsWithKey:@"Type" value:@"Page"];
        
        for (YPObject* page in allPages) {
            
            NSString *docContentNumber = [[document getInfoForKey:@"Contents" inObject:[page getObjectNumber]] getReferenceNumber];
            YPObject * pageContentsObject = [document getObjectByNumber:docContentNumber];
            
            NSData *plainContent = [pageContentsObject getUncompressedStreamContentsAsData];
            
            NSData *data2 = [@"q /Cs1 cs 0.4 0 0.6 sc 250 600 100 100 re f q " dataUsingEncoding:NSASCIIStringEncoding];
            
            NSRange firstPartRange = {0,64};
            NSRange lastPartRange = {64, ([plainContent length]-64)};
            NSData *data1 = [plainContent subdataWithRange:firstPartRange];
            NSData *data3 = [plainContent subdataWithRange:lastPartRange];
            
            NSMutableData * newPlainContent = [data1 mutableCopy];
            [newPlainContent appendData:data2];
            [newPlainContent appendData:data3];
            
            [pageContentsObject setStreamContentsWithData:newPlainContent];
            [document addObjectToUpdateQueue:pageContentsObject];
        }
        
        [document updateDocumentData];
        [[document modifiedPDFData] writeToFile:@"/tmp/2-page-pages-export-mod.pdf" atomically:YES];
        
     }
    return 0;
}