//
//  PlayerViewController.h
//  Radio Play by Radiomyme
//

#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AutoScrollLabel.h"
#import <CFNetwork/CFNetwork.h>
#import "Radio.h"
#import <UIKit/UIKit.h>
#import "FXImageView.h"
#import <StoreKit/StoreKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>

@import CoreMotion;
@import AdSupport;
@import StoreKit;
@import SafariServices;

BOOL areAdsRemoved;

@class AudioStreamer, AutoScrollLabel;

@interface PlayerViewController : UIViewController <UIActionSheetDelegate, NSURLConnectionDataDelegate, RadioDelegate, UIAlertViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver, SFSafariViewControllerDelegate>
{
    IBOutlet UITextField             *downloadSourceField;
    IBOutlet UIButton                *button;
    IBOutlet UIButton                *facebook;
    IBOutlet UIButton                *twitter;
    IBOutlet UIButton                *open_music;
    IBOutlet UIButton                *share;
    IBOutlet UIButton                *airplay;

    IBOutlet AutoScrollLabel         *scrollStream;
    IBOutlet AutoScrollLabel         *metadataAll;
    IBOutlet UILabel                 *streamName;
    NSString                         *metadataArtist;
    NSString                         *metadataTitle;
    NSString                         *metadataAlbum;
    IBOutlet UISlider                *slider;

    IBOutlet FXImageView             *albumArt;
    IBOutlet FXImageView             *albumArtBlur;
    NSString                         *pub;
    IBOutlet UIImage                 *radio_albumArt;

    NSString                         *selectedStreamTitle;
    NSString                         *selectedStream;
    NSString                         *selectedStreamImage;

    UISlider                         *volumeSlider;
    IBOutlet UIButton                *removeAdsButton;
    IBOutlet UIButton                *restore;
    IBOutlet UIButton                *RemoveAds;

    Radio                            *_radio;
    AVPlayer                         *radioPlayer;
    PlayerViewController             *streamViewController;
    UIActivityIndicatorView          *spinner;
    NSURL                            *musicNSURL;
}

@property (nonatomic, strong) NSString                         *metadataArtist;
@property (nonatomic, strong) NSString                         *metadataTitle;
@property (nonatomic, strong) NSString                         *metadataAlbum;

- (IBAction)restore;
- (IBAction)tapsRemoveAds;
- (IBAction)buttonPressed:(id)sender;
- (IBAction)facebookPressed:(id)sender;
- (IBAction)twitterPressed:(id)sender;
- (IBAction)open_musicPressed:(id)sender;
- (IBAction)sharePressed;
- (IBAction)airplayPressed;
- (IBAction)removeAds:(id)sender;

- (void)updateAlbumArt;

@property (nonatomic, retain) NSString                         *selectedStreamTitle;
@property (nonatomic, retain) NSString                         *selectedStream;
@property (nonatomic, retain) NSString                         *selectedStreamImage;
@property (nonatomic, retain) NSMutableData                    *responseData;
@property (nonatomic, retain) NSURLConnection                  *connection;
@property (nonatomic, retain) IBOutlet FXImageView             *albumArt;
@property (nonatomic, retain) IBOutlet FXImageView             *albumArtBlur;
@property (nonatomic, retain) IBOutlet UIImage                 *radio_albumArt;
@property (nonatomic, retain) IBOutlet UILabel                 *bufferingLabel;
@property (nonatomic, retain) IBOutlet UILabel                 *streamName;
@property (nonatomic, retain) IBOutlet UIButton                *airplay;
@property (nonatomic, retain) AVRoutePickerView                *routerPickerView;

// Volume Slider

@property (weak, nonatomic) IBOutlet UISlider                *slider;
- (IBAction)sliderAction:(id)sender;

@property (assign) BOOL isquickaction;

@end
