//
//  YPAttribute.h
//  YAPDFKit
//
//  Created by Pim Snel on 16-02-16.
//  Copyright © 2016-2019 Lingewoud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YPAttribute : NSObject

@property NSString *attributeAsString;
@property NSString *attributeType;

- (id)initWithString:(NSString*)string;
- (NSString*)determineAttributeType:(NSString*)string;
@end
