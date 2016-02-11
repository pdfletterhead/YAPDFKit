#  YAPDFKit

[![Build
Status](https://travis-ci.org/mipmip/YAPDFKit.svg?branch=master)](https://travis-ci.org/mipmip/YAPDFKit)

Yet another PDF Kit is a independent PDF Kit written in objective-c for
parsing and manipulating PDF's.

WARNING: Currently the state of YAPDFKit is experimental.

## Motivation
This project started because I wanted to remove white
backgrounds from PDF's made by Applications like Apple Pages. YAPDFKit
is used in the [PDF Letterhead App](http://pdfletterhead.net).

YAPDFKit tries to be completely independant of Apple's PDFKit

## Requirements

### Platform targets

- Usable in OSX and iOS projects
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
- [ ] Add some file intergration tests
- [ ] Return all document pages
- [ ] Return all page objects
- [ ] Return page content object
- [ ] Add new object at file bottom
- [ ] calculate file and object length
- [ ] Add new xref table at file bottom
- [ ] Add new trailer

### Backlog
- [ ] add inflate function
- [ ] Exact Text (ProcessOutput)
- [ ] Make podspec
- [ ] Code Coverage
- [ ] Rename all object attributes classes with a name including object
- [ ] cleanup file reader

## Credits

- YAPDFKit is a fork of [PDFCoolParser](https://github.com/kozliappi/PDFCoolParser) by @kozliappi.
- YAPDFKit is sponsored by [Lingewoud](http://lingewoud.com) and [MunsterMade](http://munstermade.com).

