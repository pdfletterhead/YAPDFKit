//
//  PDFStreamDecoder.h
//  Parser
//
//  Created by Aliona on 24.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFStreamDecoder : NSObject
- (id)initWithData:(NSData *)d;
- (NSData *)getDecrypted;
@end
