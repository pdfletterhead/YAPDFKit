//
//  YPObject.m
//  YAPDFKit
//
//  Created by Aliona on 19.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//  Modify by LiuQiang on 25-03-16
//  mail:liulcsy@163.com

#import "YPObject.h"
#import "YPArray.h"
#import "YPHexString.h"
#import "YPBool.h"
#import "YPDictionary.h"
#import "YPName.h"
#import "YPNumber.h"
#import "YPString.h"
#import "YPObjectReference.h"
#import "Utils.h"

@implementation YPObject
{
    const char * rawData;
    NSUInteger dataLength;
    size_t * index;
    NSMutableArray * contents;
    NSMutableDictionary * pdfContents;
}

@synthesize value, firstNumber, secondNumber, references, stream, dictionary;

- (id)initWithData :(NSData*)d first:(NSInteger*)first second:(NSInteger*)second 
{
    if (self = [super init]) {
        
        rawData = (const char *)[d bytes];
        dataLength = d.length;
        
        //pdfContents = documentContents;
        [self run];
        
        firstNumber = *first;
        secondNumber = *second;
        
        //references = [[NSMutableArray alloc] init];
        
        if([contents count] != 0) {
            value = [contents objectAtIndex:0];
        } else {
            NSLog(@"EMPTY OBJ %ld %ld",(long)firstNumber,(long)secondNumber);
        }
        
        return self;
    }
    
    NSLog(@"init with nil");
    return nil;
}

- (void)run
{
    index = 0;
    size_t i = 0;
    contents = [[NSMutableArray alloc] init];
    for (; i < dataLength; ++i) {
        NSObject *obj = [[NSObject alloc] init];
        obj = [self checkNextStruct:&i];
        if(obj) {
            [contents addObject:obj];
        }
    }
    index = &i;

}

- (NSObject *)checkNextStruct:(size_t *)idx
{
    size_t i = *idx;
    
    NSObject *structure;
    
    if (!(i < dataLength)) {
        return nil;
    }
    
    if (rawData[i] == '<') {
        if(rawData[i+1] == '<') {
            structure = [self checkDict:&i];
        } else {
            structure = [self checkBinaryString:&i];
        }
    } else if (rawData[i] == '[') {
        structure = [self checkArray:&i];
    } else if (rawData[i] == '(') {
        structure = [self checkString:&i];
    } else if (rawData[i] == '/') {
        structure = [self checkName:&i];
    } else if (isNum(rawData[i]) || rawData[i] == '+' || rawData[i] == '-') {
        structure = [self checkNum:&i];
    } else if (rawData[i] == 't' || rawData[i] == 'f') {
        structure = [self checkBool:&i];
    } else if (rawData[i] == 's') {

        stream = [self checkStream:&i];
        
        
    } else if (isBlank(rawData[i])) {
        skipBlankSymbols(rawData, &i);

        [self checkNextStruct:&i];
    }
    
    *idx = i;

    return structure;
}

- (NSDictionary *)checkDict:(size_t *)idx
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    size_t i = *idx;
    i += 2;
    
    for(; i < dataLength; ++i) {
        
        NSString *key = nil;
        NSObject *obj = nil;
        
        skipBlankSymbols(rawData, &i);
        
        if (rawData[i] == '>' && i+1 < dataLength && rawData[i+1] == '>') {
            ++i;
            break;
        }
        
        if (rawData[i] == '/') {
            key = [self checkName:&i
                   ];
        }
        
        skipBlankSymbols(rawData, &i);

        obj = [self checkNextStruct:&i];
        
        if(key && obj) {
            [dict setObject:obj forKey:key];
        }
    }
    
    *idx = i;

    dictionary = [[YPDictionary alloc] initWithDictionary:(NSDictionary*)dict];
    
    return (NSDictionary*)dict;
}

- (NSArray *)checkArray:(size_t *)idx
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    size_t i = *idx;
    ++i;
    
    for(; i < dataLength; ++i) {
        
        NSObject *obj = nil;
        skipBlankSymbols(rawData, &i);
        
        if (rawData[i] == ']' && rawData[i-1] != '\\') {
            break;
        }
        
        obj = [self checkNextStruct:&i];

        if(obj) {
            [array addObject:obj];
        }
    }
    
    YPArray *pdfArray = (YPArray*)array;
    *idx = i;
    return pdfArray;
}

- (YPBool *)checkBool:(size_t *)idx
{
    YPBool *b = [[YPBool alloc] init];
    NSUInteger i = *idx;
    
    if (i+4 < dataLength) {
        char buffer[] = {rawData[i], rawData[i+1], rawData[i+2], rawData[i+3], 0};
        if([@(buffer) isEqualToString:@"fals"] && i+5 < dataLength && rawData[i+4] == 'e') {
            b.value = NO;
            i = i+4;
        } else if ([@(buffer) isEqualToString:@"true"]) {
            b.value = YES;
            i = i+3;
        }
    }
    
    *idx = i;
    return b;
}

- (YPHexString *)checkBinaryString:(size_t *)idx
{
    NSString *str = @"";
    YPHexString *binary;
    NSUInteger i = *idx;
    ++i;
    
    for (; i > 0 && i < dataLength; ++i) {
        if(rawData[i] == '>') {
            break;
        }
        if (!isHexSymbol(rawData[i])) {
            return nil; //error "Hex string contains non-hex symbols"
        }
        char buffer[] = {rawData[i], 0};
        str = [str stringByAppendingString:@(buffer)];
    }
    
    // если в строке нечетное количество символов,
    // подразумевается, что последний символ "0"
    if ([str length] % 2) {
        str = [str stringByAppendingString:@"0"];
    }
    
    *idx = i;
    binary = (YPHexString *)str;
    
    return binary;
}

- (YPString *)checkString:(size_t *)idx
{
    NSString *str = @"";
    YPString *pdfString;
    NSUInteger i = *idx;
    NSUInteger brackets = 0;
    ++i;
    
    for (; i < dataLength; ++i) {
        if (rawData[i] == '(' && rawData[i-1] != '\\') {
            brackets++;
        } else if (brackets && rawData[i] == ')') {
            brackets--;
        } else if(rawData[i] == ')' && !brackets && rawData[i-1] != '\\') {
            break;
        }
        char buffer[] = {rawData[i], 0};
        if (@(buffer)) { 
            str = [str stringByAppendingString:@(buffer)];
        }
    }
    
    *idx = i;
    pdfString = (YPString *)str;
    return pdfString;
}

- (YPName *)checkName:(size_t *)idx
{
    NSString *name = @"";
    YPName *pdfName;
    NSUInteger i = *idx;
    ++i;
    
    for (; i < dataLength && !isBlank(rawData[i]) && rawData[i]!='>' && rawData[i]!='/'; ++i) {
        char buffer[] = {rawData[i], 0};
        name = [name stringByAppendingString:@(buffer)];
    }
    
    *idx = i;
    pdfName = (YPName *)name;
    return pdfName;
}

- (id)checkNum:(size_t *)idx
{
    NSString *num = @"";
    NSString *secondNum = @"";
    NSUInteger i = *idx;
    BOOL isReal = NO;
    
    do {
        if (rawData[i] == '.') {
            if(isReal) {
                return nil; // error "Incorrect number syntax: two dots in a number."
            }
            isReal = YES;
        }
        char buffer[] = {rawData[i], 0};
        num = [num stringByAppendingString:@(buffer)];
        ++i;
    } while ( i < dataLength && (isNum(rawData[i]) || rawData[i] == '.'));

    if (i+3< dataLength && isBlank(rawData[i]) && isNum(rawData[i+1]) && isBlank(rawData[i+2]) && rawData[i+3] == 'R') {
        char buffer[] = {rawData[i+1], 0};
        secondNum = [secondNum stringByAppendingString:@(buffer)];
        YPObjectReference *objRef = [self objRef:num:secondNum];
        i += 3;
        *idx = i;
        return objRef;
    }
    
    --i;
    *idx = i;
    
    YPNumber *pdfNum = [[YPNumber alloc] init];
    if(isReal) {
        float f = [num floatValue];
        [pdfNum initWithReal:f];
    } else {
        NSUInteger igr = [num integerValue];
        [pdfNum initWithInt:igr];
    }
    
    return pdfNum;
}

- (YPObjectReference *)objRef:(NSString *)firstNum :(NSString *)secondNum
{
    YPObjectReference *ref = [[YPObjectReference alloc]initWithNum:firstNum:secondNum];
    NSString *refNum = [ref getReferenceNumber];
    if (!references) {
        references = [[NSMutableDictionary alloc] init];
    }
    [references setObject:refNum forKey:refNum];
    return ref;
}


- (YPObjectStream *)checkStream:(size_t *)idx
{
    NSUInteger i = *idx;
    
    const char *b = NULL;
    if (i+5 < dataLength) {
        char buffer[] = {rawData[i], rawData[i+1], rawData[i+2], rawData[i+3], rawData[i+4], rawData[i+5],0};
        if (![@(buffer)isEqualToString:@"stream"]){
            return nil; //error
        }
        i += 5;
        b = &rawData[i+2];
    }
    
    const char* e = NULL;
    for(; i < dataLength; ++i) {
        if (rawData[i] == 'e' && rawData[i-1] != '/' && i+8 < dataLength) {
            char buffer[] = {rawData[i], rawData[i+1], rawData[i+2], rawData[i+3], rawData[i+4], rawData[i+5], rawData[i+6], rawData[i+7], rawData[i+8], 0};
           
            /* This check must be activated
             if (![@(buffer)isEqualToString:@"endstream"]){
                return nil; //error
            }
            */

            if ([@(buffer)isEqualToString:@"endstream"]){
                e = &rawData[i-1];
                break;
            }
        }
    }
    
    YPObjectStream * returnStream = [[YPObjectStream alloc] initWithData:[NSData dataWithBytes:b length:e - b]];

    i += 8;
    *idx = i;
    return returnStream;
}

/// METHODS AVAILABLE AFTER PARSING
/// -------------------------------

- (YPObjectStream *)getStreamObject {
    return stream;
}


- (NSArray*)getContents {
    return contents;
}

- (id)getObjectForKeyInDict:(NSString*)key
{
    id info = nil;
    id objectValue = [self value];
    if ([objectValue isKindOfClass:[NSDictionary class]] && [objectValue objectForKey:key]) {
        info = [objectValue objectForKey:key];
    }
    return info;
}

- (NSString *)getObjectNumber
{
    NSString *num = @"";
    
    NSString *first = [NSString stringWithFormat:@"%ld",(long)firstNumber];
    NSString *second = [NSString stringWithFormat:@"%ld",(long)secondNumber];
    num = [num stringByAppendingString:first];
    num = [num stringByAppendingString:@" "];
    num = [num stringByAppendingString:second];
    
    return num;
}

- (id)getValueByName:(NSString *)n
{
    NSObject *obj = [[NSObject alloc] init];
    if ([value isKindOfClass:[YPDictionary class]] && [value objectForKey:n]) {
        
    }
    return obj;
}

// You should not use this is for update tasks as the content gets corrupts
- (NSString*)getUncompressedStreamContents
{
    if(stream)
    {
        NSString *filter = [dictionary objectForKey:@"Filter"];
        return [[self stream] getDecompressedDataAsString:filter];
    }
    
    return nil;
}

- (NSData*)getUncompressedStreamContentsAsData
{
    //filter may be array
    NSString *flateDecode = nil;
    if(stream)
    {
        id filter = [dictionary objectForKey:@"Filter"];
        
        if ([filter isKindOfClass:[NSString class]]) {
              flateDecode = filter;
        }
        if ([filter isKindOfClass:[NSArray class]]) {
             flateDecode = filter[0];
        }
        return [[self stream] getDecompressedData:flateDecode];
    }
    return nil;
}

- (void) setStreamContentsWithData:(NSData*)data
{
    [dictionary removeObjectForKey:@"Filter"];
    stream = [[YPObjectStream alloc] initWithData:data andFilter:@"None"];
}

- (NSData*) createObjectDataBlock
{
    NSString* startstring =[@"" stringByAppendingFormat:@"%@ obj\n",[self getObjectNumber]];
    NSData*startData =[startstring dataUsingEncoding:NSASCIIStringEncoding];
    
    NSMutableData* blockData = [[NSMutableData alloc] initWithData:startData];
    
    if(dictionary)
    {
        //if stream set of replace length
        if(stream)
        {
            [dictionary setObject:[NSNumber numberWithInt:(int)[stream length]] forKey:@"Length"];
            
            // For now we do not support Filters for created blocks, so we'll remove the key
            [dictionary removeObjectForKey:@"Filter"];
        }

        [blockData appendData:[[dictionary stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if(stream)
        {
            [blockData appendData:[@"stream\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [blockData appendData:[self getUncompressedStreamContentsAsData]];
            [blockData appendData:[@"endstream\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    [blockData appendData:[@"endobj\n" dataUsingEncoding:NSUTF8StringEncoding]];
    return (NSData*)blockData;
}

@end