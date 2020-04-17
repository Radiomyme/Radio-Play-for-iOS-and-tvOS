//
//  AppDelegate.h
//  Radio Play by Radiomyme
//

#import	"URLCacheConnection.h"
#import <StoreKit/StoreKit.h>

#import <UIKit/UIKit.h>

extern NSString *kItemTitleKey;		// dictionary key for obtaining the item's title to display in each cell
extern NSString *kItemTitle2Key;	// dictionary key for obtaining the item's title to display in each cell
extern NSString *kImageFilePathKey;	// dictionary key for obtaining the item's title to display in each cell
extern NSString *kImageFilePath2Key;
extern NSString *ksubtitle;
extern NSString *kChildrenKey;		// dictionary key for obtaining the item's children
extern NSString *kCellIdentifier;	// the table view's cell identifier
extern NSString *kFacebook;
extern NSString *kTwitter;
extern NSString *km3u8;
extern NSString *QUICK_ACTION_ENABLED;
extern NSString *Category;

#define AD_KEY @"adkey"


@interface AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, URLCacheConnectionDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>
{
    NSTimer							 *timer;
	NSDate                           *fileDate;
	NSError                          *error;
    UIWindow				         *window;
	NSString                         *dataPath;
	NSString                         *filePath;
    NSString                         *artistfilePath;
	NSDictionary		             *outlineData;
    NSMutableArray                   *urlArray;
    UITabBarController	             *myTabBarController;
    UITabBarItem                     *radioTab;
    UITabBarItem                     *facebookTab;
    UITabBarItem                     *twitterTab;
	UINavigationController	         *navigationController;
    IBOutlet UIButton *removeAdsButton;
    IBOutlet UIButton *reloadButton;
    IBOutlet UIButton *restore;
    IBOutlet UIPickerView *Picker;
    NSArray *dataarray;
    IBOutlet UITextField *textField;
    IBOutlet UIToolbar *toolbar;

	UILabel							 *updatingText;
	UIImageView						 *bufferingBg;
	UIBarButtonItem					 *updateButton;
	UIActivityIndicatorView			 *activityIndicator;
    BOOL							 uiIsVisible;
    int                              selector_category;
}

@property (assign) BOOL isLocalEnabled;
@property (assign) BOOL isquickaction;

@property (nonatomic, retain) IBOutlet UIWindow                 *window;
@property (nonatomic, retain) IBOutlet UILabel                  *updatingText;
@property (nonatomic, retain) IBOutlet UIImageView              *bufferingBg;
@property (nonatomic, retain) IBOutlet UIBarButtonItem          *updateButton;
@property (nonatomic, retain) IBOutlet UITabBarController       *myTabBarController;
@property (nonatomic, retain) IBOutlet UITabBarItem             *radioTab;
@property (nonatomic, retain) IBOutlet UITabBarItem             *facebookTab;
@property (nonatomic, retain) IBOutlet UITabBarItem             *twitterTab;
@property (nonatomic, retain) IBOutlet UINavigationController   *navigationController;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView  *activityIndicator;
@property (nonatomic) BOOL									    uiIsVisible;

@property (nonatomic, retain) NSDate                            *fileDate;
@property (nonatomic, retain) NSDictionary                      *outlineData;
@property (nonatomic, retain) NSMutableArray                    *urlArray;

@property (nonatomic, copy) NSString                            *dataPath;
@property (nonatomic, copy) NSString                            *filePath;
@property (nonatomic, copy) NSString                            *artistfilePath;
@property (nonatomic, copy) NSString                            *AdsRemoved;

@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchBarController;

- (IBAction)updateDatabase:(id)sender;
- (IBAction)restore;
- (IBAction)tapsRemoveAds;

- (void)didReceiveRemoteNotification;
- (void)didRefreshPlayerNotification;
- (void)loadNetworkData;
- (void)loadLocalData;

@end
