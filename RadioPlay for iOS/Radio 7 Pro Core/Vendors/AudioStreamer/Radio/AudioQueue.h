//
//  AudioQueue.h
//  Radio Play by Radiomyme
//

#import <Foundation/Foundation.h>

@class AudioPacket;

@interface AudioQueue : NSObject

- (AudioPacket *)pop;
- (AudioPacket *)peak;
- (void)addPacket:(AudioPacket *)packet;
- (void)removeAllPackets;
- (NSUInteger)count;

@end
