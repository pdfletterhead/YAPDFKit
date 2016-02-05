//
//  PDFObject.m
//  Parser
//
//  Created by Aliona on 19.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import "PDFObject.h"
#import "PDFArray.h"
#import "PDFHexString.h"
#import "PDFBool.h"
#import "PDFDictionary.h"
#import "PDFName.h"
#import "PDFNumber.h"
#import "PDFString.h"
#import "PDFObjectReference.h"
#import "PDFStreamDecoder.h"
#import "Utils.h"
#include "pdf.h"


@implementation PDFObject
{
    const char * rawData;
    NSUInteger dataLength;
    NSUInteger * index;
    NSMutableArray * contents;
   // NSMutableDictionary * pdfContents;
}

@synthesize value, firstNumber, secondNumber, stream, references;

- (id)initWithData :(NSData*)d first:(NSInteger*)first second:(NSInteger*)second 
{
    if (self = [super init]) {

        //NSLog(@"hhm: ===========\n%s\n----------------------", d.bytes);
        
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
    NSUInteger i = 0;
    contents = [[NSMutableArray alloc] init];
    for (; i < dataLength; ++i) {
        NSObject *obj = [[NSObject alloc] init];
        obj = [self checkNextStruct:&i];
        if(obj) {
            [contents addObject:obj];
            //[obj dealloc];
        }
    }
    index = &i;
    //NSLog(@"%@",contents);
}

- (NSObject *)checkNextStruct:(NSUInteger *)idx
{
    NSUInteger i = *idx;
    
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
        structure = [self checkStream:&i];
        if(structure) {
            //stream = (NSData *)structure;
            PDFStreamDecoder *decrypt = [[PDFStreamDecoder alloc] initWithData:stream];
            stream = [decrypt getDecrypted];
        }
    } else if (isBlank(rawData[i])) {
        skipBlankSymbols(rawData, &i);
        [self checkNextStruct:&i];
    }
    
    *idx = i;
    return structure;
}

- (NSDictionary *)checkDict:(NSUInteger *)idx
{
    PDFDictionary *pdfDict = [[PDFDictionary alloc] init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSUInteger i = *idx;
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
  //  NSLog(@"Dictionary %@", dict);
    pdfDict = (PDFDictionary *)dict;
    return pdfDict;
}

- (NSArray *)checkArray:(NSUInteger *)idx
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSUInteger i = *idx;
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
    
    PDFArray *pdfArray = (PDFArray*)array;
    *idx = i;
   // NSLog(@"Array %@", array);
    return pdfArray;
}

- (PDFBool *)checkBool:(NSUInteger *)idx
{
    PDFBool *b = [[PDFBool alloc] init];
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
    // NSLog(@"boooool %@",str);
    return b;
}

- (PDFHexString *)checkBinaryString:(NSUInteger *)idx
{
    NSString *str = @"";
    PDFHexString *binary;
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
    binary = (PDFHexString *)str;
    
    return binary;
}

- (PDFString *)checkString:(NSUInteger *)idx
{
    NSString *str = @"";
    PDFString *pdfString;
    NSUInteger i = *idx;
    NSUInteger brackets = 0;
    ++i;
    
    for (; i < dataLength; ++i) {
        // Может содержать в себе не экранированные скобки,
        // но скобки должны закрываться в этом случае ()
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
    pdfString = (PDFString *)str;
   // NSLog(@"Textstring %@",str);
    return pdfString;
}

- (PDFName *)checkName:(NSUInteger *)idx
{
    NSString *name = @"";
    PDFName *pdfName;
    NSUInteger i = *idx;
    ++i;
    
    for (; i < dataLength && !isBlank(rawData[i]); ++i) {
        char buffer[] = {rawData[i], 0};
        name = [name stringByAppendingString:@(buffer)];
    }
    
    *idx = i;
   // NSLog(@"Name %@",name);
    pdfName = (PDFName *)name;
    return pdfName;
}

- (id)checkNum:(NSUInteger *)idx
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
        PDFObjectReference *objRef = [self objRef:num:secondNum];
        i += 3;
        *idx = i;
        return objRef;
    }
    
    --i;
    *idx = i;
    
    PDFNumber *pdfNum = [[PDFNumber alloc] init];
    if(isReal) {
        float f = [num floatValue];
        [pdfNum initWithReal:f];
    } else {
        NSUInteger igr = [num integerValue];
        [pdfNum initWithInt:igr];
    }
    
    return pdfNum;
}

- (PDFObjectReference *)objRef:(NSString *)firstNum :(NSString *)secondNum
{
    PDFObjectReference *ref = [[PDFObjectReference alloc]initWithNum:firstNum:secondNum];
    NSString *refNum = [ref getReferenceNumber];
    if (!references) {
        references = [[NSMutableDictionary alloc] init];
    }
    [references setObject:refNum forKey:refNum];
    return ref;
}


- (NSData *)checkStream:(NSUInteger *)idx
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
            if ([@(buffer)isEqualToString:@"endstream"]){
                e = &rawData[i-1];
                break;
            }
        }
    }
    
    NSMutableData *data = [NSData dataWithBytes:b length:e - b];
    //stream = (NSData *)data;
    printf("\n\nB--------\n");
    
    //dumpCharArray(data.bytes, data.length);
    NSString * found = convertStream(data);
    //printf(@"string: %s",found);
    printf("\nE--------\n\n");

    i += 8;
    *idx = i;
    
    return data;
}

- (NSData *)checkStreamWorking:(NSUInteger *)idx
{
    NSUInteger i = *idx;
    
    const char *b = NULL;
    if (i+5 < dataLength) {
        char buffer[] = {rawData[i], rawData[i+1], rawData[i+2], rawData[i+3], rawData[i+4], rawData[i+5],0};
        if (![@(buffer)isEqualToString:@"stream"]){
            return nil; //error
        }
        i += 5;
        b = &rawData[i-10];
    }
    
    const char* e = NULL;
    for(; i < dataLength; ++i) {
        if (rawData[i] == 'e' && rawData[i-1] != '/' && i+8 < dataLength) {
            char buffer[] = {rawData[i], rawData[i+1], rawData[i+2], rawData[i+3], rawData[i+4], rawData[i+5], rawData[i+6], rawData[i+7], rawData[i+8], 0};
            if ([@(buffer)isEqualToString:@"endstream"]){
                e = &rawData[i];
                break;
            }
        }
    }
    
    NSMutableData *data = [NSData dataWithBytes:b length:e - b + 20];
    stream = (NSData *)data;
    //NSLog(@"stream: %s",data.bytes);
    NSString * found = findAndConvertStream(data);
    //NSLog(@"string: %s",found);
    
    i += 8;
    *idx = i;
    
    return data;
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
    if ([value isKindOfClass:[PDFDictionary class]] && [value objectForKey:n]) {
        
    }
    return obj;
}
@end
