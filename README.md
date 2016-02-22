#  YAPDFKit

[![Build
Status](https://travis-ci.org/mipmip/YAPDFKit.svg?branch=master)](https://travis-ci.org/mipmip/YAPDFKit)

Yet another PDF Kit is a independent PDF Kit written in objective-c for
parsing and manipulating PDF's. YAPDFKit is completely independent of Apple's PDFKit

For specific cases YAPDFKit can be of great help, but it's currently in an Alpha state.

## Example

Use these includes:

```objective-c

#import <Foundation/Foundation.h>
#import "YPDocument.h"
```

In this example we add a purple rectangle below the text of every page. See main.c for a working version of this example.

```objective-c

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

```

## Requirements

### Platform targets

- Usable in OS X and iOS projects
- Oldest Mac target: Mac OS X 10.7

### Functionality targets

- Parser to create PDF Structure
- Extract Deflated and other filtered content
- Some essential Postscript knowledge and features
- Modify PDF Objects directly in PDF

## Roadmap

### Milestone 1: update page contents object

- [x] Return all document objects
- [x] Deflate content object stream
- [x] cleanup deflate function
- [x] Enable Existing Tests
- [x] Enable travis
- [x] Add some file intergration tests
- [x] Return all document pages
- [x] Return page content object
- [x] Add new object at file bottom
- [x] Add new xref table at file bottom
- [x] Add new trailer
- [x] calculate file length
- [x] calc object length
- [x] fix and check all offsets;

### Milestone 2: first CocoaPod Release
- [x] Make podspec
- [x] Replace PDF prefix with YAPDF everywhere

### Milestone 3: first CocoaPod Release
- [x] remove nsstring convertion for streams
- [x] add included pdf in main.c
- [x] cleanup file reader

### Backlog
- [ ] more examples
- [ ] Return all page objects / per page
- [ ] add inflate function
- [ ] Exact Text (ProcessOutput)
- [ ] Code Coverage
- [ ] Rename all object attributes classes with a name including object

## Motivation
This project started because we needed to remove white
backgrounds from PDF's made by Applications like Apple Pages. YAPDFKit
is used in the [PDF Letterhead App](http://pdfletterhead.net).

![image](http://picdrop.t3lab.com/DXf3SaNc8d.png)

![image](http://picdrop.t3lab.com/cAobHdySJ6.png)

## Credits
- YAPDFKit is a fork of [PDFCoolParser](https://github.com/kozliappi/PDFCoolParser) by @kozliappi.
- YAPDFKit is sponsored by [Lingewoud](http://lingewoud.com) and [MunsterMade](http://munstermade.com).

![image](http://picdrop.t3lab.com/yCWqnH5FWq.png)
