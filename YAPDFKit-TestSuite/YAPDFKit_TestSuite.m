//
//  YAPDFKit_TestSuite.m
//  YAPDFKit-TestSuite
//
//  Created by Pim Snel on 11-02-16.
//  Copyright © 2016-2019 Lingewoud. All rights reserved.

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import "YPDocument.h"
#import "YPPages.h"
#import "YPObject.h"
#import "YPArray.h"
#import "YPBool.h"
#import "YPHexString.h"
#import "YPName.h"
#import "YPNumber.h"
#import "YPString.h"
#import "YPObjectReference.h"

@interface YAPDFKit_TestSuite : XCTestCase
@property YPDocument* document;
//- (void) setupDocumentCMethod:(NSString*)fileName;

@end

@implementation YAPDFKit_TestSuite

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (YPDocument *) setupDocumentCMethod:(NSString*)fileName {
    // open pdf in memory
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *pdfPath = [bundle pathForResource:fileName ofType:@"pdf"];
    
    if (pdfPath != nil) {
        
        //NSLog(@"pdf: %@", pdfPath);
        //Open the PDF source file:
        FILE* filei = fopen([pdfPath UTF8String], "rb");
        
        //Get the file length:
        int fseekres = fseek(filei,0, SEEK_END);   //fseek==0 if ok
        long filelen = ftell(filei);
        fseekres = fseek(filei,0, SEEK_SET);
        
        //Read the entire file into memory (!):
        char *buffer = malloc(filelen*sizeof(char)); //Allocates the buffer
        ZeroMemory(buffer, filelen);
        
        if (!fread(buffer, filelen, 1 ,filei)) {
            NSLog(@"Error, reading file!");
        }
        
        NSData* fileData = [NSData dataWithBytes:(const void *)buffer length:filelen];
        
        //        NSLog(@"data: %@",fileData);
        return [[YPDocument alloc] initWithData:fileData];
        
    } else {
        NSLog(@"Error, file not found!");
    }
    return nil;
}
- (YPDocument *) setupDocumentObCMethod:(NSString*)fileName {
    // open pdf in memory
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *pdfPath = [bundle pathForResource:fileName ofType:@"pdf"];
    
    if (pdfPath != nil) {
        
        NSData *fileData = [NSData dataWithContentsOfFile:pdfPath];
        //        NSLog(@"data: %@",fileData);
        return [[YPDocument alloc] initWithData:fileData];
        
    } else {
        NSLog(@"Error, file not found!");
    }
    return nil;
}



/*
 * Тест для ссылок на объект
 * Test object references
 */
- (void)testObjectReferenceParsing
{
    char example[] = "325 0 R";
    NSData *exampleData = [NSData dataWithBytes:example length:sizeof(example)];
    NSInteger first, second;
    YPObject *obj = [[YPObject alloc] initWithData:exampleData first:&first second:&second];
    
    XCTAssert([obj.value isKindOfClass:[YPObjectReference class]], @"Failed to parse object reference");
    YPObjectReference *ref = obj.value;
    XCTAssert([[ref getReferenceNumber] isEqualToString:@"325 0"], @"Wrong reference number in object reference");
}

/*
 * Тест для имен
 */
- (void)testObjectNameParsing
{
    char example[] = "/TestName";
    NSData *exampleData = [NSData dataWithBytes:example length:sizeof(example)];
    NSInteger first, second;
    YPObject *obj = [[YPObject alloc] initWithData:exampleData first:&first second:&second];
    XCTAssert([obj.value isKindOfClass:[NSString class]], @"Failed to parse PDF name");
    YPName *name = obj.value;
    XCTAssert([name isEqualToString:@"TestName"], @"Wrong value of a name");
}

/*
 * Тест для bool
 */
- (void)testObjectBoolParsing
{
    char example[] = "true";
    NSData *exampleData = [NSData dataWithBytes:example length:sizeof(example)];
    NSInteger first, second;
    YPObject *obj = [[YPObject alloc] initWithData:exampleData first:&first second:&second];
    XCTAssert([obj.value isKindOfClass:[YPBool class]], @"Failed to parse PDF name");
    YPBool *b = obj.value;
    XCTAssert(b.value, @"Wrong value of a name");
}

/*
 * Тест для чисел с дробной частью
 */
- (void)testObjectFloatNumberParsing
{
    char example[] = "+325.0";
    NSData *exampleData = [NSData dataWithBytes:example length:sizeof(example)];
    NSInteger first, second;
    YPObject *obj = [[YPObject alloc] initWithData:exampleData first:&first second:&second];
    
    XCTAssert([obj.value isKindOfClass:[YPNumber class]], @"Failed to parse real number");
    YPNumber *num = obj.value;
    XCTAssert(num.real, @"Wrong type detected in real number");
    XCTAssertFalse(num.intValue, @"Int value detected in a float number");
    
    float f = 325.0;
    XCTAssertEqual(num.realValue, f, @"Wrong value of a float number");
    
}

/*
 * Тест для целых чисел
 */
- (void)testObjectIntNumberParsing
{
    char example[] = "-100";
    NSData *exampleData = [NSData dataWithBytes:example length:sizeof(example)];
    NSInteger first, second;
    YPObject *obj = [[YPObject alloc] initWithData:exampleData first:&first second:&second];
    
    XCTAssert([obj.value isKindOfClass:[YPNumber class]], @"Failed to parse int number");
    YPNumber *num = obj.value;
    XCTAssertFalse(num.real, @"Wrong type detected in int number");
    
    int i = -100;
    XCTAssertEqual(num.intValue, i, @"Wrong value of an int number");
    XCTAssertFalse(num.realValue, @"Float value detected in an int number");
}

/*
 * Тест для бинарных строк
 */
- (void)testObjectHexStringParsing
{
    char example[] = "<abcdef0123456789ABCDEF>";
    NSData *exampleData = [NSData dataWithBytes:example length:sizeof(example)];
    NSInteger first, second;
    YPObject *obj = [[YPObject alloc] initWithData:exampleData first:&first second:&second];
    XCTAssert([obj.value isKindOfClass:[NSString class]], @"Failed to parse hexstring");
    XCTAssert([obj.value isEqualToString:@"abcdef0123456789ABCDEF"], @"Failed to parse hexstring value");
}

/*
 * Тест для строк
 */
- (void)testObjectStringParsing
{
    char example[] = "(String)";
    NSData *exampleData = [NSData dataWithBytes:example length:sizeof(example)];
    NSInteger first, second;
    YPObject *obj = [[YPObject alloc] initWithData:exampleData first:&first second:&second];
    
    XCTAssert([obj.value isKindOfClass:[NSString class]], @"Failed to parse string");
    NSString *str = obj.value;
    XCTAssert([str isEqualToString:@"String"], @"Failed to parse string value");
    
    char example1[] = "(String(with)brackets)";
    NSData *exampleData1 = [NSData dataWithBytes:example1 length:sizeof(example1)];
    YPObject *obj1 = [[YPObject alloc] initWithData:exampleData1 first:&first second:&second];
    
    XCTAssert([obj1.value isKindOfClass:[NSString class]], @"Failed to parse string with brackets");
    NSString *str1 = obj1.value;
    XCTAssert([str1 isEqualToString:@"String(with)brackets"], @"Failed to parse string with brackets value");
    
    char example2[] = "(String\\(withbracket)";
    NSData *exampleData2 = [NSData dataWithBytes:example2 length:sizeof(example2)];
    YPObject *obj2 = [[YPObject alloc] initWithData:exampleData2 first:&first second:&second];
    
    XCTAssert([obj2.value isKindOfClass:[NSString class]], @"Failed to parse string with bracket (");
    NSString *str2 = obj2.value;
    XCTAssert([str2 isEqualToString:@"String\\(withbracket"], @"Failed to parse string with bracket ( value");
    
    char example3[] = "(String\\)withbracket)";
    NSData *exampleData3 = [NSData dataWithBytes:example3 length:sizeof(example3)];
    YPObject *obj3 = [[YPObject alloc] initWithData:exampleData3 first:&first second:&second];
    
    XCTAssert([obj3.value isKindOfClass:[NSString class]], @"Failed to parse string with bracket )");
    NSString *str3 = obj3.value;
    XCTAssert([str3 isEqualToString:@"String\\)withbracket"], @"Failed to parse string with bracket ) value");
}

/*
 * Тест для массивов
 */
- (void)testObjectArrayParsing
{
    char example[] = "[/array +123 -115.5 123 0 R <</dict <</dict1 <</dict2 123>>>>>> [ 0 1 [ 2 3 [ 4 5 ] ] ] false";
    NSData *exampleData = [NSData dataWithBytes:example length:sizeof(example)];
    NSInteger first, second;
    YPObject *obj = [[YPObject alloc] initWithData:exampleData first:&first second:&second];
    
    XCTAssert([obj.value isKindOfClass:[NSArray class]], @"Failed to parse array");
    NSArray *arr = obj.value;
    
    XCTAssert([[arr objectAtIndex:0] isKindOfClass:[NSString class]], @"Failed to parse name in array");
    XCTAssert([[arr objectAtIndex:0] isEqualToString:@"array"], @"Failed to parse value of name in array");
    
    XCTAssert([[arr objectAtIndex:1] isKindOfClass:[YPNumber class]], @"Failed to parse number in array");
    XCTAssert([[arr objectAtIndex:1] intValue] == 123, @"Failed to parse value of integer in array");
    
    XCTAssert([[arr objectAtIndex:2] isKindOfClass:[YPNumber class]], @"Failed to parse number in array");
    XCTAssert([[arr objectAtIndex:2] realValue] == -115.5, @"Failed to parse value of float in array");
    
    XCTAssert([[arr objectAtIndex:3] isKindOfClass:[YPObjectReference class]], @"Failed to parse object reference in array");
    YPObjectReference *ref = [arr objectAtIndex:3];
    XCTAssert([[ref getReferenceNumber] isEqualToString:@"123 0"], @"Failed to detect reference number in array");
    
    XCTAssert([[arr objectAtIndex:4] isKindOfClass:[NSDictionary class]], @"Failed to parse dictionary in array");
    NSDictionary *dict = [arr objectAtIndex:4];
    XCTAssert([[dict objectForKey:@"dict"] isKindOfClass:[NSDictionary class]], @"Failed to parse dict in dictionary in array");
    NSDictionary *dict1 = [dict objectForKey:@"dict"];
    XCTAssert([[dict1 objectForKey:@"dict1"] isKindOfClass:[NSDictionary class]], @"Failed to parse dict1 in dictionary in array");
    NSDictionary *dict2 = [dict1 objectForKey:@"dict1"];
    XCTAssert([[dict2 objectForKey:@"dict2"] isKindOfClass:[YPNumber class]], @"Failed to parse number in dictionary in array");
    XCTAssert([[dict2 objectForKey:@"dict2"] intValue] == 123, @"Failed to parse number value in dictionary in array");
    
    XCTAssert([[arr objectAtIndex:5] isKindOfClass:[NSArray class]], @"Failed to parse array in array");
    NSArray *arr1 = [arr objectAtIndex:5];
    XCTAssert ([[arr1 objectAtIndex:2] isKindOfClass:[NSArray class]], @"Failed to parse arr1 in array");
    XCTAssert ([[arr1 objectAtIndex:2] isKindOfClass:[NSArray class]], @"Failed to parse arr2 in array");
    
    XCTAssert([[arr objectAtIndex:6] isKindOfClass:[YPBool class]], @"Failed to parse bool in array");
    YPBool *b = [arr objectAtIndex:6];
    XCTAssertFalse(b.value, @"Failed to parse bool value in array");
}

/*
 * Тест для словарей
 */
- (void)testObjectDictionaryParsing
{
    char example[] = "<</array [ 0 1 [ 2 3 [ 4 5 ] ] ] /integer +123 /real -115.5 /reference 123 0 R  /dictionary <</dict <</dict1 <</dict2 123>>>>>>  /bool_v false >>";
    NSData *exampleData = [NSData dataWithBytes:example length:sizeof(example)];
    NSInteger first, second;
    YPObject *obj = [[YPObject alloc] initWithData:exampleData first:&first second:&second];
    
    XCTAssert([obj.value isKindOfClass:[NSDictionary class]], @"Failed to parse dictionary");
    NSMutableDictionary *dict = obj.value;
    
    XCTAssert([[dict valueForKey:@"array"] isKindOfClass:[NSArray class]], @"Failed to parse array in dictionary");
    NSArray *arr = [dict valueForKey:@"array"];
    
    XCTAssert([[arr objectAtIndex:0] isKindOfClass:[YPNumber class]], @"Failed to parse array in dictionary value 0");
    XCTAssert([[arr objectAtIndex:0] intValue] == 0, @"Failed to parse array in dictionary value 0: incorrect value");
    XCTAssert([[arr objectAtIndex:1] isKindOfClass:[YPNumber class]], @"Failed to parse array in dictionary value 1");
    XCTAssert([[arr objectAtIndex:1] intValue] == 1, @"Failed to parse array in dictionary value 1: incorrect value");
    XCTAssert([[arr objectAtIndex:2] isKindOfClass:[NSArray class]], @"Failed to parse array in dictionary value 2");
    NSArray *arr1 = [arr objectAtIndex:2];
    XCTAssert([[arr1 objectAtIndex:0] isKindOfClass:[YPNumber class]], @"Failed to parse array1 in dictionary value 0");
    XCTAssert([[arr1 objectAtIndex:0] intValue] == 2, @"Failed to parse array1 in dictionary value 0: incorrect value");
    XCTAssert([[arr1 objectAtIndex:1] isKindOfClass:[YPNumber class]], @"Failed to parse array1 in dictionary value 1");
    XCTAssert([[arr1 objectAtIndex:1] intValue] == 3, @"Failed to parse array1 in dictionary value 1: incorrect value");
    XCTAssert([[arr1 objectAtIndex:2] isKindOfClass:[NSArray class]], @"Failed to parse array1 in dictionary value 2");
    NSArray *arr2 = [arr1 objectAtIndex:2];
    XCTAssert([[arr2 objectAtIndex:0] isKindOfClass:[YPNumber class]], @"Failed to parse array2 in dictionary value 0");
    XCTAssert([[arr2 objectAtIndex:0] intValue] == 4, @"Failed to parse array2 in dictionary value 0: incorrect value");
    XCTAssert([[arr2 objectAtIndex:1] isKindOfClass:[YPNumber class]], @"Failed to parse array2 in dictionary value 1");
    XCTAssert([[arr2 objectAtIndex:1] intValue] == 5, @"Failed to parse array2 in dictionary value 1: incorrect value");
    
    XCTAssert([[dict valueForKey:@"integer"] isKindOfClass:[YPNumber class]], @"Failed to parse integer in dictionary");
    NSLog(@"%@", [dict valueForKey:@"integer"]);
    NSLog(@"%@", [dict valueForKey:@"real"]);
    NSLog(@"%@", [dict valueForKey:@"reference"]);
    XCTAssert([[dict valueForKey:@"integer"] intValue] == 123, @"Failed to parse integer value in dictionary");
    
    XCTAssert([[dict valueForKey:@"real"] isKindOfClass:[YPNumber class]], @"Failed to parse float number in dictionary");
    XCTAssertEqual([[dict valueForKey:@"real"] realValue], -115.5, @"Failed to parse float number value in dictionary");
    
    XCTAssert([[dict valueForKey:@"reference"] isKindOfClass:[YPObjectReference class]], @"Failed to parse object reference in dictionary");
    XCTAssert([[[dict valueForKey:@"reference"] getReferenceNumber] isEqual:@"123 0"], @"Failed to parse object reference number in dictionary");
    
    XCTAssert([[dict valueForKey:@"dictionary"] isKindOfClass:[NSDictionary class]], @"Failed to parse dictionary in dictionary");
    NSDictionary *dict1 = [dict valueForKey:@"dictionary"];
    XCTAssert([[dict1 valueForKey:@"dict"] isKindOfClass:[NSDictionary class]], @"Failed to parse dictionary1 in dictionary");
    NSDictionary *dict2 = [dict1 valueForKey:@"dict"];
    XCTAssert([[dict2 valueForKey:@"dict1"] isKindOfClass:[NSDictionary class]], @"Failed to parse dictionary2 in dictionary");
    NSDictionary *dict3 = [dict2 valueForKey:@"dict1"];
    XCTAssert([[dict3 valueForKey:@"dict2"] isKindOfClass:[YPNumber class]], @"Failed to parse dictionary3 in dictionary");
    XCTAssert([[dict3 valueForKey:@"dict2"] intValue] == 123, @"Failed to parse value in final dictionary");
    
    XCTAssert([[dict valueForKey:@"bool_v"] isKindOfClass:[YPBool class]], @"Failed to parse bool in dictionary");
    YPBool *b = [dict valueForKey:@"bool_v"];
    XCTAssertFalse( b.value, @"Failed to parse object reference number in dictionary");
}


- (void)xtestPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


- (void)testDocumentPDFInfo
{
    YPDocument * document = [self setupDocumentCMethod:@"2-page-pages-export"];
    XCTAssert([document isKindOfClass:[YPDocument class]], @"Failed to setup document ");
    
    NSString * testString = @"Size: 21059 bytes\n\
Version: 1.3\n\
Binary: True\n\
Objects: 35\n\
Streams: 7\n\
Comments: 2\n";
    
//    NSLog(@"doc info %@",[document getPDFInfo]);
//    NSLog(@"doc info %@",testString);
    XCTAssert([[document getPDFInfo] isEqualToString:testString], @"Wrong Document info");

}

- (void)xtestDocumentMetaData
{
    YPDocument * document = [self setupDocumentCMethod:@"2-page-pages-export"];
    
    NSString * testString = @"File: fcexploit.pdf\n \
    Size: 25169 bytes\n \
    Version: 1.3\n \
    Binary: True\n \
    Objects: 35\n \
    Streams: 7\n \
    Comments: 0";
    
 //   NSLog(@"doc info %@",[document getPDFMetaData]);
    XCTAssert([[document getPDFMetaData] isEqualToString:testString], @"Wrong Document info");
}

- (void)testDocumentAllPages
{
    
    YPDocument * document = [self setupDocumentCMethod:@"2-page-pages-export"];

    YPPages *pg = [[YPPages alloc] initWithDocument:document];
    [pg getPageCount];
    [pg getPagesTree];
}

- (void)testDocumentContentsPages
{
    
}

- (void)testYPObjects
{
    YPDocument * document = [self setupDocumentObCMethod:@"2-page-pages-export"];
    XCTAssert([document isKindOfClass:[YPDocument class]], @"Failed to setup document ");
    
    //[document getInfoForKey:@"Type"];
    
    //SOME FEATURES
    //NSLog(@"dict: %lu", (unsigned long)[[document allObjects] count]);
    
    NSDictionary *pdfObjs = [document allObjects];
    
    XCTAssert([pdfObjs count] == 35, @"Their should be 35 objects");
    
    for(id key in pdfObjs) {
        id pdfObject = [pdfObjs objectForKey:key];
        XCTAssert([key isKindOfClass:[NSString class]], @"Wrong key type in object iteration ");
        
        //NSLog(@"Objectnumber: %@",[pdfObject getObjectNumber]);
        //NSLog(@"contents: %@",[pdfObject getContents]);
        
        if([pdfObject getStreamObject])
        {
            //NSLog(@"Objectnumber: %@",[pdfObject getObjectNumber]);
            //NSLog(@"stream object: %@",[pdfObject getStreamObject]);
            //NSLog(@"stream unenc: %@",[[pdfObject getStreamObject] getDecompressedDataAsString]);
        }
    }
    
    //id pdfObject = [pdfObjs objectForKey:@"21 0"];
    //NSLog(@"class %@", [[pdfObject getContents] class]);

    XCTAssert([[[pdfObjs[@"21 0"] getContents] firstObject] isKindOfClass:[NSDictionary class]], @"Wrong content type");
    
    //YPPages *pg = [[YPPages alloc] initWithDocument:document];
    //[pg getPageCount];
    //[pg getPagesTree];
    
    /*
     if ([document errorMessage]) {
     NSLog(@"%@", [document errorMessage]);
     }
     else {
     NSLog(@"%@", [document version]);
     }
     */
    
    
    //XCTAssert([obj.value isEqualToString:@"abcdef0123456789ABCDEF"], @"Failed to parse hexstring value");
}
@end
