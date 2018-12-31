//
//  Streamer.h
//  Radio Play by Radiomyme
//

#import <Foundation/Foundation.h>
#import "Radio.h"
#import "PlaylistParser.h"

typedef enum {
    kPlaylistNone = 0,
    kPlaylistM3U,
    kPlaylistPLS,
    kPlaylistXSPF
} PlaylistType;

typedef enum {
    kHTTPStatePlaylistParsing = 0,
    kHTTPStateAudioStreaming
} HTTPState;

@interface Streamer : Radio

@property (nonatomic, copy) NSString *httpUserAgent;
@property (nonatomic, assign) NSUInteger httpTimeout;

@end
