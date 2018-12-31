//
//  AudioPacket.m
//  Radio Play by Radiomyme
//

#import "AudioPacket.h"

@interface AudioPacket () {
    NSData *_data;
    AudioStreamPacketDescription _audioDescription;
    
    NSUInteger _consumedLength;
}

@end

@implementation AudioPacket

@synthesize data = _data;
@synthesize audioDescription = _audioDescription;

- (id)initWithData:(NSData *)data {
    self = [super init];
    if(self) {
        _data = [data retain];
        _consumedLength = 0;
    }
    
    return self;
}

- (void)dealloc {
    [_data release];
    
    [super dealloc];
}

- (NSUInteger)length {
    return [_data length];
}

- (NSUInteger)remainingLength {
    return ([_data length] - _consumedLength);
}

- (void)copyToBuffer:(void *const)buffer size:(int)size {
    int dataSize = size;
    if((_consumedLength + dataSize) > [self length]) {
        dataSize = [self length] - _consumedLength;
    }
    
    memcpy(buffer, ([_data bytes] + _consumedLength), dataSize);
    _consumedLength += dataSize;
}

@end
