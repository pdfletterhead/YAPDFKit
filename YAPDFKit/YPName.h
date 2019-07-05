//
//  YPName.h
//  YAPDFKit
//
//  Created by Aliona on 26.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//  Copyright © 2016-2019 Lingewoud. All rights reserved.

#import <Foundation/Foundation.h>

/**
 * Тип PDF Name *
 * Начинается с символа '/', может содержать код
 * шестнадцатеричного числа. Не содержит пробельных
 * символов.
 */
@interface YPName : NSMutableString

@end
