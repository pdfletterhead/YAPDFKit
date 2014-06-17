//
//  PDFHexString.h
//  Parser
//
//  Created by Aliona on 26.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Тип PDF Hexadecimal String *
 * Бинарная строка, содержит символы [0-9] [A-F] [a-f].
 * Всегда четное количество символов.
 */
@interface PDFHexString : NSString

@end
