//
//  M3UParser.m
//  Radio Play by Radiomyme
//

#import "M3UParser.h"

@implementation M3UParser

- (id)init {
    self = [super init];
    if(self) {

    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (NSString *)parseStreamUrl:(NSData *)httpData {
    NSString *document = [[[NSString alloc] initWithBytes:[httpData bytes] length:[httpData length] encoding:NSUTF8StringEncoding] autorelease];
    NSArray *lines = [document componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if(lines && [lines count] > 0) {
        for(NSString *line in lines) {
            if([line hasPrefix:@"http"]) {
                NSString *streamUrl = [line stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                return streamUrl;
            }
        }
    }
    
    return nil;
}

@end
