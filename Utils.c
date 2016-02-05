//
//  Utils.c
//  Parser
//
//  Created by Aliona on 22.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#include <stdio.h>

int isBlank(char ch)
{
    return ch == ' ' || ch == '\n' || ch == '\r' || ch == '\t';
}

int isNum(char ch)
{
    return '0' <= ch && ch <= '9';
}

int isHexSymbol(char ch)
{
    return ('0' <= ch && ch <= '9') || ('a' <= ch && ch <= 'f') || ('A' <= ch && ch <= 'F');
}

void skipBlankSymbols(const char * rawData, size_t *idx)
{
    size_t i = *idx;
    
    while(rawData[i] == ' ' || rawData[i] == '\n' || rawData[i] == '\r' || rawData[i] == '\t') {
        i++;
    }
    
    *idx = i;
}

void dumpCharArray(const char * rawData, size_t size)
{
    for (int j = 0; j < size; j++ ) {
        printf("%c",  rawData[j]);
    }
}
