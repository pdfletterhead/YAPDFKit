//
//  PDFNumber.h
//  YAPDFKit
//
//  Created by Aliona on 27.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Тип PDF Number *
 * Принимает целое или дробное значение.
 * Может содержать знак + или -
 * Дробная часть отделяется точкой.
 */
@interface PDFNumber : NSObject

/**
 * Принимает значение true, если число дробное 
 * и false в противном случае
 */
@property BOOL real;

/**
 * Значение для real = false (целое число)
 */
@property int intValue;

/**
 * Значение для real = true (дробное число)
 */
@property float realValue;

/**
 * Инициализация для целого числа
 */
- (void) initWithInt:(NSInteger)i;

/**
 * Инициализация для дробного числа
 */
- (void) initWithReal:(float)f;
@end
