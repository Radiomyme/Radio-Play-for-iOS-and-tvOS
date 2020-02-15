//
//  ABITunesWrapper.m
//  Radio Play
//
//  Created by Amin Benarieb on 16/08/2017.
//
//

#import "ABITunesWrapper.h"

static NSString* const kiTunesTrackURL = @"https://itunes.apple.com/search?term=%@&media=music";
static NSString* const kResultJSONKeyResults = @"results";
static NSString* const kResultJSONKeyCollectionName = @"collectionName";
static NSString* const kResultJSONKeyArtworkUrl = @"artworkUrl100";
static NSString* const kResultJSONKeyMusicUrl = @"trackViewUrl";
static NSString* const kLastFMAPIKEY = @"0b50f9e072e81512eae02cb870a5353d";

@implementation ABITunesWrapperInfo : NSObject
@end

@implementation ABITunesResultInfo
@end


@implementation ABITunesWrapper

- (void)requestAlbumInfoFrom:(ABITunesWrapperInfo *)info completion:(ABITunesWrapperResult)completion
{
    NSString *encodedArtistName = [info.artistName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *encodedTrackName = [info.trackName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *trackQueury = [NSString stringWithFormat:@"%@+%@", encodedArtistName, encodedTrackName];
    trackQueury = [NSString stringWithFormat:kiTunesTrackURL, trackQueury];
    NSURL *url = [NSURL URLWithString:trackQueury];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:url];
    
    NSLog(@"COLLECTION NAME (trackQueury): %@", trackQueury);
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
          
          ABITunesResultInfo *resultInfo = [ABITunesResultInfo new];
          
          // Handling error
          if (error)
          {
              completion(nil, error);
              return;
          }
          
          // Handling jsonError
          NSError *jsonError = nil;
          if (jsonError)
          {
              completion(nil, jsonError);
              return;
          }
          
          // Gettting results from JSON
          id json = [NSJSONSerialization JSONObjectWithData:data options:nil error:&jsonError];
          NSArray *results = json[kResultJSONKeyResults];
          
          // Getting *only first* result
          NSDictionary *firstItem = [results firstObject];
          
          // Halding resutls
          if (![firstItem isKindOfClass:[NSDictionary class]])
          {
              completion(nil, nil);
          }
          NSString *collectionName = firstItem[kResultJSONKeyCollectionName];
          if ([collectionName isKindOfClass:[NSString class]])
          {
              resultInfo.collectionName = collectionName;
          }
          
          // Collection name
          NSString *artWork = firstItem[kResultJSONKeyArtworkUrl];
          if ([artWork isKindOfClass:[NSString class]])
          {
              // Getting 500x500 artWork size
              artWork = [artWork stringByReplacingOccurrencesOfString:@"100" withString:@"1000"];
              resultInfo.artworkURL = [NSURL URLWithString:artWork];
          }
          
          NSString *MusicURL = firstItem[kResultJSONKeyMusicUrl];
          if ([MusicURL isKindOfClass:[NSString class]])
          {
              [MusicURL stringByReplacingOccurrencesOfString:@"https://itunes.apple.com/us/" withString:@"https://itunes.apple.com/"];
              resultInfo.musicURL = [NSURL URLWithString:MusicURL];
          }
          
          completion(resultInfo, nil);
      }] resume];
    
}

@end
