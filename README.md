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

In this example we remove all non-transparent white backgrounds from every page in an 
PDF file and we save the result in a new PDF file

```objective-c

NSData *fileData = [NSData dataWithContentsOfFile:@"/path/to/pdf/PDF-with-non-transparent-background.pdf"];
YPDocument *document = [[YPDocument alloc] initWithData:fileData];

YPPages *pg = [[YPPages alloc] initWithDocument:document];

// Get all pages unsorted
NSArray * allPages = [document getAllObjectsWithKey:@"Type" value:@"Page"];

for (YPObject *page in allPages) {

    NSString *docContentNumber = [[document getInfoForKey:@"Contents" inObject:[page getObjectNumber]] getReferenceNumber];
    YPObject *pageContentsObject = [document getObjectByNumber:docContentNumber];

    NSString *plainContent = [pageContentsObject getUncompressedStreamContents];

    NSString *newPlainContent = [plainContent stringByReplacingOccurrencesOfString:@"0 0 595 842 re W n /Cs1 cs 1 1 1 sc"
                                                                        withString:@"0 0 000 000 re W n /Cs1 cs 1 1 1 sc"];

    [pageContentsObject setStreamContentsWithString:newPlainContent];

    [document addObjectToUpdateQueue:pageContentsObject];
}

[document updateDocumentData];
[[document modifiedPDFData] writeToFile:@"/path/to/pdf/PDF-with-transparent-background.pdf" atomically:YES];
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
- [ ] add included pdf in main.c

### Backlog
- [ ] Return all page objects / per page
- [ ] add inflate function
- [ ] Exact Text (ProcessOutput)
- [ ] Code Coverage
- [ ] Rename all object attributes classes with a name including object
- [ ] cleanup file reader

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
