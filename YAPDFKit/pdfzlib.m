//
//  pdflib.m
//  YAPDFKit
//
//  Created by Pim Snel on 10-02-16.
//  Copyright © 2016-2019 Lingewoud. All rights reserved.
//

//  Based on zachron's pdfiphone solution
//  https://github.com/zachron/pdfiphone

//  The implementation was slightly changed so that ir returns an NSString
//  instead of creating a temporary text file and reading a string from there.
//  This new approach lets the NSString object handle the encoding of the PDF
//  file, so as to support a wider variety of characters.

//  Adobe has a web site that converts PDF files to text for free,
//  so why would you need something like this? Several reasons:
//
//  1) This code is entirely free including for commericcial use. It only
//     requires ZLIB (from www.zlib.org) which is entirely free as well.
//
//  2) This code tries to put tabs into appropriate places in the text,
//     which means that if your PDF file contains mostly one large table,
//     you can easily take the output of this program and directly read it
//     into Excel! Otherwise if you select and copy the text and paste it into
//     Excel there is no way to extract the various columns again.
//
//  This code assumes that the PDF file has text objects compressed
//  using FlateDecode (which seems to be standard).
//
//  This code is free. Use it for any purpose.
//  The author assumes no liability whatsoever for the use of this code.
//  Use it at your own risk!


//  PDF file strings (based on PDFReference15_v5.pdf from www.adobve.com:
//
//  BT = Beginning of a text object, ET = end of a text object
//  5 Ts = superscript
//  -5 Ts = subscript
//  Td move to start next line

#include "pdfzlib.h"

#include <stdio.h>
#include <string.h>

#include <stdlib.h>
#include <ctype.h>

#import <Foundation/Foundation.h>
#include "zlib.h"

NSMutableString *result;

void ZeroMemory(void * buffer, long sizeOf)
{
	memset(buffer, 0, sizeOf);
}

//Keep this many previous recent characters for back reference:
#define oldchar 15

//Convert a recent set of characters into a number if there is one.
//Otherwise return -1:
float ExtractNumber(const char* search, int lastcharoffset)
{
	int i = lastcharoffset;
	while (i>0 && search[i]==' ') i--;
	while (i>0 && (isdigit(search[i]) || search[i]=='.')) i--;
	float flt=-1.0;
	char buffer[oldchar+5]; 
	ZeroMemory(buffer,sizeof(buffer));
	strncpy(buffer, search+i+1, lastcharoffset-i);
	if (buffer[0] && sscanf(buffer, "%f", &flt))
	{
		return flt;
	}
	return -1.0;
}

//Check if a certain 2 character token just came along (e.g. BT):
bool seen2(const char* search, char* recent)
{
if (    recent[oldchar-3]==search[0] 
     && recent[oldchar-2]==search[1] 
	 && (recent[oldchar-1]==' ' || recent[oldchar-1]==0x0d || recent[oldchar-1]==0x0a) 
	 && (recent[oldchar-4]==' ' || recent[oldchar-4]==0x0d || recent[oldchar-4]==0x0a)
	 )
	{
		return true;
	}
	return false;
}

//This method processes an uncompressed Adobe (text) object and extracts text.
void ProcessOutput(char* output, size_t len)
{
	//Are we currently inside a text object?
	bool intextobject = false;

	//Is the next character literal (e.g. \\ to get a \ character or \( to get ( ):
	bool nextliteral = false;
	
	//() Bracket nesting level. Text appears inside ()
	int rbdepth = 0;

	//Keep previous chars to get extract numbers etc.:
	char oc[oldchar];
	int j=0;
	for (j=0; j<oldchar; j++) oc[j]=' ';

	for (size_t i=0; i<len; i++)
	{
		unsigned char c = output[i];
		if (intextobject)
		{
			if (rbdepth==0 && seen2("TD", oc))
			{
				//Positioning.
				//See if a new line has to start or just a tab:
				float num = ExtractNumber(oc,oldchar-5);
				if (num>1.0)
				{
					[result appendFormat:@"\n"];
				}
				if (num<1.0)
				{
                    [result appendFormat:@"\t"];
				}
			}
			if (rbdepth==0 && seen2("ET", oc))
			{
				//End of a text object, also go to a new line.
				intextobject = false;
				[result appendFormat:@"\n"];
			}
			else if (c=='(' && rbdepth==0 && !nextliteral) 
			{
				//Start outputting text!
				rbdepth=1;
				//See if a space or tab (>1000) is called for by looking
				//at the number in front of (
				int num = ExtractNumber(oc,oldchar-1);
				if (num>0)
				{
					if (num>1000.0)
					{
						[result appendFormat:@"\t"];
					}
					else if (num>100.0)
					{
						[result appendFormat:@" "];
					}
				}
			}
			else if (c==')' && rbdepth==1 && !nextliteral) 
			{
				//Stop outputting text
				rbdepth=0;
				[result appendFormat:@"\n"];
			}
			else if (rbdepth==1) 
			{
				//Just a normal text character:
				if (c=='\\' && !nextliteral)
				{
					//Only print out next character no matter what. Do not interpret.
					nextliteral = true;
				}
				else
				{
					nextliteral = false;

                    [result appendFormat:@"%c", c];
                    
				}
			}
		}
		//Store the recent characters for when we have to go back for a number:
		for (j=0; j<oldchar-1; j++) oc[j]=oc[j+1];
		oc[oldchar-1]=c;
		if (!intextobject)
		{
			if (seen2("BT", oc))
			{
				//Start of a text object:
				intextobject = true;
			}
		}
	}
}

NSData* inflateStringData(NSData* data)
{
    return nil;
}



NSData* deflateData(NSData * data)
{
    
    //Skip to beginning and end of the data stream:
    const char* buffer = data.bytes;
    size_t streamstart = 0;
    size_t streamend = data.length;
    
    if (buffer[streamstart]==0x0d && buffer[streamstart+1]==0x0a) streamstart+=2;
    else if (buffer[streamstart]==0x0a) streamstart++;
    
    if (buffer[streamend-2]==0x0d && buffer[streamend-1]==0x0a) streamend-=2;
    else if (buffer[streamend-1]==0x0a) streamend--;
    
    //Assume output will fit into 100 times input buffer:
    size_t outsize = (streamend - streamstart)*100;
    char *output = malloc(outsize*sizeof(char)); //Allocates the output
    ZeroMemory(output, outsize);
    
    //Now use zlib to inflate:
    z_stream zstrm;
    ZeroMemory(&zstrm, sizeof(zstrm));
    
    zstrm.avail_in = (uInt)streamend - (uInt)streamstart + (uInt)1;
    zstrm.avail_out = (uInt)outsize;
    
    
//    NSLog(@"z avail_in : %d, z avail_out: %d", zstrm.avail_in , zstrm.avail_out);
    zstrm.next_in = (Bytef*)(buffer + streamstart);
    zstrm.next_out = (Bytef*)output;
    
    int rsti = inflateInit(&zstrm);
    if (rsti == Z_OK)
    {
        int rst2 = inflate (&zstrm, Z_FINISH);
//        NSLog(@"z code: %d", rst2);
//        if (rst2 >= 0 || rst2 == -5)
        if (rst2 >= 0)
        {
            NSData * retdata = [[NSData alloc] initWithBytes:output length: zstrm.total_out];
            //Ok, got something, extract the text:
            //size_t totout = zstrm.total_out;
            //printf("rawxxx: %s",output);
            //ProcessOutput(output, totout);
            //NSLog(@"text %@",result);
            //NSString *decompr = [NSString stringWithCString:output encoding:NSUTF8StringEncoding];
            
           // printf("\nraw: %s",output);
//            NSString *decompr = [NSString stringWithUTF8String:(char *)output];
            
            free(output);
            return retdata;
            

        }
        

    }

    free(output);
    return nil;
}

NSString* deflateDataAsString(NSData * data)
{
    
    //Skip to beginning and end of the data stream:
    const char* buffer = data.bytes;
    size_t streamstart = 0;
    size_t streamend = data.length;
    
    if (buffer[streamstart]==0x0d && buffer[streamstart+1]==0x0a) streamstart+=2;
    else if (buffer[streamstart]==0x0a) streamstart++;
    
    if (buffer[streamend-2]==0x0d && buffer[streamend-1]==0x0a) streamend-=2;
    else if (buffer[streamend-1]==0x0a) streamend--;
    
    //Assume output will fit into 100 times input buffer:
    size_t outsize = (streamend - streamstart)*100;
    char *output = malloc(outsize*sizeof(char)); //Allocates the output
    ZeroMemory(output, outsize);
    
    //Now use zlib to inflate:
    z_stream zstrm;
    ZeroMemory(&zstrm, sizeof(zstrm));
    
    zstrm.avail_in = (uInt)streamend - (uInt)streamstart + (uInt)1;
    zstrm.avail_out = (uInt)outsize;
    
    
//    NSLog(@"z avail_in : %d, z avail_out: %d", zstrm.avail_in , zstrm.avail_out);
    zstrm.next_in = (Bytef*)(buffer + streamstart);
    zstrm.next_out = (Bytef*)output;
    
    int rsti = inflateInit(&zstrm);
    if (rsti == Z_OK)
    {
        int rst2 = inflate (&zstrm, Z_FINISH);
//        if (rst2 >= 0 || rst2 == -5)
        if (rst2 >= 0)
        {
            //Ok, got something, extract the text:
            //size_t totout = zstrm.total_out;
            //printf("raw: %s",output);
            //ProcessOutput(output, totout);
            //NSLog(@"text %@",result);
            NSString *decompr = [NSString stringWithCString:output encoding:NSUTF8StringEncoding];
           // printf("\nraw: %s",output);
//            NSString *decompr = [NSString stringWithUTF8String:(char *)output];
            
            if(decompr)
            {
                free(output);
                return decompr;
            }
            else
            {
                NSString *decompr2 = [NSString stringWithCString:output encoding:NSMacOSRomanStringEncoding];
               // NSLog(@"\nraw2: %@",decompr2);
                free(output);
                return decompr2;
            }
            
            
            
            return decompr;
        }
        

    }

    free(output);
    return nil;
}



