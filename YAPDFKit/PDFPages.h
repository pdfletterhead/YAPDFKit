//
//  PDFPages.h
//  YAPDFKit
//
//  Created by Aliona on 28.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import "PDFDocument.h"

@interface PDFPages : NSObject

@property id pageInfoObjectNum;

- (id)initWithDocument:(PDFDocument *)d;
- (int)getPageCount;
- (id)getPagesTree;

@end
