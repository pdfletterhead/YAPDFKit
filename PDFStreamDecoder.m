//
//  PDFStreamDecoder.m
//  Parser
//
//  Created by Aliona on 24.05.14.
//  Copyright (c) 2014 Ptenster. All rights reserved.
//

#import <zlib.h>
#import "PDFStreamDecoder.h"
#import "NSData+Compression.h"


enum FILTER {
    FLATEDECODE = 1,
};

@implementation PDFStreamDecoder
{
    enum FILTER;
    NSData *data;
    NSData *decrypted;
}

- (id)initWithData:(NSData *)d
{
    if([super init]) {

//        data = [d zlibInflate];

        //NSLog(@"data: %@",d);
        
        unsigned char *bytePtr = (unsigned char *)[d bytes];
        //SLog(@"raw1inflated: %s", bytePtr);
        
        NSString *path = [ @"~/Desktop/test1.gzip" stringByExpandingTildeInPath];
        NSURL *pathUrl = [NSURL fileURLWithPath:path];
        [d writeToURL:pathUrl atomically:YES];
        
        
        
        
        
        
        
        
        
//        decrypted = [self decrypt];

        
        
        
        data = d;
        return self;
    }

    return nil;
}

#define CHUNK 16384


/* Decompress from file source to file dest until stream ends or EOF.
 inf() returns Z_OK on success, Z_MEM_ERROR if memory could not be
 allocated for processing, Z_DATA_ERROR if the deflate data is
 invalid or incomplete, Z_VERSION_ERROR if the version of zlib.h and
 the version of the library linked do not match, or Z_ERRNO if there
 is an error reading or writing the files. */
int inf(FILE *source, FILE *dest)
{
    int ret;
    unsigned have;
    z_stream strm;
    unsigned char in[CHUNK];
    unsigned char out[CHUNK];
    
    /* allocate inflate state */
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.avail_in = 0;
    strm.next_in = Z_NULL;
    ret = inflateInit(&strm);
    if (ret != Z_OK)
        return ret;
    
    /* decompress until deflate stream ends or end of file */
    do {
        strm.avail_in = fread(in, 1, CHUNK, source);
        if (ferror(source)) {
            (void)inflateEnd(&strm);
            return Z_ERRNO;
        }
        if (strm.avail_in == 0)
            break;
        strm.next_in = in;
        
        /* run inflate() on input until output buffer not full */
        do {
            strm.avail_out = CHUNK;
            strm.next_out = out;
            ret = inflate(&strm, Z_NO_FLUSH);
            assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
            switch (ret) {
                case Z_NEED_DICT:
                    ret = Z_DATA_ERROR;     /* and fall through */
                case Z_DATA_ERROR:
                case Z_MEM_ERROR:
                    (void)inflateEnd(&strm);
                    return ret;
            }
            have = CHUNK - strm.avail_out;
            if (fwrite(out, 1, have, dest) != have || ferror(dest)) {
                (void)inflateEnd(&strm);
                return Z_ERRNO;
            }
        } while (strm.avail_out == 0);
        
        /* done when inflate() says it's done */
    } while (ret != Z_STREAM_END);
    
    /* clean up and return */
    (void)inflateEnd(&strm);
    return ret == Z_STREAM_END ? Z_OK : Z_DATA_ERROR;
}

- (NSData *)decrypt
{
    NSData *uncompressedData = nil;

    uLongf destLen = 100 * data.length;
    Bytef *dest = malloc(100 * data.length);
    
    int stat = uncompress(dest, &destLen, data.bytes, data.length);
    if(stat == Z_OK)
    {
        uncompressedData = [NSData dataWithBytes:dest length:destLen];
        NSLog(@"dataunc: %@",uncompressedData);
    }
    else{
        NSLog(@"not oke: ");
    }
    free(dest);
    
    return uncompressedData;
}

- (NSData *)getDecrypted
{
    return decrypted;
}
@end
