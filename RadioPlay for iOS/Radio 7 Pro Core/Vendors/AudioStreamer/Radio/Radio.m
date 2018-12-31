//
//  Radio.m
//  Radio Play by Radiomyme
//

#import "Radio.h"
#import "ReachabilityRadioKit.h"

@interface Radio()
@property (nonatomic, readwrite) RadioState radioState;
@end

@implementation Radio

@synthesize radioState = _radioState;
@synthesize radioError = _radioError;
@synthesize radioTitle = _radioTitle;
@synthesize radioName = _radioName;
@synthesize radioGenre = _radioGenre;
@synthesize radioUrl = _radioUrl;
@synthesize delegate = _delegate;

- (id)initWithURL:(NSURL *)url {
    self = [super init];
    if(self) {
        _url = [url retain];
        _delegate = nil;
        
        _playerState.started = NO;
        _playerState.playing = NO;
        _playerState.paused = NO;
        _playerState.gain = 0.5;
        _playerState.totalBytes = 0;
        _playerState.bufferInSeconds = 1; // 3 seconds buffering
        _playerState.audioQueue = [[AudioQueue alloc] init];
        _playerState.queue = NULL;
        _playerState.packetDescriptions = NULL;
        _playerState.lockQueue = dispatch_queue_create("lockQueue", NULL);
        
        _radioState = kRadioStateStopped;
        _radioError = kRadioErrorNone;
        
        _shutdown = NO;
        _waitingForReconnection = NO;
        _connectionError = NO;
        _buffersInUse = 0;
        
        _bgTask = UIBackgroundTaskInvalid;
        
        _bufferTimer = nil;
        _reconnectTimer = nil;
        _reachability = nil;
        _connectionType = kRadioConnectionTypeNone;
    }
    
    return self;
}

- (void)dealloc {
    _delegate = nil;
    [_url release];
    
    if(_playerState.packetDescriptions) {
        free(_playerState.packetDescriptions);
    }
    [_playerState.audioQueue release];
    dispatch_release(_playerState.lockQueue);
    
    if(_bufferTimer) {
        [_bufferTimer invalidate];
        [_bufferTimer release];
        _bufferTimer = nil;
    }
    
    if(_reconnectTimer) {
        [_reconnectTimer invalidate];
        [_reconnectTimer release];
        _reconnectTimer = nil;
    }
    
    if(_reachability) {
        [_reachability stopNotifier];
        [_reachability release];
        _reachability = nil;
    }
    
    DLog(@"DEALLOCATED");
    
    [super dealloc];
}


#pragma mark -
#pragma mark Instance Methods

- (void)shutdown {
    // implemented in subclass
}

- (void)play {
    // implemented in subclass
}

- (void)pause {
    // implemented in sublass
}

- (BOOL)isPlaying {
    return _playerState.playing;
}

- (BOOL)isPaused {
    return _playerState.paused;
}

- (BOOL)isBuffering {
    return _playerState.buffering;
}

- (void)setBufferInSeconds:(NSUInteger)seconds {
    if(seconds > 30) {
        seconds = 30;
    }
    if(seconds < 1) {
        seconds = 1;
    }
    
    // buffers contain 0.5 seconds of data
    _playerState.bufferInSeconds = seconds * 2;
}

- (void)setVolume:(float)volume {
    if(volume < 0) {
        volume = 0;
    }
    
    if(volume > 1.0) {
        volume = 1.0;
    }
    
    _playerState.gain = volume;
    
    if(_playerState.queue == nil) {
        return;
    }
    AudioQueueSetParameter(_playerState.queue, kAudioQueueParam_Volume, _playerState.gain);
}

#pragma mark -
#pragma mark Private Methods

@end
