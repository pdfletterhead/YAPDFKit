//
//  PDFParser.h
//  Parser
//
//  Created by Aliona on 10.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFParser : NSObject
{
    NSData *fileData;
}

- (void) setFileData:(NSString*)path;
- (void) initWithContentsOfFile:(NSString*)path;


@end
