//
//  pdflib.h
//  YAPDFKit
//
//  Created by Pim Snel on 10-02-16.
//  Copyright © 2016 Lingewoud. All rights reserved.
//

#import <Foundation/Foundation.h>
NSData* deflateData(NSData * data);
NSString* deflateDataAsString(NSData * data);
NSData* inflateStringToData(NSString* string);
void ZeroMemory(void * buffer, long sizeOf);