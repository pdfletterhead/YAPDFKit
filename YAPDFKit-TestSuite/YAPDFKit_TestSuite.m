//
//  YAPDFKit_TestSuite.m
//  YAPDFKit-TestSuite
//
//  Created by Pim Snel on 11-02-16.
//  Copyright © 2016 Lingewoud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import "PDFObject.h"
#import "PDFArray.h"
#import "PDFBool.h"
#import "PDFHexString.h"
#import "PDFName.h"
#import "PDFNumber.h"
#import "PDFString.h"
#import "PDFObjectReference.h"

@interface YAPDFKit_TestSuite : XCTestCase

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

- (void)xtestExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

/*
 * Тест для ссылок на объекты
 */
- (void)testObjectReferenceParsing
{
    char example[] = "325 0 R";
    NSData *exampleData = [NSData dataWithBytes:example length:sizeof(example)];
    NSInteger first, second;
    PDFObject *obj = [[PDFObject alloc] initWithData:exampleData first:&first second:&second];
    
    XCTAssert([obj.value isKindOfClass:[PDFObjectReference class]], @"Failed to parse object reference");
    PDFObjectReference *ref = obj.value;
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
    PDFObject *obj = [[PDFObject alloc] initWithData:exampleData first:&first second:&second];
    XCTAssert([obj.value isKindOfClass:[NSString class]], @"Failed to parse PDF name");
    PDFName *name = obj.value;
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
    PDFObject *obj = [[PDFObject alloc] initWithData:exampleData first:&first second:&second];
    XCTAssert([obj.value isKindOfClass:[PDFBool class]], @"Failed to parse PDF name");
    PDFBool *b = obj.value;
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
    PDFObject *obj = [[PDFObject alloc] initWithData:exampleData first:&first second:&second];
    
    XCTAssert([obj.value isKindOfClass:[PDFNumber class]], @"Failed to parse real number");
    PDFNumber *num = obj.value;
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
    PDFObject *obj = [[PDFObject alloc] initWithData:exampleData first:&first second:&second];
    
    XCTAssert([obj.value isKindOfClass:[PDFNumber class]], @"Failed to parse int number");
    PDFNumber *num = obj.value;
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
    PDFObject *obj = [[PDFObject alloc] initWithData:exampleData first:&first second:&second];
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
    PDFObject *obj = [[PDFObject alloc] initWithData:exampleData first:&first second:&second];
    
    XCTAssert([obj.value isKindOfClass:[NSString class]], @"Failed to parse string");
    NSString *str = obj.value;
    XCTAssert([str isEqualToString:@"String"], @"Failed to parse string value");
    
    char example1[] = "(String(with)brackets)";
    NSData *exampleData1 = [NSData dataWithBytes:example1 length:sizeof(example1)];
    PDFObject *obj1 = [[PDFObject alloc] initWithData:exampleData1 first:&first second:&second];
    
    XCTAssert([obj1.value isKindOfClass:[NSString class]], @"Failed to parse string with brackets");
    NSString *str1 = obj1.value;
    XCTAssert([str1 isEqualToString:@"String(with)brackets"], @"Failed to parse string with brackets value");
    
    char example2[] = "(String\\(withbracket)";
    NSData *exampleData2 = [NSData dataWithBytes:example2 length:sizeof(example2)];
    PDFObject *obj2 = [[PDFObject alloc] initWithData:exampleData2 first:&first second:&second];
    
    XCTAssert([obj2.value isKindOfClass:[NSString class]], @"Failed to parse string with bracket (");
    NSString *str2 = obj2.value;
    XCTAssert([str2 isEqualToString:@"String\\(withbracket"], @"Failed to parse string with bracket ( value");
    
    char example3[] = "(String\\)withbracket)";
    NSData *exampleData3 = [NSData dataWithBytes:example3 length:sizeof(example3)];
    PDFObject *obj3 = [[PDFObject alloc] initWithData:exampleData3 first:&first second:&second];
    
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
    PDFObject *obj = [[PDFObject alloc] initWithData:exampleData first:&first second:&second];
    
    XCTAssert([obj.value isKindOfClass:[NSArray class]], @"Failed to parse array");
    NSArray *arr = obj.value;
    
    XCTAssert([[arr objectAtIndex:0] isKindOfClass:[NSString class]], @"Failed to parse name in array");
    XCTAssert([[arr objectAtIndex:0] isEqualToString:@"array"], @"Failed to parse value of name in array");
    
    XCTAssert([[arr objectAtIndex:1] isKindOfClass:[PDFNumber class]], @"Failed to parse number in array");
    XCTAssert([[arr objectAtIndex:1] intValue] == 123, @"Failed to parse value of integer in array");
    
    XCTAssert([[arr objectAtIndex:2] isKindOfClass:[PDFNumber class]], @"Failed to parse number in array");
    XCTAssert([[arr objectAtIndex:2] realValue] == -115.5, @"Failed to parse value of float in array");
    
    XCTAssert([[arr objectAtIndex:3] isKindOfClass:[PDFObjectReference class]], @"Failed to parse object reference in array");
    PDFObjectReference *ref = [arr objectAtIndex:3];
    XCTAssert([[ref getReferenceNumber] isEqualToString:@"123 0"], @"Failed to detect reference number in array");
    
    XCTAssert([[arr objectAtIndex:4] isKindOfClass:[NSDictionary class]], @"Failed to parse dictionary in array");
    NSDictionary *dict = [arr objectAtIndex:4];
    XCTAssert([[dict objectForKey:@"dict"] isKindOfClass:[NSDictionary class]], @"Failed to parse dict in dictionary in array");
    NSDictionary *dict1 = [dict objectForKey:@"dict"];
    XCTAssert([[dict1 objectForKey:@"dict1"] isKindOfClass:[NSDictionary class]], @"Failed to parse dict1 in dictionary in array");
    NSDictionary *dict2 = [dict1 objectForKey:@"dict1"];
    XCTAssert([[dict2 objectForKey:@"dict2"] isKindOfClass:[PDFNumber class]], @"Failed to parse number in dictionary in array");
    XCTAssert([[dict2 objectForKey:@"dict2"] intValue] == 123, @"Failed to parse number value in dictionary in array");
    
    XCTAssert([[arr objectAtIndex:5] isKindOfClass:[NSArray class]], @"Failed to parse array in array");
    NSArray *arr1 = [arr objectAtIndex:5];
    XCTAssert ([[arr1 objectAtIndex:2] isKindOfClass:[NSArray class]], @"Failed to parse arr1 in array");
    XCTAssert ([[arr1 objectAtIndex:2] isKindOfClass:[NSArray class]], @"Failed to parse arr2 in array");
    
    XCTAssert([[arr objectAtIndex:6] isKindOfClass:[PDFBool class]], @"Failed to parse bool in array");
    PDFBool *b = [arr objectAtIndex:6];
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
    PDFObject *obj = [[PDFObject alloc] initWithData:exampleData first:&first second:&second];
    
    XCTAssert([obj.value isKindOfClass:[NSDictionary class]], @"Failed to parse dictionary");
    NSMutableDictionary *dict = obj.value;
    
    XCTAssert([[dict valueForKey:@"array"] isKindOfClass:[NSArray class]], @"Failed to parse array in dictionary");
    NSArray *arr = [dict valueForKey:@"array"];
    
    XCTAssert([[arr objectAtIndex:0] isKindOfClass:[PDFNumber class]], @"Failed to parse array in dictionary value 0");
    XCTAssert([[arr objectAtIndex:0] intValue] == 0, @"Failed to parse array in dictionary value 0: incorrect value");
    XCTAssert([[arr objectAtIndex:1] isKindOfClass:[PDFNumber class]], @"Failed to parse array in dictionary value 1");
    XCTAssert([[arr objectAtIndex:1] intValue] == 1, @"Failed to parse array in dictionary value 1: incorrect value");
    XCTAssert([[arr objectAtIndex:2] isKindOfClass:[NSArray class]], @"Failed to parse array in dictionary value 2");
    NSArray *arr1 = [arr objectAtIndex:2];
    XCTAssert([[arr1 objectAtIndex:0] isKindOfClass:[PDFNumber class]], @"Failed to parse array1 in dictionary value 0");
    XCTAssert([[arr1 objectAtIndex:0] intValue] == 2, @"Failed to parse array1 in dictionary value 0: incorrect value");
    XCTAssert([[arr1 objectAtIndex:1] isKindOfClass:[PDFNumber class]], @"Failed to parse array1 in dictionary value 1");
    XCTAssert([[arr1 objectAtIndex:1] intValue] == 3, @"Failed to parse array1 in dictionary value 1: incorrect value");
    XCTAssert([[arr1 objectAtIndex:2] isKindOfClass:[NSArray class]], @"Failed to parse array1 in dictionary value 2");
    NSArray *arr2 = [arr1 objectAtIndex:2];
    XCTAssert([[arr2 objectAtIndex:0] isKindOfClass:[PDFNumber class]], @"Failed to parse array2 in dictionary value 0");
    XCTAssert([[arr2 objectAtIndex:0] intValue] == 4, @"Failed to parse array2 in dictionary value 0: incorrect value");
    XCTAssert([[arr2 objectAtIndex:1] isKindOfClass:[PDFNumber class]], @"Failed to parse array2 in dictionary value 1");
    XCTAssert([[arr2 objectAtIndex:1] intValue] == 5, @"Failed to parse array2 in dictionary value 1: incorrect value");
    
    XCTAssert([[dict valueForKey:@"integer"] isKindOfClass:[PDFNumber class]], @"Failed to parse integer in dictionary");
    NSLog(@"%@", [dict valueForKey:@"integer"]);
    NSLog(@"%@", [dict valueForKey:@"real"]);
    NSLog(@"%@", [dict valueForKey:@"reference"]);
    XCTAssert([[dict valueForKey:@"integer"] intValue] == 123, @"Failed to parse integer value in dictionary");
    
    XCTAssert([[dict valueForKey:@"real"] isKindOfClass:[PDFNumber class]], @"Failed to parse float number in dictionary");
    XCTAssertEqual([[dict valueForKey:@"real"] realValue], -115.5, @"Failed to parse float number value in dictionary");
    
    XCTAssert([[dict valueForKey:@"reference"] isKindOfClass:[PDFObjectReference class]], @"Failed to parse object reference in dictionary");
    XCTAssert([[[dict valueForKey:@"reference"] getReferenceNumber] isEqual:@"123 0"], @"Failed to parse object reference number in dictionary");
    
    XCTAssert([[dict valueForKey:@"dictionary"] isKindOfClass:[NSDictionary class]], @"Failed to parse dictionary in dictionary");
    NSDictionary *dict1 = [dict valueForKey:@"dictionary"];
    XCTAssert([[dict1 valueForKey:@"dict"] isKindOfClass:[NSDictionary class]], @"Failed to parse dictionary1 in dictionary");
    NSDictionary *dict2 = [dict1 valueForKey:@"dict"];
    XCTAssert([[dict2 valueForKey:@"dict1"] isKindOfClass:[NSDictionary class]], @"Failed to parse dictionary2 in dictionary");
    NSDictionary *dict3 = [dict2 valueForKey:@"dict1"];
    XCTAssert([[dict3 valueForKey:@"dict2"] isKindOfClass:[PDFNumber class]], @"Failed to parse dictionary3 in dictionary");
    XCTAssert([[dict3 valueForKey:@"dict2"] intValue] == 123, @"Failed to parse value in final dictionary");
    
    XCTAssert([[dict valueForKey:@"bool_v"] isKindOfClass:[PDFBool class]], @"Failed to parse bool in dictionary");
    PDFBool *b = [dict valueForKey:@"bool_v"];
    XCTAssertFalse( b.value, @"Failed to parse object reference number in dictionary");
}


- (void)xtestPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
