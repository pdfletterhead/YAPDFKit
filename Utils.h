
//
//  Utils.h
//  Parser
//
//  Created by Aliona on 22.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#ifndef Parser_Utils_h
#define Parser_Utils_h

/**
 * Проверяет, является ли символ ch пустым. Пустыми считаются
 * следующие символы: пробел, перенос строки и символ табуляции.
 * @return 1, если символ пустой и 0 если символ не пустой
 */
int isBlank(char ch);

/**
 * Проверяет, является ли символ ch числом (0-9).
 * @return 1, если текущий символ - число и 0 в противном случае
 */
int isNum(char ch);

/**
 * Проверяет, является ли символ ch символом шестнадцатеричной строки
 * [0-9] [a-f] [A-F]
 * @return 1, если является и 0 в противном случае
 */
int isHexSymbol(char ch);

/**
 * Пропускает пустые символы (пробел, перенос строки и символ табуляции),
 * увеличивая индекс текущего символа.
 * @param rawData - текст, idx - номер текущего просматриваемого символа
 */
void skipBlankSymbols(const char * rawData, size_t *idx);

void dumpCharArray(const char * rawData, size_t size);

#endif
