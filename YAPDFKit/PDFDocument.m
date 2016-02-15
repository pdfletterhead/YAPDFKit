//
//  PDFDocument.m
//  YAPDFKit
//
//  Created by Aliona on 10.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import "PDFDocument.h"
#import "PDFObject.h"
#import "PDFXref.h"
#import "Utils.h"

enum ParserStates {
    ERROR_STATE = -1,
    BEGIN_STATE = 0,
    FILL_VERSION_STATE,
    SEARCH_NEXT_PDF_STRUCTURE_STATE,
    NEXT_PDF_STRUCTURE_STATE,
    IN_PDF_COMMENT_STATE,
    IN_PDF_OBJECT_STATE,
    IN_PDF_XREF_STATE,
    DEFAULT_STATE,
};

const char* strblock(const char* p, int(^func)(char ch))
{
    for (; *p && func(*p); ++p) {
    }
    return p;
}

@implementation PDFDocument

@synthesize objects;
@synthesize comments;
@synthesize docSize;
@synthesize modifiedPDFData;
@synthesize updateObjectQueue;
@synthesize lastTrailerOffset;

- (id)initWithData:(NSData*)data
{
    if (self = [super init]) {

        _version = @"";
        objects = [[NSMutableDictionary alloc] init];
        comments = [[NSMutableArray alloc] init];
        docSize = [data length];
        
        modifiedPDFData = [[NSMutableData alloc] initWithData:data];
        updateObjectQueue = [[NSMutableArray alloc] init];

        char *buffer = malloc(data.length + 1);
        memcpy(buffer, data.bytes, data.length);
        buffer[data.length] = 0;
        NSData *dataWithNull = [NSData dataWithBytes:buffer length:data.length + 1];
        free(buffer);

        [self parseData:dataWithNull];
        [self linkObjectsWithContents];

        return self;
    }
    return nil;
}

- (NSDictionary*)allObjects
{
    return objects;
}

- (NSString*)version
{
    return _version;
}

- (NSString*)errorMessage
{
    return _errorMessage;
}

- (void)parseData:(NSData*)data
{
    enum ParserStates state = BEGIN_STATE;

    if (data.length < 5) {
        _errorMessage = @"Too short file";
        return;
    }

    NSUInteger i = 0;

    while (i < data.length && _errorMessage == nil) {
        switch (state) {
            case BEGIN_STATE:
                state = [self handleBeginState:data idx:&i];
                break;

            case FILL_VERSION_STATE:
                state = [self handleVersionState:data idx:&i];
                break;

            case SEARCH_NEXT_PDF_STRUCTURE_STATE:
                state = [self handleSearchNextPDFStructureState:data idx:&i];
                break;

            case NEXT_PDF_STRUCTURE_STATE:
                state = [self handleNextPDFStructureState:data idx:&i];
                break;

            case IN_PDF_COMMENT_STATE:
                state = [self handleInPDFCommentState:data idx:&i];
                break;

            case IN_PDF_OBJECT_STATE:
                state = [self handleInPDFObjectState:data idx:&i];
                break;

            case IN_PDF_XREF_STATE:
                state = [self handleInPDFXrefState:data idx:&i];
                break;

            default:
                ++i;
                break;
        }
    }
}

- (enum ParserStates)handleBeginState:(NSData*)data idx:(NSUInteger*)idx
{
    const char *rawData = (const char *)[data bytes];

    NSUInteger i = *idx;
    if(rawData[i] == '%') {
        char buffer[] = {rawData[i], rawData[i+1], rawData[i+2], rawData[i+3], rawData[i+4], 0};
        if (strncmp("%PDF-", buffer, sizeof(buffer) / sizeof(char))) {
            _errorMessage = @"Failed to read pdf header";
            return ERROR_STATE;
        }
        *idx += sizeof(buffer) - 1;
        return FILL_VERSION_STATE;
    }
    _errorMessage = @"File must begin with '%' symbol";
    return ERROR_STATE;
}

- (enum ParserStates)handleVersionState:(NSData*)data idx:(NSUInteger*)idx
{
    const char *rawData = (const char *)[data bytes];

    NSUInteger i = *idx;
    for (; rawData[i] != '\r' && rawData[i] != '\n'; ++i) {
        char buffer[] = {rawData[i], 0};
        _version = [_version stringByAppendingString:@(buffer)];


        //NSDictionary *dict = [NSDictionary dictionaryWithObject:_version forKey:@"version"];
        //[_objects addObject:dict];
    }

    *idx = i;
    return SEARCH_NEXT_PDF_STRUCTURE_STATE;
}

- (enum ParserStates)handleSearchNextPDFStructureState:(NSData*)data idx:(NSUInteger*)idx
{
    const char *rawData = (const char *)[data bytes];

    NSUInteger i = *idx;
    for (; isBlank(rawData[i]); ++i) {
    }

    *idx = i;
    return NEXT_PDF_STRUCTURE_STATE;
}

- (enum ParserStates)handleNextPDFStructureState:(NSData*)data idx:(NSUInteger*)idx
{
    const char *rawData = (const char *)[data bytes];

    NSUInteger i = *idx;
    enum ParserStates state = ERROR_STATE;

    switch (rawData[i]) {
        case '%':
            state = IN_PDF_COMMENT_STATE;
            ++i;
            break;

        case 'x':
            state = IN_PDF_XREF_STATE;
            break;

        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            state = IN_PDF_OBJECT_STATE;
            break;

        default:
            state = DEFAULT_STATE;
            break;
    }
    *idx = i;
    return state;
}

- (enum ParserStates)handleInPDFCommentState:(NSData*)data idx:(NSUInteger*)idx
{
    const char *rawData = (const char*)[data bytes];
    NSUInteger i = *idx;

    NSUInteger endOfCommentIdx = i;
    while (rawData[endOfCommentIdx] != '\r' && rawData[endOfCommentIdx] != '\n') {
        ++endOfCommentIdx;
    }
    char* buffer = malloc((endOfCommentIdx - i) + 1);
    memcpy(buffer, &rawData[i], (endOfCommentIdx - i) + 1);
    buffer[endOfCommentIdx - i] = 0;
    NSString* comment = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
//    NSString* comment = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
//    NSLog(@"%@", comment);
    i = endOfCommentIdx;

    //NSDictionary *dict = [NSDictionary dictionaryWithObject:comment forKey:@"comment"];
    [comments addObject:comment];

    *idx = i;
    return SEARCH_NEXT_PDF_STRUCTURE_STATE;
}

- (enum ParserStates)handleInPDFObjectState:(NSData*)data idx:(NSUInteger*)idx
{
    const char *rawData = (const char*)[data bytes];
    NSUInteger dataLength = data.length;

    NSUInteger i = *idx;
    NSString *firstObjNum = @"";
    NSString *secondObjNum = @"";

    for(; i < dataLength; ++i) {
        if(isNum(rawData[i])) {
            char buffer[] = {rawData[i], 0};
            firstObjNum = [firstObjNum stringByAppendingString:@(buffer)];
        } else {
            break;
        }
    }

    if (!isBlank(rawData[i])) {
        _errorMessage = @"Unknown object syntax";
        return ERROR_STATE;
    }

    for (; i+3 < dataLength; ++i) {
        if (rawData[i] == ' ' && rawData[i+1] == 'o' && rawData[i+2] == 'b' && rawData[i+3] == 'j') {
            i += 4;
            break;
        }
        char buffer[] = {rawData[i], 0};
        secondObjNum = [secondObjNum stringByAppendingString:@(buffer)];
    }

    NSInteger first = [firstObjNum integerValue];
    NSInteger second = [secondObjNum integerValue];

    skipBlankSymbols(rawData, &i);

    const char* objBodyBegin = &rawData[i];
    const char* objBodyEnd;

    for (; i+6 < dataLength; ++i) {
        if (rawData[i-1] != '\\' && rawData[i] == 'e' && rawData[i+1] == 'n' && rawData[i+2] == 'd' && rawData[i+3] == 'o' && rawData[i+4] == 'b' && rawData[i+5] == 'j') {
            objBodyEnd = &rawData[i-1];
            i += 6;
            break;
        }
    }

    skipBlankSymbols(rawData, &i);
    NSData *objectData = NULL;

    if(objBodyEnd - objBodyBegin > 0) {
        objectData = [NSData dataWithBytes:objBodyBegin length:objBodyEnd - objBodyBegin];
    }

    PDFObject *p = [[PDFObject alloc] initWithData:objectData first:&first second:&second];
    [objects setObject:p forKey:[p getObjectNumber]];

    *idx = i;
    return SEARCH_NEXT_PDF_STRUCTURE_STATE;
}

- (enum ParserStates)handleInPDFXrefState:(NSData*)data idx:(NSUInteger*)idx
{
    NSUInteger i = *idx;
    const char *rawData = (const char*)[data bytes];
    NSUInteger dataLength = data.length;

    if(!(i+3 < dataLength && rawData[i] == 'x' && rawData[i+1] == 'r' && rawData[i+2] == 'e' && rawData[i+3] == 'f')) {
        _errorMessage = @"Xref unknown syntax";
        return ERROR_STATE;
    }

    i += 4;
    const char* xrefBegin = &rawData[i];
    const char* xrefEnd = NULL;

    for (; i+9 < dataLength; ++i) {
        if (rawData[i] == 't') {
            char buffer[] = {rawData[i], rawData[i+1], rawData[i+2], rawData[i+3], rawData[i+4], rawData[i+5], rawData[i+6], 0};
            if (![@(buffer) isEqualToString:@"trailer"]) {
                _errorMessage = @"Xref unknown syntax";
                return ERROR_STATE;
            }
            lastTrailerOffset = (NSInteger*)i;
            
            xrefEnd = &rawData[i];
            i += 7;
            break;
        }
    }

    NSData *xrefData = [NSData dataWithBytes:xrefBegin length:xrefEnd - xrefBegin];

    skipBlankSymbols(rawData, &i);
    const char* trailerBegin = &rawData[i];
    const char* trailerEnd = NULL;

    for (; i+9 < dataLength; ++i) {
        if (rawData[i] == 's') {
            xrefEnd = &rawData[i];
            char buffer[] = {rawData[i], rawData[i+1], rawData[i+2], rawData[i+3], rawData[i+4], rawData[i+5], rawData[i+6], rawData[i+7], rawData[i+8], 0};
            if (![@(buffer) isEqualToString:@"startxref"]) {
                _errorMessage = @"Xref unknown syntax";
                return ERROR_STATE;
            }

            trailerEnd = &rawData[i];
            i += 9;
            break;
        }
    }

    NSData *trailerData = [NSData dataWithBytes:trailerBegin length:trailerEnd - trailerBegin];

    //NSLog(@"Xref: %@ \r Trailer: %@", xrefData, trailerData);

    skipBlankSymbols(rawData, &i);

    NSString *someNum = @"";
    while (i < dataLength && isNum(rawData[i])) {
        char buffer[] = {rawData[i], 0};
        someNum = [someNum stringByAppendingString:@(buffer)];
        ++i;
    }

    *idx = i;
    return SEARCH_NEXT_PDF_STRUCTURE_STATE;
}

- (void) linkObjectsWithContents
{
    for (NSString *key in objects) {
        PDFObject* object = [objects objectForKey:key];
        if (object.references) {
            NSMutableDictionary *cpReference = [[NSMutableDictionary alloc] init];
            for(NSString *reference in object.references) {
                if ([objects objectForKey:reference]) {
                    PDFObject *referenceTo = [objects objectForKey:reference];
                    [cpReference setObject:referenceTo forKey:reference];
                }
            }
            object.references = cpReference;
        }
    }
}

- (NSArray*) getAllObjectsWithKey:(NSString *)key{
    NSMutableArray * infoArray = [[NSMutableArray alloc] init];
    for (NSString* obj in objects) {
        PDFObject *current = [objects objectForKey:obj];
        id currentValue = [current value];
        if ([currentValue isKindOfClass:[NSDictionary class]] && [currentValue objectForKey:key]) {
//            info = [currentValue objectForKey:key];
            [infoArray addObject:current];
            //NSLog(@"%@ : obj num %@",info, [current getObjectNumber]);
        }
    }
    return (NSArray*)infoArray;
}

- (NSArray *)getAllObjectsWithKey:(NSString *)key value:(NSString *)value
{
    NSMutableArray * infoArray = [[NSMutableArray alloc] init];
    NSArray* objWithKeyType = [self getAllObjectsWithKey:@"Type"];
    
    for (PDFObject* obj in objWithKeyType) {
        NSString * valForKey = [self getInfoForKey:key inObject:[obj getObjectNumber]];
        if ([valForKey isEqualToString:value])
        {
            [infoArray addObject:obj];
        }
    }
    
    return (NSArray*)infoArray;
}

- (id) getInfoForKey:(NSString *)key
{
    id info = nil;
    for (NSString* obj in objects) {
        PDFObject *current = [objects objectForKey:obj];
        id currentValue = [current value];
        if ([currentValue isKindOfClass:[NSDictionary class]] && [currentValue objectForKey:key]) {
            info = [currentValue objectForKey:key];
            //NSLog(@"%@ : obj num %@",info, [current getObjectNumber]);
        }
    }
    return info;
}

- (id) getInfoForKey:(NSString *)key inObject:(NSString *)objectNumber
{
    id info = nil;
    PDFObject *object = [objects objectForKey:objectNumber];
    id objectValue = [object value];
    if ([objectValue isKindOfClass:[NSDictionary class]] && [objectValue objectForKey:key]) {
        info = [objectValue objectForKey:key];
    }
    return info;
}

- (NSString *)getObjectNumberForKey:(NSString *)key value:(NSString *)value
{
    NSString *num = @"";
    for (NSString* obj in objects) {
        PDFObject *current = [objects objectForKey:obj];
        id currentValue = [current value];
        if ([currentValue isKindOfClass:[NSDictionary class]] && [currentValue objectForKey:key]) {
            if (value && ![value isEqualToString:[currentValue objectForKey:key] ]) {
                continue;
            }
            num = [current getObjectNumber];
            //NSLog(@"%@", num);
        }
    }
    return num;
}


- (BOOL)isBinary
{
    if([comments[0] canBeConvertedToEncoding:NSASCIIStringEncoding])
    {
        return false;
    }
    else
    {
        return true;
    }
    

    return false;
}

- (NSDictionary*)getObjectsWithStreams
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    for(id key in objects) {
        id pdfObject = [objects objectForKey:key];
        
        id stream = [pdfObject getStreamObject];
        
        if(stream)
        {
            [dict setObject:stream forKey:key];
        }
    }
    
    return (NSDictionary*)dict;
}


- (NSString*)getPDFInfo
{
    NSMutableString* infoString = (NSMutableString*)@"";
    infoString = (NSMutableString*)[infoString stringByAppendingFormat:@"Size: %ld bytes\n",(long)docSize];
    infoString = (NSMutableString*)[infoString stringByAppendingFormat:@"Version: %@\n",_version];
    
    if([self isBinary])
    {
        infoString = (NSMutableString*)[infoString stringByAppendingString:@"Binary: True\n"];
    }
    else
    {
        infoString = (NSMutableString*)[infoString stringByAppendingString:@"Binary: False\n"];
    }
    infoString = (NSMutableString*)[infoString stringByAppendingFormat:@"Objects: %ld\n",[objects count]];
    infoString = (NSMutableString*)[infoString stringByAppendingFormat:@"Streams: %ld\n",[[self getObjectsWithStreams] count]];
    infoString = (NSMutableString*)[infoString stringByAppendingFormat:@"Comments: %ld\n",[comments count]];
    
    return (NSString*)infoString;
}

- (NSString*)getPDFMetaData
{
    return nil;
}

- (NSString *) getDocumentCatalog
{
    NSString *catalogNum = [self getObjectNumberForKey:@"Type" value:@"Catalog"];
    
    return catalogNum;
}

- (PDFObject*) getObjectByNumber:(NSString*)number
{
    PDFObject* object = [objects objectForKey:number];
    return object;
}

- (void) addObjectToUpdateQueue:(PDFObject *)pdfObject
{
    //add to update array
    [updateObjectQueue addObject:pdfObject];
    //[pdfObject getUncompressedStreamContents];
}

- (void) updateDocumentData
{
    //previous trailor
    //NSNumber* prevTrailer;
    
    //NSNumber* offSet; //[NSNumber numberWithInt: (int)[modifiedPDFData length]];
    PDFXref * xref = [[PDFXref alloc] init];
    
    //create object blocks and add to data
    for (PDFObject * obj in updateObjectQueue) {
        
        NSNumber* offset = [NSNumber numberWithInt: (int)[modifiedPDFData length]];
        [xref addObjectEntry:offset generation:[NSNumber numberWithInt:1] deleted:NO];
        
        NSData *data = [[obj createObjectBlock] dataUsingEncoding:NSUTF8StringEncoding];
        [modifiedPDFData appendData:data];
    }
    
    //write update xref
    NSNumber* startXref = [NSNumber numberWithInt: (int)[modifiedPDFData length]];
    [modifiedPDFData appendData:[[xref stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [modifiedPDFData appendData:[[self createTrailerBlock:startXref previousTrailorOffset:(int)lastTrailerOffset] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //write new trailer
}

- (NSString*) createTrailerBlock:(NSNumber*)startxref previousTrailorOffset:(NSInteger)prev
{
    /*
    trailer
    << /Size 36 /Root 19 0 R /Info 1 0 R /ID [ <ede0accd1c1d502ae2a231a489ab03f8>
                                              <ede0accd1c1d502ae2a231a489ab03f8> ] >>
    startxref
    20181
    %%EOF
    */
    
    NSMutableString* blockString = (NSMutableString*)@"trailer\n";
    blockString = (NSMutableString*)[blockString stringByAppendingString:@"<< "];
    blockString = (NSMutableString*)[blockString stringByAppendingFormat:@"/Size %lu ",(unsigned long)[objects count]];
    blockString = (NSMutableString*)[blockString stringByAppendingFormat:@"/Root %@ R ",[self getDocumentCatalog]];
    blockString = (NSMutableString*)[blockString stringByAppendingFormat:@"/Prev %ld ",(long)prev];
    blockString = (NSMutableString*)[blockString stringByAppendingString:@">>\n"];
    blockString = (NSMutableString*)[blockString stringByAppendingFormat:@"startxref\n%@\n",startxref];
    blockString = (NSMutableString*)[blockString stringByAppendingString:@"%%EOF"];
    
    return blockString;
}

- (void) writeToFile
{
    
}

@end
