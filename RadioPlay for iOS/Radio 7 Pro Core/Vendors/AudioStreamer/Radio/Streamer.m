//
//  Streamer.m
//  Radio Play by Radiomyme
//

#import "Streamer.h"
#import "AudioPacket.h"
#import "NSHTTPURLResponse.h"
#import "M3UParser.h"
#import "XSPFParser.h"
#import "PLSParser.h"
#import "ReachabilityRadioKit.h"

@interface Streamer() {
    NSURLConnection *_urlConnection;
    NSMutableData *_audioData;
    NSMutableData *_playlistData;
    NSMutableData *_metaData;
    NSDictionary *_streamHeaders;
    NSString *_contentType;
    NSString *_httpUserAgent;
    NSUInteger _httpTimeout;
    
    int _metadataInterval;
    int _metadataLength;
    int _streamCount;
    int _bitrateInBytes;
    BOOL _icyStartFound;
    BOOL _icyEndFound;
    BOOL _icyHeadersParsed;
    BOOL _connectionFinished;
    
    BOOL _highQualityFormat;
    AudioStreamBasicDescription _hqASBD;
    
    PlaylistType _playlistType;
    NSObject<PlaylistParser> *_playlistParser;
    
    HTTPState _httpState;
    
}

- (void)handlePlayCallback:(AudioQueueRef) inAudioQueue 
                    buffer:(AudioQueueBufferRef) inBuffer;
- (void)handlePropertyChange:(AudioFileStreamID) inAudioFileStream 
                    property:(AudioFileStreamPropertyID) inPropertyID 
                       flags:(UInt32 *)ioFlags;
- (void)handlePacket:(UInt32) inNumberBytes 
     numberOfPackets:(UInt32) inNumberPackets 
           inputData:(const void *)inInputData 
  packetDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions;
- (void)dismissQueue;
- (void)primeQueueBuffers;
- (void)startQueue;
- (void)requestPlaylist;
- (void)requestAudioStream;
- (void)parseAudioData:(NSData *)data;
- (void)setState:(RadioState) state;
- (UInt32)fileTypeHint;
- (void)cleanup;
- (void)startBufferTimerWithTimeout:(NSInteger)timeout;
- (void)startReconnectTimerWithTimeout:(NSInteger)timeout;
- (void)stopBufferTimer;
- (void)stopReconnectTimer;
- (void)onBufferTimerFired:(NSTimer *)timer;
- (void)onReconnectTimerFired:(NSTimer *)timer;
- (void)onReachabilityChanged:(NSNotification *)notification;
- (void)onBackground:(NSNotification *)notification;
- (void)onForeground:(NSNotification *)notification;
@end


static void HTTPPlayCallback(void *inUserData, AudioQueueRef inAudioQueue, AudioQueueBufferRef inBuffer) {
    Streamer *radio = (Streamer *)inUserData;
    [radio handlePlayCallback:inAudioQueue buffer:inBuffer];
}

static void PacketsProc(void *inUserData, UInt32 inNumberBytes, UInt32 inNumberPackets, const void *inInputData, AudioStreamPacketDescription *inPacketDescriptions) {
    Streamer *radio = (Streamer *)inUserData;
    [radio handlePacket:inNumberBytes numberOfPackets:inNumberPackets inputData:inInputData packetDescriptions:inPacketDescriptions];
}

static void PropertyListenerProc(void *inUserData, AudioFileStreamID inAudioFileStream, AudioFileStreamPropertyID inPropertyID, UInt32 *ioFlags) {
    Streamer *radio = (Streamer *)inUserData;
    [radio handlePropertyChange:inAudioFileStream property:inPropertyID flags:ioFlags];
}


@implementation Streamer

@synthesize httpUserAgent = _httpUserAgent;
@synthesize httpTimeout = _httpTimeout;

- (id)initWithURL:(NSURL *)url {
    if(![[url scheme] isEqualToString:@"http"] &&
       ![[url scheme] isEqualToString:@"https"]) {
        return nil;
    }
    
    self = [super initWithURL:url];
    if(self) {
        _httpUserAgent = nil;
        _httpTimeout = 30;
        _httpState = kHTTPStatePlaylistParsing;
        
        _radioTitle = nil;
        _radioName = nil;
        _radioGenre = nil;
        _radioUrl = nil;
        
        _playlistType = kPlaylistNone;
        _playlistParser = nil;
        
        NSString *urlExtension = [_url pathExtension];
        if([urlExtension compare:@"m3u" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            _playlistType = kPlaylistM3U;
            _playlistParser = [[M3UParser alloc] init];
        } else if([urlExtension compare:@"pls" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            _playlistType = kPlaylistPLS;
            _playlistParser = [[PLSParser alloc] init];
        } else if([urlExtension compare:@"xspf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            _playlistType = kPlaylistXSPF;
            _playlistParser = [[XSPFParser alloc] init];
        } else {
            // we will immediately start parsing the audio stream
            _httpState = kHTTPStateAudioStreaming;
        }
        
        _urlConnection = nil;
        _audioData = nil;
        _playlistData = nil;
        _metaData = nil;
        _metadataLength = 0;
        _metadataInterval = 0;
        _bitrateInBytes = 0;
        _streamCount = 0;
        _contentType = nil;
        
        _icyStartFound = NO;
        _icyEndFound = NO;
        _icyHeadersParsed = NO;
        _connectionFinished = NO;
        
        _highQualityFormat = NO;

        
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
        AudioSessionSetActive(true);
      
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_httpUserAgent release];
    [_radioTitle release];
    [_radioName release];
    [_radioGenre release];
    [_radioUrl release];
    [_playlistParser release];
    
    if(_urlConnection) {
        [_urlConnection cancel];
        [_urlConnection release];
        _urlConnection = nil;
    }
    
    
    [_audioData release];
    [_metaData release];
    [_playlistData release];
    [_streamHeaders release];
    [_contentType release];
    
    [super dealloc];
}

- (void)shutdown {
    _shutdown = YES;
    if(!_playerState.paused) {
        [self pause];
    }
    
    if(USE_PLAYER_V2){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Stop_pressed" object:nil];
    }
    
    [self retain];
    dispatch_async(_playerState.lockQueue, ^{
        [self cleanup];
    });
}

- (void)play {
    if(_playerState.playing) {
        return;
    }
    
    _playerState.paused = NO;
    _playerState.playing = YES;
    
    _streamCount = 0;
    _metadataInterval = 0;
    _metadataLength = 0;
    _buffersInUse = 0;
    
    _icyStartFound = NO;
    _icyEndFound = NO;
    _icyHeadersParsed = NO;
    _connectionFinished = NO;
    _connectionError = NO;
    _waitingForReconnection = NO;
    
    if(_metaData == nil) {
        _metaData = [[NSMutableData alloc] init];
    }

    if(_audioData == nil) {
        if(USE_PLAYER_V2){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Play_pressed" object:nil];
        }else{
            _audioData = [[NSMutableData alloc] init];
        }
    }
    
    if(_playlistType != kPlaylistNone && _playlistData == nil) {
        if(USE_PLAYER_V2){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Play_pressed" object:nil];
        }else{
            _playlistData = [[NSMutableData alloc] init];
        }
    }
    
    // this value will be later calculated in PropertyListenerProc
    _playerState.bufferSize = AQ_DEFAULT_BUF_SIZE;
    _playerState.totalBytes = 0;
    
    if(_reachability == nil) {
        _reachability = [[ReachabilityRadioKit reachabilityForInternetConnection] retain];
        [_reachability startNotifier];
    }

    NetworkStatus status = [_reachability currentReachabilityStatus];
    if(status == ReachableViaWWAN) {
        _connectionType = kRadioConnectionTypeWWAN;
    } else if(status == ReachableViaWiFi) {
        _connectionType = kRadioConnectionTypeWiFi;
    }
    
    if([_reachability isReachable]) {
        [self setState:kRadioStateConnecting];
        
        if(_httpState == kHTTPStatePlaylistParsing) {
            [self requestPlaylist];
        } else {
            [self requestAudioStream];
        }
    } else {
        _playerState.playing = NO;
        [_reachability stopNotifier];
        [_reachability release];
        _reachability = nil;
        
        _radioError = kRadioErrorNetworkError;
        [self setState:kRadioStateError];
    }
}

- (void)pause {
    if(_playerState.paused) {
        return;
    }
    
    _playerState.playing = NO;
    _playerState.paused = YES;
    
    if(_urlConnection) {
        [_urlConnection cancel];
        [_urlConnection release];
        _urlConnection = nil;
    }
    
    if(_playerState.started) {
        _playerState.started = NO;
        _playerState.totalBytes = 0.0;
        
        [self dismissQueue];
        
        dispatch_sync(_playerState.lockQueue, ^(void) {
            [_playerState.audioQueue removeAllPackets];
        });
    }
 
    [self stopBufferTimer];
    [self stopReconnectTimer];
    
    if(USE_PLAYER_V2){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Stop_pressed" object:nil];
    }
    
    if(_reachability) {
        [_reachability stopNotifier];
        [_reachability release];
        _reachability = nil;
    }
    
    if(_connectionError) {
        if(!_waitingForReconnection) {
            // start reconnect timer and wait 60 seconds for new connection notification from reachability
            // if we can't establish a new connection within 60 seconds we'll enter the error state
            // and inform the UI about the network connection error.
            _waitingForReconnection = YES;
            [self setState:kRadioStateBuffering];
            
            [self startReconnectTimerWithTimeout:60];
            if(_reachability == nil) {
                _reachability = [[ReachabilityRadioKit reachabilityForInternetConnection] retain];
                [_reachability startNotifier];
            }
            
            NetworkStatus status = [_reachability currentReachabilityStatus];
            if(status == ReachableViaWiFi || status == ReachableViaWWAN) {
                [self stopReconnectTimer];
                DLog(@"Reconnecting to radio stream");
                [self play];
            }
        } else {
            _radioError = kRadioErrorNetworkError;
            [self setState:kRadioStateError];
        }
    } else {
        [self setState:kRadioStateStopped];
    }
}


#pragma mark -
#pragma mark Private Methods
- (void)handlePlayCallback:(AudioQueueRef) inAudioQueue 
                    buffer:(AudioQueueBufferRef) inBuffer {
    if(_playerState.paused) {
        return;
    }
    
    __block int maxBytes = inBuffer->mAudioDataBytesCapacity;
    __block int descriptionCount = 0;
    inBuffer->mAudioDataByteSize = 0;
    
    dispatch_sync(_playerState.lockQueue, ^(void) {
        @autoreleasepool {
            // variable bit rate implementation (VBR)
            if(_playerState.packetDescriptions) {
                AudioPacket *audioPacket = [_playerState.audioQueue peak];
                while(audioPacket) {
                    if(([audioPacket length] + inBuffer->mAudioDataByteSize) < maxBytes) {
                        [audioPacket copyToBuffer:(inBuffer->mAudioData+inBuffer->mAudioDataByteSize) size:[audioPacket length]];
                        _playerState.packetDescriptions[descriptionCount] = [audioPacket audioDescription];
                        _playerState.packetDescriptions[descriptionCount].mStartOffset = inBuffer->mAudioDataByteSize;
                        inBuffer->mAudioDataByteSize += [audioPacket length];
                        
                        audioPacket = [_playerState.audioQueue pop];
                        [audioPacket release];
                        audioPacket = [_playerState.audioQueue peak];
                        descriptionCount++;
                    } else {
                        break;
                    }
                }
            } else { // constant bit rate implementation (CBR)
                AudioPacket *audioPacket = [_playerState.audioQueue peak];
                int dataWritten = 0;
                while(audioPacket) {
                    if((dataWritten + [audioPacket remainingLength]) > maxBytes) {
                        int dataNeeded = (maxBytes - dataWritten);
                        [audioPacket copyToBuffer:(inBuffer->mAudioData+dataWritten) size:dataNeeded];
                        dataWritten += dataNeeded;
                        break;
                    } else {
                        dataWritten += [audioPacket remainingLength];
                        [audioPacket copyToBuffer:(inBuffer->mAudioData+dataWritten) size:[audioPacket remainingLength]];
                         
                         audioPacket = [_playerState.audioQueue pop];
                         [audioPacket release];
                         audioPacket = [_playerState.audioQueue peak];
                    }
                }
                inBuffer->mAudioDataByteSize = dataWritten;
            }
            
            // buffer was used previously
            _buffersInUse--;
            if(inBuffer->mAudioDataByteSize > 0) {
                // descriptionCount = 0, _playerState.packetDescriptions = NULL for CBR streams
                OSStatus result = AudioQueueEnqueueBuffer(inAudioQueue, inBuffer, descriptionCount, _playerState.packetDescriptions);
                if(result != noErr) {
                    DLog(@"could not enqueue buffer");
                    
                    _radioError = kRadioErrorAudioQueueEnqueue;
                    [self setState:kRadioStateError];
                } else {
                    _buffersInUse++;
                    if(_playerState.buffering && (_buffersInUse >= (NUM_AQ_BUFS - 1))) {
                        DLog(@"start playback again, buffers filled up again and ready to go");
                        _playerState.buffering = NO;
                        
                        [self stopBufferTimer];
                        [self primeQueueBuffers];
                        [self startQueue];
                    }
                }
            }
            
            
            if(_buffersInUse == 0 && !_playerState.buffering) {
                if(_connectionFinished) {
                    // connection is closed and all buffers are empty
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self pause];
                    });
                } else {
                    DLog(@"all buffers empty, buffering");
                    AudioQueuePause(inAudioQueue);
                    
                    _playerState.totalBytes = 0.0;
                    _playerState.buffering = YES;
                    [self setState:kRadioStateBuffering];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self startBufferTimerWithTimeout:10];
                    });                
                }
            }
        }
    });
}

- (void)handlePropertyChange:(AudioFileStreamID) inAudioFileStream 
                    property:(AudioFileStreamPropertyID) inPropertyID 
                       flags:(UInt32 *)ioFlags {
    OSStatus err = noErr;
    
    if(inPropertyID == kAudioFileStreamProperty_ReadyToProducePackets) {
        // the audio stream parser is now ready to produce packets
        // get the stream format
        UInt32 asbdSize = sizeof(_playerState.audioFormat);
        err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &asbdSize, &_playerState.audioFormat);
        if(err) {
            DLog(@"Error: get kAudioFileStreamProperty_DataFormat %ld", err);
            _radioError = kRadioErrorFileStreamGetProperty;
            [self setState:kRadioStateError];
            return;
        }
        
        AudioSessionSetActive(true);
        
        if(_highQualityFormat) {
            _playerState.audioFormat = _hqASBD;
        }
        
        // create the audio queue
        err = AudioQueueNewOutput(&_playerState.audioFormat, HTTPPlayCallback, self, NULL, NULL, 0, &_playerState.queue);
        if(err) {
            DLog(@"Error: AudioQueueNewOutput %ld", err);
            _radioError = kRadioErrorAudioQueueCreate;
            [self setState:kRadioStateError];
            return;
        }
        
        bool isFormatVBR = (_playerState.audioFormat.mBytesPerPacket == 0 ||
                            _playerState.audioFormat.mFramesPerPacket == 0);
        if(isFormatVBR) {
            _playerState.packetDescriptions = (AudioStreamPacketDescription *)malloc(AQ_MAX_PACKET_DESCS * sizeof(AudioStreamPacketDescription));
            
            UInt32 maxPacket;
            UInt32 maxPacketSize = 0;
            int maxBufferSize = 0x10000; // 64KB
            err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_PacketSizeUpperBound, &maxPacketSize, &maxPacket);
            if(err) {
                DLog(@"Warning: get kAudioFileStreamProperty_PacketSizeUpperbound %ld", err);
                _playerState.bufferSize = _playerState.audioFormat.mSampleRate * 0.5;
            } else {
                Float64 numBytesForTime = _playerState.audioFormat.mSampleRate * maxPacket * 0.5;
                _playerState.bufferSize = (numBytesForTime < maxBufferSize) ? numBytesForTime : maxBufferSize;
            }
        } else {
            _playerState.packetDescriptions = NULL;
            // calculate buffer size so that there is 0.5 seconds of data in one buffer
            int packetsForTime = (_playerState.audioFormat.mSampleRate / _playerState.audioFormat.mFramesPerPacket) * 0.5;
            _playerState.bufferSize = packetsForTime * _playerState.audioFormat.mBytesPerPacket;
        }
        
        // allocate the audio queue buffers
        for(int i = 0; i < NUM_AQ_BUFS; ++i) {
            err = AudioQueueAllocateBuffer(_playerState.queue, _playerState.bufferSize, &_playerState.queueBuffers[i]);
            if(err) {
                DLog(@"Error: AudioQueueAllocateBuffer %ld", err);
                _radioError = kRadioErrorAudioQueueBufferCreate;
                [self setState:kRadioStateError];
                return;
            }
        }
        
        // get the magic cookie size
        UInt32 cookieSize;
        Boolean writable;
        err = AudioFileStreamGetPropertyInfo(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, &writable);
        if(err) {
            DLog(@"Warning: info kAudioFileStreamProperty_MagicCookieData %ld", err);
            return;
        }
        
        // get the magic cookie data
        void *cookieData = calloc(1, cookieSize);
        err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, cookieData);
        if(err) {
            DLog(@"Warning: get kAudioFileStreamProperty_MagicCookieData %ld", err);
            free(cookieData);
            return;
        }
        
        // set the magic cookie on the queue
        err = AudioQueueSetProperty(_playerState.queue, kAudioQueueProperty_MagicCookie, cookieData, cookieSize);
        free(cookieData);
        if(err) {
            DLog(@"Warning: set kAudioQueueProperty_MagicCookie %ld", err);
            return;
        }
    } else if(inPropertyID == kAudioFileStreamProperty_FormatList) {
        Boolean writable;
        UInt32 propertySize;
        err = AudioFileStreamGetPropertyInfo(inAudioFileStream, kAudioFileStreamProperty_FormatList, &propertySize, &writable);
        if(err) {
            DLog(@"Warning: info kAudioFileStreamProperty_FormatList %ld", err);
            return;
        }
        
        AudioFormatListItem *formatList = malloc(propertySize);
        err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_FormatList, &propertySize, formatList);
        if(err) {
            DLog(@"Warning: get kAudioFileStreamProperty_FormatList %ld", err);
            free(formatList);
            return;
        }
        
        UInt32 numFormats = propertySize / sizeof(AudioFormatListItem);
        DLog(@"This file has a %ld layered data format:", numFormats);
        for(unsigned int i = 0; i < numFormats; i++) {
            // AudioStreamBasicDescription temp = formatList[i].mASBD;
            DLog(@"%ld %f", temp.mFormatID, temp.mSampleRate);
        }
        
        UInt32 itemIndex;
        UInt32 indexSize = sizeof(itemIndex);
        // get the index number of the first playable format -- this index number will be for
        // the highest quality layer the platform is capable of playing
        err = AudioFormatGetProperty(kAudioFormatProperty_FirstPlayableFormatFromList, propertySize, formatList, &indexSize, &itemIndex);
        if(err) {
            DLog(@"Warning: get kAudioFormatProperty_FirstPlayableFormatFromList %ld", err);
            free(formatList);
            return;
        }
        
        _highQualityFormat = YES;
        _hqASBD = formatList[itemIndex].mASBD;
        
        free(formatList);
    }
}

- (void)handlePacket:(UInt32) inNumberBytes 
     numberOfPackets:(UInt32) inNumberPackets 
           inputData:(const void *)inInputData 
  packetDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions {
    dispatch_sync(_playerState.lockQueue, ^(void) {
        @autoreleasepool {
            for(int i = 0; i < inNumberPackets; ++i) {
                AudioStreamPacketDescription description = inPacketDescriptions[i];
                
                NSData *data = [[NSData alloc] initWithBytes:((const char *)inInputData+description.mStartOffset) length:description.mDataByteSize];
                AudioPacket *packet = [[AudioPacket alloc] initWithData:data];
                [packet setAudioDescription:description];
                [_playerState.audioQueue addPacket:packet];
                [data release];
                [packet release];
                
                _playerState.totalBytes += description.mDataByteSize;
            }
        }
    });
    
    if(!_playerState.started && !_playerState.paused && _playerState.totalBytes > (_playerState.bufferInSeconds * _playerState.bufferSize)) {
        DLog(@"total bytes for playback start: %llu", _playerState.totalBytes);
        _playerState.buffering = NO;
        
        [self primeQueueBuffers];
        [self startQueue];
    }
    
    // enqueue audio buffers again after buffering
    if(_playerState.started && !_playerState.paused && _playerState.buffering && _playerState.totalBytes > (_playerState.bufferInSeconds * _playerState.bufferSize)) {
        DLog(@"total bytes for playback start: %llu", _playerState.totalBytes);
        DLog(@"starting playback again");
        _playerState.buffering = NO;
        [self stopBufferTimer];
        
        [self primeQueueBuffers];
        [self startQueue];
    }
}

- (void)dismissQueue {
    if(_playerState.queue) {
        if(_playerState.playing) {
            AudioQueueStop(_playerState.queue, YES);
            _playerState.playing = NO;
        }
        
        AudioQueueDispose(_playerState.queue, YES);
        _playerState.queue = NULL;
        
        if(_playerState.packetDescriptions) {
            free(_playerState.packetDescriptions);
            _playerState.packetDescriptions = NULL;
        }
        
        AudioSessionSetActive(false);
    }
}

- (void)primeQueueBuffers {
    _buffersInUse = NUM_AQ_BUFS;
    for(int i = 0; i < NUM_AQ_BUFS; ++i) {
        HTTPPlayCallback(self, _playerState.queue, _playerState.queueBuffers[i]);
    }
}

- (void)startQueue {
    AudioQueueSetParameter(_playerState.queue, kAudioQueueParam_Volume, _playerState.gain);
    OSStatus err = AudioQueueStart(_playerState.queue, NULL);
    if(err == noErr) {
        _playerState.started = YES;
        _playerState.playing = YES;
        
        [self setState:kRadioStatePlaying];
    } else {
        _radioError = kRadioErrorAudioQueueStart;
        [self setState:kRadioStateError];
    }
}

- (void)requestPlaylist {
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:_url] autorelease];
    [request setCachePolicy:NSURLCacheStorageNotAllowed];
    if(_httpUserAgent) {
        [request setValue:_httpUserAgent forHTTPHeaderField:@"User-Agent"];
    }
    [request setTimeoutInterval:_httpTimeout];
    
    if(_urlConnection) {
        [_urlConnection release];
        _urlConnection = nil;
    }
    
    _urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)requestAudioStream {
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:_url] autorelease];
    [request setCachePolicy:NSURLCacheStorageNotAllowed];
    // Shoutcast Metadata Protocol: http://www.smackfu.com/stuff/programming/shoutcast.html
    [request setValue:@"1" forHTTPHeaderField:@"Icy-Metadata"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    if(_httpUserAgent) {
        [request setValue:_httpUserAgent forHTTPHeaderField:@"User-Agent"];
    }
    [request setTimeoutInterval:_httpTimeout];
    
    if(_urlConnection) {
        [_urlConnection release];
        _urlConnection = nil;
    }
    
    _urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)parseAudioData:(NSData *)data {
    if(_playerState.paused) {
        return;
    }
    
    const char *bytes = [data bytes];
    int length = [data length];
    int streamStart = 0;
    
    if(_metadataInterval == 0) {
        NSString *icyCheck = [[[NSString alloc] initWithBytes:bytes length:10 encoding:NSUTF8StringEncoding] autorelease];
        if(icyCheck && [icyCheck caseInsensitiveCompare:@"ICY 200 OK"] == NSOrderedSame) {
            _icyStartFound = YES;
        }
        
        if(_icyStartFound && !_icyEndFound) {
            int lineStart = 0;
            char c1 = '\0';
            char c2 = '\0';
            char c3 = '\0';
            char c4 = '\0';
            BOOL radioMetadataReady = NO;
            
            for(streamStart = 0; streamStart < length; streamStart++) {
                if((streamStart + 3) > length) {
                    break;
                }
                
                c1 = bytes[streamStart];
                c2 = bytes[streamStart+1];
                c3 = bytes[streamStart+2];
                c4 = bytes[streamStart+3];
                
                if(c1 == '\r' && c2 == '\n') {
                    NSString *fullString = [[[NSString alloc] initWithBytes:bytes length:streamStart encoding:NSUTF8StringEncoding] autorelease];
                    if(fullString == nil) {
                        fullString = [[[NSString alloc] initWithBytes:bytes length:streamStart encoding:NSASCIIStringEncoding] autorelease];
                    }
                    if(fullString) {
                        NSString *line = [fullString substringWithRange:NSMakeRange(lineStart, (fullString.length - lineStart))];
                        NSArray *lineItems = [line componentsSeparatedByString:@":"];
                        if([lineItems count] > 1) {
                            if([[lineItems objectAtIndex:0] caseInsensitiveCompare:@"icy-metaint"] == NSOrderedSame) {
                                _metadataInterval = [[lineItems objectAtIndex:1] intValue];
                            }
                            
                            if([[lineItems objectAtIndex:0] caseInsensitiveCompare:@"icy-br"] == NSOrderedSame) {
                                _bitrateInBytes = ([[lineItems objectAtIndex:1] intValue] * 1000) / 8;
                            }
                            
                            if([[lineItems objectAtIndex:0] caseInsensitiveCompare:@"Content-Type"] == NSOrderedSame) {
                                if(_contentType) {
                                    [_contentType release];
                                    _contentType = nil;
                                }
                                
                                _contentType = [[[lineItems objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] retain];
                            }
                            
                            if([[lineItems objectAtIndex:0] caseInsensitiveCompare:@"icy-name"] == NSOrderedSame) {
                                if(_radioName) {
                                    [_radioName release];
                                    _radioName = nil;
                                }
                                
                                _radioName = [[[lineItems objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] retain];
                                radioMetadataReady = YES;
                            }
                            
                            if([[lineItems objectAtIndex:0] caseInsensitiveCompare:@"icy-genre"] == NSOrderedSame) {
                                if(_radioGenre) {
                                    [_radioGenre release];
                                    _radioGenre = nil;
                                }
                                
                                _radioGenre = [[[lineItems objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] retain];
                                radioMetadataReady = YES;
                            }
                            
                            if([[lineItems objectAtIndex:0] caseInsensitiveCompare:@"icy-url"] == NSOrderedSame) {
                                if(_radioUrl) {
                                    [_radioUrl release];
                                    _radioUrl = nil;
                                }
                                
                                _radioUrl = [[[lineItems objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] retain];
                                radioMetadataReady = YES;
                            }
                        }
                    
                        // end of line
                        lineStart = fullString.length + 2;
                    } else { // fullString == nil
                        lineStart += 2;
                    }
                    
                    if(c3 == '\r' && c4 == '\n') {
                        _icyEndFound = YES;
                        break;
                    }
                }
                
            }
            
            if(_icyEndFound) {
                _icyHeadersParsed = YES;
                streamStart += 4;
                
                OSStatus err = AudioFileStreamOpen(self, PropertyListenerProc, PacketsProc, [self fileTypeHint], &_playerState.streamID);
                if(err != noErr) {
                    DLog(@"Error: AudioFileStreamOpen %ld", err);
                    return;
                }
            }
            
            if(radioMetadataReady) {
                if(_delegate && [_delegate respondsToSelector:@selector(radioMetadataReady:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [_delegate radioMetadataReady:self];
                    });
                }
            }
        }
    }
    
    if(_metadataInterval != 0) {
        for(int i = streamStart; i < length; ++i) {
            if(_metadataLength > 0) {
                if(bytes[i] != '\0') {
                    [_metaData appendBytes:(bytes+i) length:1];
                }
                
                _metadataLength--;
                if(_metadataLength == 0) {
                    NSString *title = [[[NSString alloc] initWithBytes:[_metaData bytes] length:[_metaData length] encoding:NSUTF8StringEncoding] autorelease];
                    NSError *error = nil;
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^StreamTitle='([^;]*)';" options:0 error:&error];
                    if(title && error == nil) {
                        NSTextCheckingResult *match = [regex firstMatchInString:title options:0 range:NSMakeRange(0, [title length])];
                        if(match) {
                            NSRange groupOne = [match rangeAtIndex:1];
                            if(!NSEqualRanges(groupOne, NSMakeRange(NSNotFound, 0))) {
                                NSString *streamTitle = [title substringWithRange:groupOne];
                                
                                if(_radioTitle) {
                                    [_radioTitle release];
                                    _radioTitle = nil;
                                }
                                
                                _radioTitle = [streamTitle retain];
                                if(_delegate && [_delegate respondsToSelector:@selector(radioTitleChanged:)]) {
                                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                                        [_delegate radioTitleChanged:self];
                                    });
                                }
                            }
                        }
                    }
                    
                    [_metaData setLength:0];
                }
                
                
                continue;
            }
            
            if(_metadataInterval > 0 && _streamCount == _metadataInterval) {
                _metadataLength = 16 * bytes[i];
                _streamCount = 0;
                
                continue;
            }
            
            _streamCount++;
            [_audioData appendBytes:(bytes+i) length:1];
            if([_audioData length] == _playerState.bufferSize) {
                AudioFileStreamParseBytes(_playerState.streamID, [_audioData length], [_audioData bytes], 0);
                [_audioData setLength:0];
            }
        }
    } else if(_metadataInterval == 0 && !_icyStartFound) {
        for(int i = streamStart; i < length; i++) {
            [_audioData appendBytes:(bytes+i) length:1];
            if([_audioData length] == _playerState.bufferSize) {
                AudioFileStreamParseBytes(_playerState.streamID, [_audioData length], [_audioData bytes], 0);
                [_audioData setLength:0];
            }
        }
    }
}

- (void)setState:(RadioState) state {
    if(state == _radioState) {
        return;
    }
    
    _radioState = state;
    if(_radioState == kRadioStateError) {
        _playerState.playing = NO;
        _playerState.paused = NO;
        _playerState.buffering = NO;
        _playerState.started = NO;
        _playerState.totalBytes = 0.0;
        
        if(_urlConnection) {
            [_urlConnection cancel];
            [_urlConnection release];
            _urlConnection = nil;
        }
        
        [self dismissQueue];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if(_delegate && [_delegate respondsToSelector:@selector(radioStateChanged:)]) {
            [_delegate radioStateChanged:self];
        }
    });
    
    if(_radioState == kRadioStatePlaying || _radioState == kRadioStateError) {
        if(_bgTask) {
            DLog(@"Ending background task");
            [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
            _bgTask = UIBackgroundTaskInvalid;
        }
    }
}

- (UInt32)fileTypeHint {
    if(_contentType == nil) {
        return 0;
    }
    
    if([_contentType caseInsensitiveCompare:@"audio/mpeg"] == NSOrderedSame) {
        return kAudioFileMP3Type;
    } else if([_contentType caseInsensitiveCompare:@"audio/aac"] == NSOrderedSame) {
        return kAudioFileAAC_ADTSType;
    } else if([_contentType caseInsensitiveCompare:@"audio/aacp"] == NSOrderedSame) {
        return kAudioFileAAC_ADTSType;
    } else {
        return 0;
    }
}

- (void)cleanup {
    [self release];
}

- (void)startBufferTimerWithTimeout:(NSInteger)timeout {
    [self stopBufferTimer];
    
    UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
    if(appState == UIApplicationStateBackground || appState == UIApplicationStateInactive) {
        DLog(@"Starting buffer timer in background");
        if(_bgTask == UIBackgroundTaskInvalid) {
            _bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(_bgTask != UIBackgroundTaskInvalid) {
                        [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
                        _bgTask = UIBackgroundTaskInvalid;
                    }
                });
            }];
        }
    }
    
    DLog(@"Starting buffer timer with timeout: %d", timeout);
    _bufferTimer = [[NSTimer scheduledTimerWithTimeInterval:timeout 
                                                     target:self 
                                                   selector:@selector(onBufferTimerFired:) 
                                                   userInfo:nil 
                                                    repeats:NO] retain];
}

- (void)startReconnectTimerWithTimeout:(NSInteger)timeout {
    [self stopReconnectTimer];
    
    UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
    if(appState == UIApplicationStateBackground || appState == UIApplicationStateInactive) {
        DLog(@"Starting reconnect timer in background");
        if(_bgTask == UIBackgroundTaskInvalid) {
            _bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(_bgTask != UIBackgroundTaskInvalid) {
                        [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
                        _bgTask = UIBackgroundTaskInvalid;
                    }
                });
            }];
        }
    }
    
    DLog(@"Starting reconnect timer with timeout: %d", timeout);
    _reconnectTimer = [[NSTimer scheduledTimerWithTimeInterval:timeout
                                                        target:self
                                                      selector:@selector(onReconnectTimerFired:)
                                                      userInfo:nil
                                                       repeats:NO] retain];
}

- (void)stopBufferTimer {
    if(_bufferTimer) {
        DLog(@"Stopping buffer timer");
        [_bufferTimer invalidate];
        [_bufferTimer release];
        _bufferTimer = nil;
    }
}

- (void)stopReconnectTimer {
    if(_reconnectTimer) {
        DLog(@"Stopping reconnect timer");
        [_reconnectTimer invalidate];
        [_reconnectTimer release];
        _reconnectTimer = nil;
    }
}

- (void)onBufferTimerFired:(NSTimer *)timer {
    [_bufferTimer release];
    _bufferTimer = nil;
    
    if(_reachability == nil) {
        _reachability = [[ReachabilityRadioKit reachabilityForInternetConnection] retain];
        [_reachability startNotifier];
    }
    
    _connectionError = YES;
    [self pause];
}

- (void)onReconnectTimerFired:(NSTimer *)timer {
    [_reconnectTimer release];
    _reconnectTimer = nil;
    
    _connectionError = YES;
    [self pause];
}


- (void)onReachabilityChanged:(NSNotification *)notification {
    if(_reachability) {
        if(_playerState.started && ![_reachability isReachable]) {
            UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
            if(appState == UIApplicationStateBackground || appState == UIApplicationStateInactive) {
                DLog(@"connection dropped while radio is in background");
                if(_bgTask == UIBackgroundTaskInvalid) {
                    _bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(_bgTask != UIBackgroundTaskInvalid) {
                                [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
                                _bgTask = UIBackgroundTaskInvalid;
                            }
                        });
                    }];
                }
            }
        }
        
        if([_reachability isReachable]) {
            if(_waitingForReconnection) {
                [self stopReconnectTimer];
                DLog(@"Reconnecting to radio stream");
                [self play];
            } else if(_playerState.playing && _connectionType == kRadioConnectionTypeWWAN) {
                // Check if we are now connected via WiFi and change to WiFi if so
                NetworkStatus status = [_reachability currentReachabilityStatus];
                if(status == ReachableViaWiFi) {
                    DLog(@"Switching back to WiFi");
                    [self pause];
                    [self play];
                }
            }
        }
    }
}

- (void)onBackground:(NSNotification *)notification {
    if(_radioState == kRadioStateConnecting || _radioState == kRadioStateBuffering) {
        DLog(@"radio is buffering while entering background");
        if(_bgTask == UIBackgroundTaskInvalid) {
            _bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(_bgTask != UIBackgroundTaskInvalid) {
                        [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
                        _bgTask = UIBackgroundTaskInvalid;
                    }
                });
            }];
        }
    }
}

- (void)onForeground:(NSNotification *)notification {
    if(_bgTask != UIBackgroundTaskInvalid) {
		[[UIApplication sharedApplication] endBackgroundTask:_bgTask];
		_bgTask = UIBackgroundTaskInvalid;
	}
}


#pragma mark -
#pragma mark NSURLConnectionDelegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if([httpResponse respondsToSelector:@selector(statusCode)]) {
        int statusCode = [httpResponse statusCode];
        if(statusCode >= 400) {
            _radioError = kRadioErrorNetworkError;
            [self setState:kRadioStateError];
            [connection cancel];
            
            return;
        }
    }
    
    if(_httpState == kHTTPStateAudioStreaming) {
        if(_streamHeaders) {
            [_streamHeaders release];
            _streamHeaders = nil;
        }
        
        _streamHeaders = [[httpResponse caseInsensitiveHTTPHeaders] retain];
        NSString *contentType = [_streamHeaders objectForKey:@"content-type"];
        if(contentType) {
            [_contentType release];
            _contentType = [contentType retain];
        }
        
        NSString *bitrate = [_streamHeaders objectForKey:@"icy-br"];
        if(bitrate) {
            _bitrateInBytes = ([bitrate intValue] * 1000) / 8;
        }
        
        NSString *metaInt = [_streamHeaders objectForKey:@"icy-metaint"];
        if(metaInt) {
            _metadataInterval = [metaInt intValue];
            _icyHeadersParsed = YES;
        }
        
        BOOL radioMetadataReady = NO;
        NSString *radioName = [_streamHeaders objectForKey:@"icy-name"];
        if(radioName) {
            if(_radioName) {
                [_radioName release];
                _radioName = nil;
            }
            _radioName = [radioName retain];
            radioMetadataReady = YES;
        }
        
        NSString *radioGenre = [_streamHeaders objectForKey:@"icy-genre"];
        if(radioGenre) {
            if(_radioGenre) {
                [_radioGenre release];
                _radioGenre = nil;
            }
            _radioGenre = [radioGenre retain];
            radioMetadataReady = YES;
        }
        
        NSString *radioUrl = [_streamHeaders objectForKey:@"icy-url"];
        if(radioUrl) {
            if(_radioUrl) {
                [_radioUrl release];
                _radioUrl = nil;
            }
            _radioUrl = [radioUrl retain];
            radioMetadataReady = YES;
        }
        
        if(radioMetadataReady) {
            if(_delegate && [_delegate respondsToSelector:@selector(radioMetadataReady:)]) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [_delegate radioMetadataReady:self];
                });
            }
        }
        
        [self setState:kRadioStateBuffering];
        
        OSStatus err = AudioFileStreamOpen(self, PropertyListenerProc, PacketsProc, [self fileTypeHint], &_playerState.streamID);
        if(err != noErr) {
            DLog(@"Error: AudioFileStreamOpen %ld", err);
            _radioError = kRadioErrorFileStreamOpen;
            [self setState:kRadioStateError];
            return;
        }
        
        [_metaData setLength:0];
        [_audioData setLength:0];
    } else {
        [_playlistData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(_httpState == kHTTPStateAudioStreaming) {
        [self parseAudioData:data];
    } else {
        [_playlistData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(_httpState == kHTTPStateAudioStreaming) {
        if(_playerState.playing) {
            // check if internet is reachable, if so the radio host could be down
            // in which case there's no need to reconnect.
            if(_reachability && [_reachability isReachable]) {
                [_reachability stopNotifier];
                [_reachability release];
                _reachability = nil;
                
                _radioError = kRadioErrorHostNotReachable;
                [self setState:kRadioStateError];
            } else {
                _connectionError = YES;
                [self pause];
            }
        }
    } else {
        _radioError = kRadioErrorNetworkError;
        [self setState:kRadioStateError];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(_httpState == kHTTPStateAudioStreaming) {
        _connectionFinished = YES;
        if(_playerState.playing) {
            if(_playerState.buffering || _buffersInUse == 0) {
                [self pause];
            }
        }
    } else {
        NSString *streamUrl = [_playlistParser parseStreamUrl:_playlistData];
        NSURL *streamURL = [NSURL URLWithString:streamUrl];
        if(streamURL) {
            [_url release];
            _url = [streamURL retain];
            
            _httpState = kHTTPStateAudioStreaming;
            [self requestAudioStream];
        } else {
            _radioError = kRadioErrorPlaylistParsing;
            [self setState:kRadioStateError];
        }
    }
}

@end
