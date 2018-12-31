//
//  Radio.h
//  Radio Play by Radiomyme
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AudioQueue.h"

#define NUM_AQ_BUFS             3
#define AQ_MAX_PACKET_DESCS     512
#define AQ_DEFAULT_BUF_SIZE     4096

typedef struct {
    AudioFileStreamID streamID;
    AudioStreamBasicDescription audioFormat;
    AudioQueueRef queue;
    AudioQueueBufferRef queueBuffers[NUM_AQ_BUFS];
    AudioStreamPacketDescription *packetDescriptions;
    __unsafe_unretained AudioQueue *audioQueue;
    BOOL started;
    BOOL playing;
    BOOL paused;
    BOOL buffering;
    int bufferSize;
    NSUInteger bufferInSeconds;
    unsigned long long totalBytes;
    float gain;
    dispatch_queue_t lockQueue;
} PlayerState;

typedef enum {
    kRadioStateStopped = 0,
    kRadioStateConnecting,
    kRadioStateBuffering,
    kRadioStatePlaying,
    kRadioStateError
} RadioState;

typedef enum {
    kRadioErrorNone = 0,
    kRadioErrorPlaylistParsing,
    kRadioErrorFileStreamGetProperty,
    kRadioErrorFileStreamOpen,
    kRadioErrorAudioQueueCreate,
    kRadioErrorAudioQueueBufferCreate,
    kRadioErrorAudioQueueEnqueue,
    kRadioErrorAudioQueueStart,
    kRadioErrorDecoding,
    kRadioErrorHostNotReachable,
    kRadioErrorNetworkError
} RadioError;

typedef enum {
    kRadioConnectionTypeNone = 0,
    kRadioConnectionTypeWWAN,
    kRadioConnectionTypeWiFi
} RadioConnectionType;

@protocol RadioDelegate;
@class ReachabilityRadioKit;

@interface Radio : NSObject {
    NSURL *_url;
    
    NSString *_radioTitle;
    NSString *_radioName;
    NSString *_radioGenre;
    NSString *_radioUrl;
    
    PlayerState _playerState;
    RadioState _radioState;
    RadioError _radioError;
    
    NSObject<RadioDelegate> *_delegate;
    
    BOOL _shutdown;
    BOOL _waitingForReconnection;
    BOOL _connectionError;
    int _buffersInUse;
    
    UIBackgroundTaskIdentifier _bgTask;
    NSTimer *_bufferTimer;
    NSTimer *_reconnectTimer;
    
    ReachabilityRadioKit *_reachability;
    RadioConnectionType _connectionType;
}

@property (nonatomic, readonly) RadioState radioState;
@property (nonatomic, readonly) RadioError radioError;
@property (nonatomic, retain, readonly) NSString *radioTitle;
@property (nonatomic, retain, readonly) NSString *radioName;
@property (nonatomic, retain, readonly) NSString *radioGenre;
@property (nonatomic, retain, readonly) NSString *radioUrl;
@property (nonatomic, assign) NSObject<RadioDelegate> *delegate;

- (id)initWithURL:(NSURL *)url;

- (void)shutdown;
- (void)play;
- (void)pause;

- (BOOL)isPlaying;
- (BOOL)isPaused;
- (BOOL)isBuffering;
- (void)setBufferInSeconds:(NSUInteger)seconds;
- (void)setVolume:(float)volume;

@end


@protocol RadioDelegate<NSObject>
@optional
- (void)radioStateChanged:(Radio *)radio;
- (void)radioMetadataReady:(Radio *)radio;
- (void)radioTitleChanged:(Radio *)radio;
@end
