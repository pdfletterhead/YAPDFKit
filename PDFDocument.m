//
//  PDFDocument.m
//  Parser
//
//  Created by Aliona on 10.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import "PDFDocument.h"
#import "PDFObject.h"
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

@synthesize contents;

- (id)initWithData:(NSData*)data
{
    if (self = [super init]) {
        
        _version = @"";
        contents = [[NSMutableDictionary alloc] init];
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
        //[_contents addObject:dict];
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
    NSLog(@"%@", comment);
    i = endOfCommentIdx;
    
    //NSDictionary *dict = [NSDictionary dictionaryWithObject:comment forKey:@"comment"];
    //[_contents addObject:dict];
    
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

    NSString * objBodyStr = [[NSString alloc] initWithData:objectData encoding:NSASCIIStringEncoding];
    if ([objBodyStr rangeOfString:@"FlateDecode"].location == NSNotFound) {
    } else {
        
        //NSLog(@"\n\nB--------\n\n");
        //dumpCharArray(objectData.bytes, objectData.length);
        //printf("\n\nE--------\n\n");
    }
    
    PDFObject *p = [[PDFObject alloc] initWithData:objectData first:&first second:&second];
    [contents setObject:p forKey:[p getObjectNumber]];

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
    for (NSString *key in contents) {
        PDFObject* object = [contents objectForKey:key];
        if (object.references) {
            NSMutableDictionary *cpReference = [[NSMutableDictionary alloc] init];
            for(NSString *reference in object.references) {
                if ([contents objectForKey:reference]) {
                    PDFObject *referenceTo = [contents objectForKey:reference];
                    [cpReference setObject:referenceTo forKey:reference];
                }
            }
            object.references = cpReference;
        }
    }
}

- (id) getInfoForKey:(NSString *)key
{
    id info = nil;
    for (NSString* obj in contents) {
        PDFObject *current = [contents objectForKey:obj];
        id currentValue = [current value];
        if ([currentValue isKindOfClass:[NSDictionary class]] && [currentValue objectForKey:key]) {
            info = [currentValue objectForKey:key];
            NSLog(@"%@ : obj num %@",info, [current getObjectNumber]);
        }
    }
    return info;
}

- (id) getInfoForKey:(NSString *)key inObject:(NSString *)objectNumber
{
    id info = nil;
    PDFObject *object = [contents objectForKey:objectNumber];
    id objectValue = [object value];
    if ([objectValue isKindOfClass:[NSDictionary class]] && [objectValue objectForKey:key]) {
        info = [objectValue objectForKey:key];
        NSLog(@"getInfoForKey %@ : %@",key,info);
    }
    return info;
}

- (NSString *)getObjectNumberForKey:(NSString *)key :(NSString *)value
{
    NSString *num = @"";
    for (NSString* obj in contents) {
        PDFObject *current = [contents objectForKey:obj];
        id currentValue = [current value];
        if ([currentValue isKindOfClass:[NSDictionary class]] && [currentValue objectForKey:key]) {
            if (value && ![value isEqualToString:[currentValue objectForKey:key] ]) {
                continue;
            }
            num = [current getObjectNumber];
            NSLog(@"%@", num);
        }
    }
    return num;
}

@end