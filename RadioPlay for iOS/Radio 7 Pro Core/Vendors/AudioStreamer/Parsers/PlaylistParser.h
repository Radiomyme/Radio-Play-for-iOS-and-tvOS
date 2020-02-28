//
//  PlaylistParserProtocol.h
//  Radio Play by Radiomyme
//

#import <Foundation/Foundation.h>

@protocol PlaylistParser <NSObject>
- (NSString *)parseStreamUrl:(NSData *)httpData;
@end
