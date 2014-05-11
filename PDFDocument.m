//
//  PDFDocument.m
//  Parser
//
//  Created by Aliona on 10.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import "PDFDocument.h"

enum ParserStates {
    ERROR_STATE = -1,
    BEGIN_STATE = 0,
    FILL_VERSION_STATE,
    SEARCH_NEXT_PDF_STRUCTURE_STATE,
    NEXT_PDF_STRUCTURE_STATE,
    IN_PDF_COMMENT_STATE,
    IN_PDF_OBJECT_STATE,
    DEFAULT_STATE,
};

int isBlankSymbol(char ch)
{
    return ch == ' ' || ch == '\n' || ch == '\r' || ch == '\t';
}

int isDigitSymbol(char ch)
{
    return '0' <= ch && ch <= '9';
}

const char* strblock(const char* p, int(^func)(char ch))
{
    for (; *p && func(*p); ++p) {
    }
    return p;
}

@implementation PDFDocument

- (id)initWithData:(NSData*)data
{
    if (self = [super init]) {
        _version = @"";
        
        char *buffer = malloc(data.length + 1);
        memcpy(buffer, data.bytes, data.length);
        buffer[data.length] = 0;
        NSData *dataWithNull = [NSData dataWithBytes:buffer length:data.length + 1];
        free(buffer);
        
        [self parseData:dataWithNull];
        
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

- (BOOL)isBlankSymbol:(char)symbol
{
    return symbol == ' ' || symbol == '\t' || symbol == '\r' || symbol == '\n';
}

- (BOOL)isDigitSymbol:(char)symbol
{
    return '0' <= symbol && symbol <= '9';
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
    }
    
    *idx = i;
    return SEARCH_NEXT_PDF_STRUCTURE_STATE;
}

- (enum ParserStates)handleSearchNextPDFStructureState:(NSData*)data idx:(NSUInteger*)idx
{
    const char *rawData = (const char *)[data bytes];
    
    NSUInteger i = *idx;
    for (; [self isBlankSymbol:rawData[i]]; ++i) {
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
    
    *idx = i;
    return SEARCH_NEXT_PDF_STRUCTURE_STATE;
}

- (enum ParserStates)handleInPDFObjectState:(NSData*)data idx:(NSUInteger*)idx
{
    const char *rawData = (const char*)[data bytes];
    
    const char *beginFirstNum = &rawData[*idx];
    const char *endFirstNum   = strblock(beginFirstNum, ^(char ch) {
        return isDigitSymbol(ch);
    });
    if (endFirstNum == 0) {
        _errorMessage = @"Unexpected end of file";
        return ERROR_STATE;
    }
    
    // Получим начао второго числа объекта
    const char *beginSecondNum = strblock(endFirstNum, ^(char ch) {
        return isBlankSymbol(ch);
    });
    if (beginSecondNum == 0) {
        _errorMessage = @"Unexpected end of file";
        return ERROR_STATE;
    }
    if (isDigitSymbol(*beginSecondNum) == NO) {
        _errorMessage = @"It was not digit";
        return ERROR_STATE;
    }
    
    // Получим конец второго числа оъекта
    const char *endSecondNum = strblock(beginSecondNum, ^(char ch) {
        return isDigitSymbol(ch);
    });
    if (endSecondNum == 0) {
        _errorMessage = @"Unexpected end of file";
        return ERROR_STATE;
    }
    
    const char *beginObj = strblock(endSecondNum, ^(char ch) {
        return isBlankSymbol(ch);
    });
    if (beginObj == 0) {
        _errorMessage = @"Unexpected end of file";
        return ERROR_STATE;
    }
    
    char buffer[] = {beginObj[0], beginObj[1], beginObj[2], 0};
    if (strncmp(buffer, "obj", sizeof(buffer))) {
        _errorMessage = @"It was not object";
        return ERROR_STATE;
    }
    
    char *buffer1 = malloc(endFirstNum - beginFirstNum + 1);
    char *buffer2 = malloc(endSecondNum - beginSecondNum + 1);
    memcpy(buffer1, beginFirstNum, endFirstNum - beginFirstNum);
    memcpy(buffer2, beginSecondNum, endSecondNum - beginSecondNum);
    free(buffer1);
    free(buffer2);
    
    const char* objBodyBegin = beginObj + sizeof(buffer) - 1;
    
    const char *endObj = strstr(objBodyBegin, "endobj");
    if (endObj == 0) {
        _errorMessage = @"End of object not found";
        return ERROR_STATE;
    }
    
    NSData *objectData = [NSData dataWithBytes:objBodyBegin length:endObj - objBodyBegin];
    NSString *objBodyStr = [[NSString alloc] initWithData:objectData encoding:NSASCIIStringEncoding];
    
    NSLog(@"%@ %@ obj\r%@\rendobj", @(buffer1), @(buffer2), objBodyStr);
    
    *idx = endObj - rawData;
    *idx += sizeof("endobj");
    --(*idx);
    
    return SEARCH_NEXT_PDF_STRUCTURE_STATE;
}

@end
