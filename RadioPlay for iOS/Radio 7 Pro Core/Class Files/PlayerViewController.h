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

@import CoreMotion;
@import AdSupport;
@import StoreKit;
@import FBAudienceNetwork;
@import GoogleMobileAds;
@import SafariServices;

BOOL areAdsRemoved;

#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "GoogleMobileAds/GADInterstitial.h"
#import "GoogleMobileAds/GADInterstitialDelegate.h"

@class AudioStreamer, AutoScrollLabel;

@interface PlayerViewController : UIViewController <UIActionSheetDelegate, NSURLConnectionDataDelegate, RadioDelegate, UIAlertViewDelegate, FBInterstitialAdDelegate, GADInterstitialDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver, SFSafariViewControllerDelegate>
{
	IBOutlet UITextField             *downloadSourceField;
	IBOutlet UIButton                *button;
    IBOutlet UIButton                *facebook;
    IBOutlet UIButton                *twitter;
    IBOutlet UIButton                *share;
    
	IBOutlet UILabel                 *bufferingLabel;
	IBOutlet AutoScrollLabel		 *scrollStream;
    IBOutlet AutoScrollLabel		 *metadataAll;
	IBOutlet UILabel                 *streamName;
    NSString                         *metadataArtist;
	NSString                         *metadataTitle;
	NSString                         *metadataAlbum;
	
	IBOutlet FXImageView             *albumArt;
    IBOutlet FXImageView             *albumArtBlur;
	IBOutlet MPVolumeView            *volumeView;
    UIImage                          *lastFMArt;
	NSTimer							 *clockTimer;
	UILabel                          *digits[7];
    UILabel                          *am;
    UILabel                          *pm;
    NSString                         *pub;

	NSString					     *selectedStreamTitle;
    NSString					     *selectedStream;
    NSString                         *selectedStreamImage;
	
    UISlider                         *volumeSlider;
    IBOutlet UIButton                *removeAdsButton;
    IBOutlet UIButton                *restore;
    
    Radio                            *_radio;
    AVPlayer                         *radioPlayer;
    PlayerViewController             *streamViewController;
    UIActivityIndicatorView          *spinner;
    NSURL                            *musicNSURL;
    
}

@property (nonatomic, strong) NSString                         *metadataArtist;
@property (nonatomic, strong) NSString                         *metadataTitle;
@property (nonatomic, strong) NSString                         *metadataAlbum;

// Google Ads

@property (nonatomic, strong) GADBannerView *adBanner;
@property (nonatomic, strong) GADInterstitial *interstitial;
- (GADRequest *)request;

// Facebook Ads

@property (nonatomic, strong) FBInterstitialAd *interstitialAd;

- (IBAction)restore;
- (IBAction)tapsRemoveAds;
- (IBAction)buttonPressed:(id)sender;
- (IBAction)facebookPressed:(id)sender;
- (IBAction)twitterPressed:(id)sender;
- (IBAction)sharePressed;


- (void)updateAlbumArt;

@property (nonatomic, retain) UIImage                          *lastFMArt;
@property (nonatomic, retain) NSString                         *selectedStreamTitle;
@property (nonatomic, retain) NSString                         *selectedStream;
@property (nonatomic, retain) NSString                         *selectedStreamImage;
@property (nonatomic, retain) NSMutableData                    *responseData;
@property (nonatomic, retain) NSURLConnection                  *connection;
@property (nonatomic, retain) IBOutlet FXImageView             *albumArt;
@property (nonatomic, retain) IBOutlet FXImageView             *albumArtBlur;
@property (nonatomic, retain) IBOutlet UILabel                 *bufferingLabel;
@property (nonatomic, retain) IBOutlet UILabel                 *streamName;
@property (nonatomic, retain) IBOutlet UILabel                 *am;
@property (nonatomic, retain) IBOutlet UILabel                 *pm;

@property (assign) BOOL isquickaction;

@end
