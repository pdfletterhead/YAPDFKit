//
//  YPXref.m
//  YAPDFKit
//
//  Created by Pim Snel on 13-02-16.
//  Copyright © 2016 Lingewoud. All rights reserved.
//

#import "YPXref.h"

@implementation YPXref

@synthesize objectEntries;

- (id)init
{
    if (self = [super init]) {
        
        objectEntries = [NSMutableArray array];
        
        return self;
    }
    
    return nil;
}

- (NSString*) stringValue
{
    NSMutableString* blockString = (NSMutableString*)@"xref\n";
    blockString = (NSMutableString*)[blockString stringByAppendingFormat:@"0 %lu\n",(unsigned long)[objectEntries count]];
    
    for(NSDictionary* e in objectEntries)
    {
        blockString = (NSMutableString*)[blockString stringByAppendingFormat:@"%@ %@ %@\n",e[@"offset"],e[@"generation"],e[@"deleted"]];
    }

    return blockString;
}

- (void) addObjectEntry:(NSNumber*)offset generation:(NSNumber*)aGeneration deleted:(BOOL)isDeleted
{
    NSString *offsetString = [NSString stringWithFormat:@"%010d",[offset intValue]] ;
    NSString *generationString = [NSString stringWithFormat:@"%05d",[aGeneration intValue]] ;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          offsetString, @"offset",
                          generationString,@"generation",
                          isDeleted?@"f":@"n", @"deleted",
                          nil];
    [objectEntries addObject:[NSDictionary dictionaryWithDictionary:dict]];
}

@end
