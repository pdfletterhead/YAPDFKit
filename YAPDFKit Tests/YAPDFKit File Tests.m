//
//  YAPDFKit File Tests.m
//  YAPDFKit
//
//  Created by Pim Snel on 11-02-16.
//  Copyright © 2016 Lingewoud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PDFObject.h"
#import "PDFArray.h"
#import "PDFBool.h"
#import "PDFHexString.h"
#import "PDFName.h"
#import "PDFNumber.h"
#import "PDFString.h"
#import "PDFObjectReference.h"

@interface YAPDFKit_File_Tests : XCTestCase

@end

@implementation YAPDFKit_File_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testObjectReferenceParsing
{
    char example[] = "325 0 R";
    NSLog(@"Hallo?");
    NSData *exampleData = [NSData dataWithBytes:example length:sizeof(example)];
    NSInteger first, second;
    PDFObject *obj = [[PDFObject alloc] initWithData:exampleData first:&first second:&second];
    
    XCTAssert([obj.value isKindOfClass:[PDFObjectReference class]], @"Failed to parse object reference");
    PDFObjectReference *ref = obj.value;
    XCTAssert([[ref getReferenceNumber] isEqualToString:@"325 0"], @"Wrong reference number in object reference");
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
