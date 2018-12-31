//
//  ABITunesWrapper.h
//  Radio Play
//
//  Created by Amin Benarieb on 16/08/2017.
//
//

#import <Foundation/Foundation.h>

@class ABITunesResultInfo;
typedef void(^ABITunesWrapperResult)(ABITunesResultInfo *, NSError *);

@interface ABITunesWrapperInfo : NSObject
@property (nonatomic, retain) NSString *artistName;
@property (nonatomic, retain) NSString *trackName;
@end

@interface ABITunesResultInfo : NSObject
@property (nonatomic, retain) NSString *collectionName;
@property (nonatomic, retain) NSURL    *artworkURL;
@property (nonatomic, retain) NSURL    *musicURL;
@property (nonatomic, retain) NSNumber *trackId;
@property (nonatomic, retain) NSNumber *artistId;
@property (nonatomic, retain) NSNumber *collectionId;
@end

@interface ABITunesWrapper : NSObject

- (void)requestAlbumInfoFrom:(ABITunesWrapperInfo *)info completion:(ABITunesWrapperResult)completion;

@end
