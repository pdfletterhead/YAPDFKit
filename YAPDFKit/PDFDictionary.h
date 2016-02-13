//
//  PDFDictionary.h
//  YAPDFKit
//
//  Created by Aliona on 26.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Тип PDF Dictionary *
 * Словарь состоит из пар "ключ-значение", где
 * ключом всегда является имя (PDF Name). Может
 * содержать тип (Type) и подтип (Subtype или S),
 * значения которых всегда имя (PDF Name).
 */
@interface PDFDictionary : NSObject

@property NSMutableDictionary* nsdict;

-(id)initWithDictionary:(NSDictionary*) dict;
-(id)objectForKey:(id)aKey;
-(void)setObject:(id)anObject forKey:(id)aKey;
-(void)removeObjectForKey:(id)aKey;
-(NSString*) stringValue;

@end
