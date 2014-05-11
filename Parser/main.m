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

enum ParserStates {
    BEGIN_STATE = 0,
    FILL_VERSION_STATE,
    DEFAULT_STATE,
};

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
      //  NSString *version = @"";
      //  NSString *errorMessage = nil;
        
        NSData *fileData = [NSData dataWithContentsOfFile:@"/Users/kozliappi/Desktop/test_1/test_in.pdf"];
        
        PDFDocument *document = [[PDFDocument alloc] initWithData:fileData];
        if ([document errorMessage]) {
            NSLog(@"%@", [document errorMessage]);
        }
        else {
            NSLog(@"%@", [document version]);
        }
      /*
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
