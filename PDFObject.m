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

#include "zlib.h"

BOOL debug2 = NO;


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
        rawData = (const char *)[d bytes];
        dataLength = d.length;

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
    
    if(debug2)
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
    
    if(debug2)
        NSLog(@"\nrun: %@",contents);
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
//            NSLog(@"structure: %@",structure);
            NSData *str = structure;
            unsigned char *bytePtr = (unsigned char *)[str bytes];
            //NSLog(@"raw1: \n%s", bytePtr);
            

            
         
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            //          NSString* newStr = [[NSString alloc] initWithData:str encoding:NSUTF8StringEncoding];
  //          NSLog(@"data: %@", newStr);



            
//            stream = (NSData *)structure;
            PDFStreamDecoder *decrypt = [[PDFStreamDecoder alloc] initWithData:str];
            
            //stream = [decrypt getDecrypted];
            //NSLog(@"stream: %@, structure: ---",stream);
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
    if(debug2)
        NSLog(@"\nDictionary %@", dict);
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
    if(debug2)
        NSLog(@"\nArray %@", array);
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
    if(debug2)
        NSLog(@"boooool %@",b);
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
    if(debug2)
        NSLog(@"Textstring %@",str);
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
   
    if(debug2)
        NSLog(@"Name %@",name);
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


- (NSData *)checkStream3:(NSUInteger *)idx
{
    
    char rawDataEnd[] = {
        rawData[dataLength-18],
        rawData[dataLength-17],
        rawData[dataLength-16],
        rawData[dataLength-15],
        rawData[dataLength-14],
        rawData[dataLength-13],
        rawData[dataLength-12],
        rawData[dataLength-11],
        rawData[dataLength-10],
        rawData[dataLength-9],
        rawData[dataLength-8],
        rawData[dataLength-7],
        rawData[dataLength-6],
        rawData[dataLength-5],
        rawData[dataLength-4],
        rawData[dataLength-3],
        rawData[dataLength-2],
        rawData[dataLength-1],
        rawData[dataLength-0],
        0};
        NSLog(@"\n\nrawDataEnd: %sXXX",rawDataEnd);
    
    NSUInteger i = *idx; //I-UP
    NSUInteger ii = i;
    
    const char *b = NULL;
    const char *bb = NULL;
    
    if (i+5 < dataLength) {
        char buffer[] = {rawData[i], rawData[i+1], rawData[i+2], rawData[i+3], rawData[i+4], rawData[i+5],0};
        //NSLog(@"buffer: %s", buffer);
        if (![@(buffer)isEqualToString:@"stream"]){
            return nil; //error
        }
        i += 5; //I-UP
        b = &rawData[i+1];
        
    }
    
    const char* e = NULL;
    const char* ee = NULL;

    for(; i < dataLength; ++i) { //I-UP
        
        if (rawData[i] == 'e' && rawData[i-1] != '/' && i+8 < dataLength) {
            NSLog(@"buffere: %s",&rawData[i]);

            char buffer[] = {rawData[i], rawData[i+1], rawData[i+2], rawData[i+3], rawData[i+4], rawData[i+5], rawData[i+6], rawData[i+7], rawData[i+8], 0};
            if ([@(buffer)isEqualToString:@"endstream"]){
                NSLog(@"buffer: %s", buffer);
                e = &rawData[i];
                ee = &rawData[i-9];
                NSLog(@"buffer: %s",rawData[i-20]);
                break;
            }
        }
    }
    
    NSUInteger dataLength2 = e - b;
    NSUInteger dataLength3 = ee - b + 10;
    bb = &rawData[ii];
    //printf("p: %s\n",bb);
    
    NSData *data2 = [NSData dataWithBytes:bb length:dataLength3];
    unsigned char *b3 = (unsigned char *)[data2 bytes];
    NSLog(@"yyy%s", b3);
    char b3en[] = {b3[dataLength3],b3[dataLength3-1],0};
    //NSLog(@"yyy%s", b3en);

    //Search for stream, endstream. We ought to first check the filter
    //of the object to make sure it if FlateDecode, but skip that for now!
    size_t streamstart = FindStringInBuffer (rawData, "stream", dataLength);
    size_t streamend   = FindStringInBuffer (rawData, "endstream", dataLength);

    if (streamstart>0 && streamend>streamstart)
    {
        NSLog(@"agllo2");
        //Skip to beginning and end of the data stream:
        streamstart += 6;
        
        if (bb[streamstart]==0x0d && bb[streamstart+1]==0x0a) streamstart+=2;
        else if (bb[streamstart]==0x0a) streamstart++;
        
        if (bb[streamend-2]==0x0d && bb[streamend-1]==0x0a) streamend-=2;
        else if (bb[streamend-1]==0x0a) streamend--;
        
        //Assume output will fit into 10 times input buffer:
        size_t outsize = (streamend - streamstart)*10;
        char *output = malloc(outsize*sizeof(char)); //Allocates the output
        ZeroMemory(output, outsize);
        
        //Now use zlib to inflate:
        z_stream zstrm;
        ZeroMemory(&zstrm, sizeof(zstrm));
        
        zstrm.avail_in = streamend - streamstart + 1;
        zstrm.avail_out = outsize;
        zstrm.next_in = (Bytef*)(bb + streamstart);
        zstrm.next_out = (Bytef*)output;
        
        int rsti = inflateInit(&zstrm);
        if (rsti == Z_OK)
        {
            int rst2 = inflate (&zstrm, Z_FINISH);
            if (rst2 >= 0)
            {
                //Ok, got something, extract the text:
                size_t totout = zstrm.total_out;
                //NSLog(@"xxxx%s", output);

                //ProcessOutput(output, totout);
            }
        }
        free(output);
        output=0;
        bb+= streamend + 7;
        //filelen = filelen - (streamend+7);
    }
    
    
    
    
    
    i += 8; //I-UP
    *idx = i;
    
    NSData *data = [NSData dataWithBytes:b length:dataLength2+1];
    unsigned char *b2 = (unsigned char *)[data bytes];
    //NSLog(@"%s", b2);
    return data;
}


void ZeroMemory(void * buffer, long sizeOf)
{
    //memcpy(buffer, 0, sizeof(buffer));
    memset(buffer, 0, sizeOf);
    
}


//Find a string in a buffer:
size_t FindStringInBuffer (char* buffer, char* search, size_t buffersize)
{
    NSLog(@"search %s",buffer);
    char* buffer0 = buffer;
    
    size_t len = strlen(search);
    bool fnd = false;
    while (!fnd)
    {
        fnd = true;
        for (size_t i=0; i<len; i++)
        {
            if (buffer[i]!=search[i])
            {
                fnd = false;
                break;
            }
        }
        if (fnd) return buffer - buffer0;
        buffer = buffer + 1;
        if (buffer - buffer0 + len >= buffersize) return -1;
    }
    return -1;
}


- (NSData *)checkStream:(NSUInteger *)idx
{
    

    NSUInteger i = *idx;



    
    
    const char *b = NULL;
    if (i+5 < dataLength) {
        char buffer[] = {rawData[i], rawData[i+1], rawData[i+2], rawData[i+3], rawData[i+4], rawData[i+5],0};
        //NSLog(@"buffer: %s", buffer);
        if (![@(buffer)isEqualToString:@"stream"]){
            return nil; //error
        }
        i += 5;
        b = &rawData[i];
    }
    
    const char* e = NULL;
    for(; i < dataLength; ++i) {
        if (rawData[i] == 'e' && rawData[i-1] != '/' && i+8 < dataLength) {
            char buffer[] = {rawData[i], rawData[i+1], rawData[i+2], rawData[i+3], rawData[i+4], rawData[i+5], rawData[i+6], rawData[i+7], rawData[i+8], 0};
            if ([@(buffer)isEqualToString:@"endstream"]){
                //NSLog(@"buffer: %s", buffer);
                e = &rawData[i];
                //end_i = i;
                
                break;
            }
        }
    }
 
    char new_array[] = { 0x01, 0x00, 0xFF };
    memcpy(new_array, rawData, sizeof(rawData));
    
    //memcpy(new_array, rawData, 200);

    //NSLog(@"new_array: %s", new_array);

    //memcpy(new_array, rawData, sizeof(rawData));
    
    //Search for stream, endstream. We ought to first check the filter
    //of the object to make sure it if FlateDecode, but skip that for now!
    size_t streamstart = FindStringInBuffer (new_array, "stream", dataLength);
    size_t streamend   = FindStringInBuffer (new_array, "endstream", dataLength);
    
    if (streamstart>0 && streamend>streamstart)
    {
        NSLog(@"agllo2");
        ZeroMemory(new_array, sizeof(new_array));

        NSLog(@"new_array: %s", new_array);

        //Skip to beginning and end of the data stream:
        streamstart += 6;
        
        if (new_array[streamstart]==0x0d && new_array[streamstart+1]==0x0a) streamstart+=2;
        else if (new_array[streamstart]==0x0a) streamstart++;
        
        if (new_array[streamend-2]==0x0d && new_array[streamend-1]==0x0a) streamend-=2;
        else if (new_array[streamend-1]==0x0a) streamend--;
        
        //Assume output will fit into 10 times input buffer:
        size_t outsize = (streamend - streamstart)*10;
        char *output = malloc(outsize*sizeof(char)); //Allocates the output
        ZeroMemory(output, outsize);
        
        //Now use zlib to inflate:
        z_stream zstrm;
        ZeroMemory(&zstrm, sizeof(zstrm));
        
        zstrm.avail_in = streamend - streamstart + 1;
        zstrm.avail_out = outsize;
        zstrm.next_in = (Bytef*)(new_array + streamstart);
        zstrm.next_out = (Bytef*)output;
        
        int rsti = inflateInit(&zstrm);
        if (rsti == Z_OK)
        {
            int rst2 = inflate (&zstrm, Z_FINISH);
            if (rst2 >= 0)
            {
                //Ok, got something, extract the text:
                size_t totout = zstrm.total_out;
                NSLog(@"xxxx%s", output);
                
                //ProcessOutput(output, totout);
            }
        }
        free(output);
        output=0;
        //new_array+= streamend + 7;
        //filelen = filelen - (streamend+7);
    }
    
    

    
  //  NSData *data = [NSData dataWithBytes:b length:dataLength+1];

    
    i += 8;
    *idx = i;

    return nil;
//    return data;
}


- (NSData *)checkStream2:(NSUInteger *)idx
{

    char rawDataEnd[] = {
        rawData[dataLength-18],
        rawData[dataLength-17],
        rawData[dataLength-16],
        rawData[dataLength-15],
        rawData[dataLength-14],
        rawData[dataLength-13],
        rawData[dataLength-12],
        rawData[dataLength-11],
        rawData[dataLength-10],
        rawData[dataLength-9],
        rawData[dataLength-8],
        rawData[dataLength-7],
        rawData[dataLength-6],
        rawData[dataLength-5],
        rawData[dataLength-4],
        rawData[dataLength-3],
        rawData[dataLength-2],
        rawData[dataLength-1],
        rawData[dataLength-0],
        0};
 //    NSLog(@"\n\nrawDataEnd: %sXXX",rawDataEnd);
 //   NSLog(@"\n\nrawDataBegin: %s\n\n", rawData);

    NSUInteger i = *idx;

    NSUInteger start_i = 0;
    NSUInteger end_i = 0;
    
    const char *b = NULL;
    if (i+5 < dataLength) {
        char buffer[] = {rawData[i], rawData[i+1], rawData[i+2], rawData[i+3], rawData[i+4], rawData[i+5],0};
        //NSLog(@"buffer: %s", buffer);
        if (![@(buffer)isEqualToString:@"stream"]){
            return nil; //error
        }
        i += 5;
        start_i = i;
        b = &rawData[i+1];
        
    }
    
    const char* e = NULL;
    for(; i < dataLength; ++i) {
        if (rawData[i] == 'e' && rawData[i-1] != '/' && i+8 < dataLength) {
            char buffer[] = {rawData[i], rawData[i+1], rawData[i+2], rawData[i+3], rawData[i+4], rawData[i+5], rawData[i+6], rawData[i+7], rawData[i+8], 0};
            if ([@(buffer)isEqualToString:@"endstream"]){
                //NSLog(@"buffer: %s", buffer);
                e = &rawData[i-2];
                end_i = i;
                
                //NSLog(@"buffer: %s\nend: %s\ni%lu:",buffer, e, (unsigned long)i);
                break;
            }
        }
    }
    
    NSUInteger dataLength2 = e - b;
    
    const UInt8 *bytes = (const UInt8 *)b;
    if(bytes[0] == 0x1f && bytes[1] == 0x8b)
    {
        NSLog(@"it's a gzip");
    } else
    {
        //NSLog(@"it's NOT a gzip");
    }
    
    NSData *data = [NSData dataWithBytes:b length:dataLength2+1];
    unsigned char *b2 = (unsigned char *)[data bytes];
    
    i += 8;
    *idx = i;
    
   // NSLog(@"\n\nreturnRawDataBegin: %s\n", b);
   // NSLog(@"\n\nreturnNSDataBegin: %s\n", b2);
    
    char returnDataEnd[] = {
        b[dataLength2-18],
        b[dataLength2-17],
        b[dataLength2-16],
        b[dataLength2-15],
        b[dataLength2-14],
        b[dataLength2-13],
        b[dataLength2-12],
        b[dataLength2-11],
        b[dataLength2-10],
        b[dataLength2-9],
        b[dataLength2-8],
        b[dataLength2-7],
        b[dataLength2-6],
        b[dataLength2-5],
        b[dataLength2-4],
        b[dataLength2-3],
        b[dataLength2-2],
        b[dataLength2-1],
        b[dataLength2-0],
        0};
    
    char returnNSDataEnd[] = {
        b2[dataLength2-18],
        b2[dataLength2-17],
        b2[dataLength2-16],
        b2[dataLength2-15],
        b2[dataLength2-14],
        b2[dataLength2-13],
        b2[dataLength2-12],
        b2[dataLength2-11],
        b2[dataLength2-10],
        b2[dataLength2-9],
        b2[dataLength2-8],
        b2[dataLength2-7],
        b2[dataLength2-6],
        b2[dataLength2-5],
        b2[dataLength2-4],
        b2[dataLength2-3],
        b2[dataLength2-2],
        b2[dataLength2-1],
        b2[dataLength2-0],
        0};

    
//    NSLog(@"\n\nreturnRawDataEnd: %sXXX",returnDataEnd);
//    NSLog(@"\n\nreturnNSDataEnd: %sXXX",returnNSDataEnd);
    
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
