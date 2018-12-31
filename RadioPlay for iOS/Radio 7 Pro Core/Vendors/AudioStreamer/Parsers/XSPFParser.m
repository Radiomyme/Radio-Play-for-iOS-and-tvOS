//
//  XSPFParser.m
//  Radio Play by Radiomyme
//

#import "XSPFParser.h"
#import "XMLUtilities.h"

@implementation XSPFParser

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
    NSDictionary *nsMappings = [NSDictionary dictionaryWithObjectsAndKeys:@"http://xspf.org/ns/0/", @"xspf", nil];
    NSArray *tracks = PerformXMLXPathQuery(httpData, nsMappings, @"//xspf:track/xspf:location");
    if(tracks && [tracks count] > 0) {
        NSDictionary *track = [tracks objectAtIndex:0];
        if(track) {
            NSString *streamUrl = [track objectForKey:@"nodeContent"];
            return streamUrl;
        }
    }
    
    return nil;
}

@end
