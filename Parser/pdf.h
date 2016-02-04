#import <Foundation/Foundation.h>

///Converts a PDF at pathToFile to an NSString with proper encoding.
NSString* convertFile(NSString * pathToFile);
NSString* convertPDF(NSData * data);
