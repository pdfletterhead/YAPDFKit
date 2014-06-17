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

enum ParserStates {
    BEGIN_STATE = 0,
    FILL_VERSION_STATE,
    DEFAULT_STATE,
};

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        NSData *fileData = [NSData dataWithContentsOfFile:@"/Users/kozliappi/Desktop/test_1/in.pdf"];
        PDFStreamDecoder *p = [[PDFStreamDecoder alloc] initWithData:fileData];
        NSData *u = [p getDecrypted];
        NSLog(@"%@",u);
        
        PDFDocument *document = [[PDFDocument alloc] initWithData:fileData];
        [document getInfoForKey:@"Type"];
        PDFPages *pg = [[PDFPages alloc] initWithDocument:document];
        [pg getPageCount];
        [pg getPagesTree];
        
        if ([document errorMessage]) {
            NSLog(@"%@", [document errorMessage]);
        }
        else {
            NSLog(@"%@", [document version]);
        }/**/
        
        /* NSString * s = @"#20";
        float i = [s floatValue];
        NSLog(@"i %f", i);*/
       /*
        
        //parsing an object
        NSString *s = @"3868";
        NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];
        ObjectPaser *p = [[ObjectPaser alloc] initWithData:data];

        
        
        //[obj checkNextStruct:&i];
        
      
        enum ParserStates state = BEGIN_STATE;
        
       
        const char* rawData = (const char*)[fileData bytes];
        if (fileData.length < 5) {
            return 1;
        }
        
        NSUInteger i = 0;
    
        while (i < fileData.length) {
            char ch = rawData[i];
            
            switch (state) {
                case BEGIN_STATE:
                    if(ch == '%') {
                        char buffer[] = {rawData[i], rawData[i+1], rawData[i+2], rawData[i+3], rawData[i+4], 0};
                        if (strncmp("%PDF-", buffer, sizeof(buffer) / sizeof(char))) {
                            errorMessage = @"Failed to read pdf header";
                        }
                        i += sizeof(buffer) - 1;
                        state = FILL_VERSION_STATE;
                    }
                    break;
                    
                case FILL_VERSION_STATE:
                    for (; rawData[i] != '\r' && rawData[i] != '\n'; ++i) {
                        char buffer[] = {rawData[i], 0};
                        version = [version stringByAppendingString:@(buffer)];
                    }
                    state = DEFAULT_STATE;
                    break;
                default:
                    ++i;
                    break;
            }
            
            if (errorMessage) {
                break;
            }
        }
        
        if (errorMessage) {
            NSLog(@"%@", errorMessage);
        }
        else {
            NSLog(@"%@", version);
        }*/
    }
    return 0;
}
