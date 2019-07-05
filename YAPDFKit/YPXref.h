//
//  YPXref.h
//  YAPDFKit
//
//  Created by Pim Snel on 13-02-16.
//  Copyright © 2016-2019 Lingewoud. All rights reserved.

#import <Foundation/Foundation.h>

@interface YPXref : NSObject

@property NSMutableArray * objectEntries;
//@property NSDictionary * objectEntry;

- (NSString*)stringValue;
- (void) addObjectEntry:(NSNumber*)offset generation:(NSNumber*)aGeneration deleted:(BOOL)isDeleted;
@end
