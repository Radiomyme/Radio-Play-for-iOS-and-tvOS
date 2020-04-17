//
//  AppDelegate.m
//  Radio Play by Radiomyme
//

#import "AppDelegate.h"

#import "Reachability.h"
#import "URLCacheAlert.h"
#import "Level1ViewController.h"
#import "PlayerViewController.h"
#import "Settings.h"
#import <StoreKit/StoreKit.h>

const double URLCacheInterval = 0;


NSString *kItemTitleKey		  = @"Radio Name";		        // dictionary key for obtaining the item's title to display in each cell
NSString *kItemTitle2Key	  = @"Radio Stream URL";	    // dictionary key for obtaining the item's title to display in each cell
NSString *ksubtitle           = @"Radio Subtitle";
NSString *kImageFilePathKey   = @"Background Image";	    // dictionary key for obtaining the item's title to display in each cell
NSString *kImageFilePath2Key  = @"Radio Logo";	            // dictionary key for obtaining the item's title to display in each cell
NSString *kChildrenKey		  = @"itemChildren";	        // dictionary key for obtaining the item's children
NSString *kCellIdentifier	  = @"MyIdentifier";	        // the table view's cell identifier
NSString *kFacebook           = @"Facebook ID";             // Facebook ID
NSString *kTwitter            = @"Twitter ID";              // Twitter ID
NSString *km3u8               = @"Radio Stream M3U8";       // m3u8 URL
NSString *QUICK_ACTION_ENABLED = @"";
NSString *Category            = @"";

@implementation AppDelegate

@synthesize window, outlineData, navigationController, myTabBarController;

@synthesize dataPath;
@synthesize filePath;
@synthesize artistfilePath;
@synthesize fileDate;
@synthesize urlArray;
@synthesize updatingText;
@synthesize updateButton;
@synthesize bufferingBg;
@synthesize activityIndicator;
@synthesize uiIsVisible;
@synthesize AdsRemoved;

int UpdatePerformed = 0;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0], NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];
    
    //Here to set your tint color
    //
    //Tips : Choose redColor for red, whiteColor for white...
    
    [self.window setTintColor:[UIColor blueColor]];
    
    self.uiIsVisible = YES;
    
    //Reachability* reachability = [Reachability sharedReachability];
    //[reachability setHostName:@"www.radiomyme.fr"];    // set your host name here
    //NetworkStatus remoteHostStatus = [reachability remoteHostStatus];

    _isLocalEnabled = LOCAL_ENABLED;

    if (_isLocalEnabled)
    {
        [self loadLocalData];
        reloadButton.hidden = YES;
    }
    else
    {
        [self loadNetworkData];
        reloadButton.enabled = YES;
    }
    
    /* set initial state of network activity indicators */
    [UIActivityIndicatorView beginAnimations:nil context:NULL];
    [UIActivityIndicatorView setAnimationDuration:0.0];
    [activityIndicator setAlpha:0];
    [UIActivityIndicatorView commitAnimations];
    
    [UIImageView beginAnimations:nil context:NULL];
    [UIImageView setAnimationDuration:0.0];
    [bufferingBg setAlpha:0];
    [UIImageView commitAnimations];
    
    [UILabel beginAnimations:nil context:NULL];
    [UILabel setAnimationDuration:0.0];
    [updatingText setAlpha:0];
    [UILabel commitAnimations];
    
    
    /* turn off the NSURLCache shared cache */
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                            diskCapacity:0
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache release];
    
    /* prepare to use our own on-disk cache */
    [self initCache];
    
    /* create and load the URL array using the strings stored in PlayerDB.plist */
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PlayerDB" ofType:@"plist"];
    if (path) {
        NSArray *array = [[NSArray alloc] initWithContentsOfFile:path];
        self.urlArray = [[NSMutableArray alloc] init];
        for (NSString *element in array) {
            [self.urlArray addObject:[NSURL URLWithString:element]];
        }
        [array release];
    }
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    
    self.window.rootViewController = myTabBarController;
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    NSString *const QUICK_ACTION_ENABLED = @"";
    
    //Enable Ads or not if the InApp Purchase has been made
    //
    //Tips : You can Enable or Disable Ads in the Settings.m
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    AdsRemoved = [defaults objectForKey:@"AdsRemoved"];
    if ([AdsRemoved isEqualToString:@"YES"])
    {
        areAdsRemoved = YES;
        removeAdsButton.hidden = YES;
        removeAdsButton.enabled = NO;
        NSLog(@"Ads Removed");
    }
    else
    {
        areAdsRemoved = NO;
        NSLog(@"Ads Not Removed");
    }
    
    if(InAppPurchase){
        
    }else{
        removeAdsButton.hidden = YES;
        removeAdsButton.enabled = NO;
        restore.hidden = YES;
        restore.enabled = NO;
    }
    
    //Automatic update at the start if the remote list is enabled
    //
    //Tips : You can activate or not the remote in the Settings.m
    
    if(_isLocalEnabled)
    {
        
    }else{
        [self updateDatabasevoid];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushCategories:)
                                                 name:@"Categories"
                                               object:nil];
    
    return YES;
}

- (void)tabBar:(UITabBarController *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSLog(@"1");
    if(item.tag == 0)
    {
        NSLog(@"1");
    }
}

- (void)pushCategories:(NSNotification *)notification
{
    [self loadLocalData];
}

-(void)updateDatabasevoid
{
    NSLog(@"Update Button Pressed");
    
    UpdatePerformed ++;
    
    ((Level1ViewController*)navigationController.topViewController).myTableView.userInteractionEnabled = NO;
    
    ((Level1ViewController*)navigationController.topViewController).myTableView.alpha = 0.5;
    
    ((Level1ViewController*)navigationController.topViewController).navigationItem.rightBarButtonItem.enabled = NO;
    
    [self startAnimation];
    
    updatingText.text = @"Refreshing";
    
    updateButton.enabled = NO;
    updateButton.tintColor = [UIColor blackColor];
    reloadButton.enabled = NO;
    
    _isLocalEnabled = LOCAL_ENABLED;
    
    if (_isLocalEnabled)
    {
        timer =
        [NSTimer
         scheduledTimerWithTimeInterval:2
         target:self
         selector:@selector(loadLocalData)
         userInfo:nil
         repeats:NO];
    }
    else
    {
        timer =
        [NSTimer
         scheduledTimerWithTimeInterval:2
         target:self
         selector:@selector(updatingDatabase)
         userInfo:nil
         repeats:NO];
    }
}


- (void)postPushToFacbookNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PushFacbookView" object:nil];
}

- (void)postPushToTwitterNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PushTwitterView" object:nil];
}

- (void)postInAppPurchaseNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PushInApp" object:nil];
}

- (void)postRestoreNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PushRestore" object:nil];
}

- (void)dealloc
{
    [window release];
    [dataPath release];
    [filePath release];
    [fileDate release];
    [urlArray release];
    [bufferingBg release];
    [outlineData release];
    [updatingText release];
    [updateButton release];
    [reloadButton release];
    [activityIndicator release];
    [navigationController release];
    [removeAdsButton release];
    [restore release];
    [Picker release];
    [super dealloc];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    self.uiIsVisible = YES;
    
    [self didRefreshPlayerNotification];
    
    if(_isLocalEnabled)
    {
        
    }else{
        if(UpdatePerformed == 0)
        {
            [self updateDatabasevoid];
        }
    }
    
    //Reachability* reachability = [Reachability sharedReachability];
    //[reachability setHostName:@"www.radiomyme.fr"];
    //NetworkStatus remoteHostStatus = [reachability remoteHostStatus];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    self.uiIsVisible = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    self.uiIsVisible = NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    self.uiIsVisible = YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    self.uiIsVisible = NO;
}

- (void)didRefreshPlayerNotification
{
    NSLog(@"Successfully Refreshed Player.");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPlayer" object:nil];
}

- (void)didReceiveRemoteNotification
{
    if(_isLocalEnabled)
    {
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateLevel1" object:nil];
    }else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateLevel1" object:nil];
    }
    
    ((Level1ViewController*)navigationController.topViewController).navigationItem.rightBarButtonItem.enabled = YES;
    
    updateButton.enabled = YES;
    reloadButton.enabled = YES;
    
    updatingText.text = @"Updated";
    
    NSLog(@"Successfully Reloaded Level 1's TableView");
    
    updateButton.enabled = YES;
    reloadButton.enabled = YES;
    
    [self stopAnimation];
}

- (IBAction)updateDatabase:(id)sender
{
    NSLog(@"Update Button Pressed");
    
    UpdatePerformed ++;
    
    ((Level1ViewController*)navigationController.topViewController).myTableView.userInteractionEnabled = NO;
    
    ((Level1ViewController*)navigationController.topViewController).myTableView.alpha = 0.5;
    
    ((Level1ViewController*)navigationController.topViewController).navigationItem.rightBarButtonItem.enabled = NO;
    
    [self startAnimation];
    
    updatingText.text = @"Refreshing";
    
    updateButton.enabled = NO;
    updateButton.tintColor = [UIColor blackColor];
    reloadButton.enabled = NO;
    
    _isLocalEnabled = LOCAL_ENABLED;
    
    if (_isLocalEnabled)
    {
        timer =
        [NSTimer
         scheduledTimerWithTimeInterval:2
         target:self
         selector:@selector(loadLocalData)
         userInfo:nil
         repeats:NO];
    }
    else
    {
        timer =
        [NSTimer
         scheduledTimerWithTimeInterval:2
         target:self
         selector:@selector(updatingDatabase)
         userInfo:nil
         repeats:NO];
    }
}

- (IBAction)tapsRemoveAds{
    NSLog(@"User requests to remove ads");
    
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        
        //If you have more than one in-app purchase, and would like
        //to have the user purchase a different product, simply define
        //another function and replace kRemoveAdsProductIdentifier with
        //the identifier for the other product
        
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kRemoveAdsProductIdentifier]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
        //this is called the user cannot make payments, most likely due to parental controls
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    int count = [response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (IBAction) restore{
    //this is called when the user restores purchases, you should hook this up to a button
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %i", queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored");
            
            //if you have more than one in-app purchase product,
            //you restore the correct product for the identifier.
            //For example, you could use
            //if(productID == kRemoveAdsProductIdentifier)
            //to get the product identifier for the
            //restored purchases, you can use
            //
            //NSString *productID = transaction.payment.productIdentifier;
            [self doRemoveAds];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                [self doRemoveAds]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finish
                if(transaction.error.code == SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}

- (void)doRemoveAds{
    areAdsRemoved = YES;
    removeAdsButton.hidden = YES;
    removeAdsButton.enabled = NO;
    //[[NSUserDefaults standardUserDefaults] setBool:areAdsRemoved forKey:@"areAdsRemoved"];
    NSString *AdsRemoved = @"YES";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:AdsRemoved forKey:@"AdsRemoved"];
    //use NSUserDefaults so that you can load whether or not they bought it
    //it would be better to use KeyChain access, or something more secure
    //to store the user data, because NSUserDefaults can be changed.
    //You're average downloader won't be able to change it very easily, but
    //it's still best to use something more secure than NSUserDefaults.
    //For the purpose of this tutorial, though, we're going to use NSUserDefaults
    [defaults synchronize];
}

- (void)updatingDatabase
{
    [self displayDataWithURL:[urlArray objectAtIndex:0]];
}

- (void)loadNetworkData
{
    ((Level1ViewController*)navigationController.topViewController).myTableView.userInteractionEnabled = NO;
    
    ((Level1ViewController*)navigationController.topViewController).myTableView.alpha = 0.5;
    
    updateButton.enabled = NO;
    updateButton.tintColor = [UIColor blackColor];
    reloadButton.enabled = NO;
    
    [self startAnimation];
    
    updatingText.text = @"Loading";
    
    timer =
    [NSTimer
     scheduledTimerWithTimeInterval:2
     target:self
     selector:@selector(updatingDatabase)
     userInfo:nil
     repeats:NO];
}

- (void)loadLocalData
{
    updateButton.enabled = NO;
    updateButton.tintColor = [UIColor blackColor];
    reloadButton.hidden = YES;
    
    _isLocalEnabled = LOCAL_ENABLED;
    
    if (_isLocalEnabled)
    {
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *audioPath = [documentsDirectory stringByAppendingPathComponent:@"audioplaylistpro.plist"];
        if([Category isEqualToString:@"1"])
        {
            audioPath = [documentsDirectory stringByAppendingPathComponent:@"audioplaylistpro_category1.plist"];
        }
        if([Category isEqualToString:@"2"])
        {
            audioPath = [documentsDirectory stringByAppendingPathComponent:@"audioplaylistpro_category2.plist"];
        }
        if([Category isEqualToString:@"3"])
        {
            audioPath = [documentsDirectory stringByAppendingPathComponent:@"audioplaylistpro_category3.plist"];
        }
        
        if([[NSFileManager defaultManager] fileExistsAtPath:audioPath])
        {
            NSString *path = NSHomeDirectory();
            path = [path stringByAppendingPathComponent:@"Documents"];
            path = [path stringByAppendingPathComponent:@"PlayerDB"];
            if([Category isEqualToString:@"1"])
            {
                path = [path stringByAppendingPathComponent:@"audioplaylistpro_category1.plist"];
            }
            else if ([Category isEqualToString:@"2"])
            {
                path = [path stringByAppendingPathComponent:@"audioplaylistpro_category2.plist"];
            }
            else if ([Category isEqualToString:@"3"])
            {
                path = [path stringByAppendingPathComponent:@"audioplaylistpro_category3.plist"];
            }
            else
            {
                path = [path stringByAppendingPathComponent:@"audioplaylistpro.plist"];
            }
            outlineData = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
        }
        else
        {
            NSString *path = [[NSBundle mainBundle] bundlePath];
            NSString *finalPath = [path stringByAppendingPathComponent:@"audioplaylistpro.plist"];
            if([Category isEqualToString:@"1"])
            {
                finalPath = [path stringByAppendingPathComponent:@"audioplaylistpro_category1.plist"];
            }
            if([Category isEqualToString:@"2"])
            {
                finalPath = [path stringByAppendingPathComponent:@"audioplaylistpro_category2.plist"];
            }
            if([Category isEqualToString:@"3"])
            {
                finalPath = [path stringByAppendingPathComponent:@"audioplaylistpro_category3.plist"];
            }
            outlineData = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
        }
    }
    else
    {
        NSLog (@"Remote Enabled");
        
        NSString *path = NSHomeDirectory();
        path = [path stringByAppendingPathComponent:@"Documents"];
        path = [path stringByAppendingPathComponent:@"PlayerDB"];
        if([Category isEqualToString:@"1"])
        {
            path = [path stringByAppendingPathComponent:@"audioplaylistpro_category1.plist"];
        }
        else if ([Category isEqualToString:@"2"])
        {
            path = [path stringByAppendingPathComponent:@"audioplaylistpro_category2.plist"];
        }
        else if ([Category isEqualToString:@"3"])
        {
            path = [path stringByAppendingPathComponent:@"audioplaylistpro_category3.plist"];
        }
        else
        {
            path = [path stringByAppendingPathComponent:@"audioplaylistpro.plist"];
        }
        outlineData = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
        
        NSLog (@"%@",outlineData);
    }
    
    // fetch the top level items in our outline (level 1)
    NSArray *topLevel1Content = [outlineData objectForKey:kChildrenKey];
    
    // give the top view controller its content
    Level1ViewController* lv1VC =  (Level1ViewController*)(navigationController.topViewController);
    lv1VC.listContent = topLevel1Content;
    [lv1VC.myTableView reloadData];
    [lv1VC updateSearchResultsForSearchController:lv1VC.searchController];
    
    [self didReceiveRemoteNotification];
}

/* show the user that loading activity has started */
- (void)startAnimation
{
    [self.activityIndicator startAnimating];
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
    
    [UIActivityIndicatorView beginAnimations:nil context:NULL];
    [UIActivityIndicatorView setAnimationDuration:0.5];
    [activityIndicator setAlpha:1];
    [UIActivityIndicatorView commitAnimations];
    
    [UIImageView beginAnimations:nil context:NULL];
    [UIImageView setAnimationDuration:0.5];
    [bufferingBg setAlpha:1];
    [UIImageView commitAnimations];
    
    [UILabel beginAnimations:nil context:NULL];
    [UILabel setAnimationDuration:0.5];
    [updatingText setAlpha:1];
    [UILabel commitAnimations];
}

/* show the user that loading activity has stopped */
- (void)stopAnimation
{
    [self.activityIndicator stopAnimating];
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = NO;
    
    [UIActivityIndicatorView beginAnimations:nil context:NULL];
    [UIActivityIndicatorView setAnimationDuration:0.5];
    [activityIndicator setAlpha:0];
    [UIActivityIndicatorView commitAnimations];
    
    [UIImageView beginAnimations:nil context:NULL];
    [UIImageView setAnimationDuration:0.5];
    [bufferingBg setAlpha:0];
    [UIImageView commitAnimations];
    
    [UILabel beginAnimations:nil context:NULL];
    [UILabel setAnimationDuration:0.5];
    [updatingText setAlpha:0];
    [UILabel commitAnimations];
}

- (void)initCache
{
    //create path to cache directory inside the application's Documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"PlayerDB"];
    
    //check for existence of cache directory
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        return;
    }
    
    //create a new cache directory
    if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                         error:&error]) {
        URLCacheAlertWithError(error);
        return;
    }
}

/* get modification date of the current cached data */
- (void)getFileModificationDate
{
    /* default date if file doesn't exist (not an error) */
    self.fileDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        /* retrieve file attributes */
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
        if (attributes != nil) {
            self.fileDate = [attributes fileModificationDate];
        }
        else {
            URLCacheAlertWithError(error);
        }
    }
}

/* display new or existing cached data */
- (void)displayDataWithURL:(NSURL *)theURL
{
    /* release previous instance */
    [filePath release];
    NSString *fileName = [[theURL path] lastPathComponent];
    filePath = [[dataPath stringByAppendingPathComponent:fileName] retain];
    
    /* In this program, "update" means to check the last modified date of the playlist to see if we need to load a new version. */
    [self getFileModificationDate];
    
    /* get the elapsed time since last file update */
    NSTimeInterval time = fabs([fileDate timeIntervalSinceNow]);
    
    [self startAnimation];
    updatingText.text = @"Updating";
    
    NSLog(@"Changes Found Downloading New Database.");
    
    (void) [[URLCacheConnection alloc] initWithURL:theURL delegate:self];
}

- (void)displayCachedData
{
    [self getFileModificationDate];
    
    _isLocalEnabled = LOCAL_ENABLED;
    
    if (_isLocalEnabled)
    {
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *audioPath = [documentsDirectory stringByAppendingPathComponent:@"audioplaylistpro.plist"];
        if([Category isEqualToString:@"1"])
        {
            NSString *audioPath = [documentsDirectory stringByAppendingPathComponent:@"audioplaylistpro_category1.plist"];
        }
        if([Category isEqualToString:@"2"])
        {
            NSString *audioPath = [documentsDirectory stringByAppendingPathComponent:@"audioplaylistpro_category2.plist"];
        }
        if([Category isEqualToString:@"3"])
        {
            NSString *audioPath = [documentsDirectory stringByAppendingPathComponent:@"audioplaylistpro_category3.plist"];
        }
        if([[NSFileManager defaultManager] fileExistsAtPath:audioPath])
        {
            outlineData = [[NSDictionary dictionaryWithContentsOfFile:filePath] retain];
        }
        else
        {
            NSString *path = [[NSBundle mainBundle] bundlePath];
            NSString *finalPath = [path stringByAppendingPathComponent:@"audioplaylistpro_category1.plist"];
            if([Category isEqualToString:@"1"])
            {
                NSString *finalPath = [path stringByAppendingPathComponent:@"audioplaylistpro_category1.plist"];
            }
            if([Category isEqualToString:@"2"])
            {
                NSString *finalPath = [path stringByAppendingPathComponent:@"audioplaylistpro_category2.plist"];
            }
            if([Category isEqualToString:@"3"])
            {
                NSString *finalPath = [path stringByAppendingPathComponent:@"audioplaylistpro_category3.plist"];
            }
            outlineData = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
        }
        
        outlineData = [[NSDictionary dictionaryWithContentsOfFile:filePath] retain];
        
        // fetch the top level items in our outline (level 1)
        NSArray *topLevel1Content = [outlineData objectForKey:kChildrenKey];
        
        // give the top view controller its content
        ((Level1ViewController*)navigationController.topViewController).listContent = topLevel1Content;
        
        [self didReceiveRemoteNotification];
    }
    else
    {
        NSLog (@"Remote Data");
        
        outlineData = [[NSDictionary dictionaryWithContentsOfFile:filePath] retain];
        
        // fetch the top level items in our outline (level 1)
        NSArray *topLevel1Content = [outlineData objectForKey:kChildrenKey];
        
        // give the top view controller its content
        ((Level1ViewController*)navigationController.topViewController).listContent = topLevel1Content;
        
        [self didReceiveRemoteNotification];
    }
    
}

#pragma mark -
#pragma mark URLCacheConnectionDelegate methods

- (void)connectionDidFail:(URLCacheConnection *)theConnection
{
    NSLog(@"Connection Did Fail");
    
    [theConnection release];
    
    updatingText.text = @"Failed";
    
    [self stopAnimation];
    
    updateButton.enabled = YES;
    reloadButton.enabled = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pausePlayer" object:nil];
    
    ((Level1ViewController*)navigationController.topViewController).myTableView.userInteractionEnabled = YES;
    
    ((Level1ViewController*)navigationController.topViewController).myTableView.alpha = 1;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet Connection Required" message:@"To load the Radiomyme database and listen to streaming audio you must have an active internet connection. Please check that you have and active internet connection and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
    
    [self loadLocalData];
}

- (void)connectionDidFinish:(URLCacheConnection *)theConnection
{
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES) {
        
        /* apply the modified date policy */
        [self getFileModificationDate];
        NSComparisonResult result = [theConnection.lastModified compare:fileDate];
        if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
            URLCacheAlertWithError(error);
        }
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO) {
        /* file doesn't exist, so create it */
        [[NSFileManager defaultManager] createFileAtPath:filePath
                                                contents:theConnection.receivedData
                                              attributes:nil];
    }
    else
    {
    }
    
    /* reset the file's modification date to indicate that the URL has been checked */
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil];
    if (![[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:filePath error:&error]) {
        URLCacheAlertWithError(error);
    }
    
    [self displayCachedData];
    [dict release];
    [theConnection release];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    if([[url host] isEqualToString:@"page"]){
        if([[url path] isEqualToString:@"/main"]){
            [self.navigationController setViewControllers:@[[[AppDelegate alloc] init]] animated:YES];
        }
        else if([[url path] isEqualToString:@"/play"]){
            NSString *const QUICK_ACTION_ENABLED = @"station1";
            NSLog(@"Quick Action is now enabled");
        }
        return YES;
    }
    else{
        return NO;
    }
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{
    
    BOOL handledShortCutItem = [self handleShortCutItem:shortcutItem];
    
    completionHandler(handledShortCutItem);
}

- (BOOL)handleShortCutItem : (UIApplicationShortcutItem *)shortcutItem{
    
    BOOL handled = NO;
    
    NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
    
    NSString *shortcutstation1 = [NSString stringWithFormat:@"%@.station1", bundleId];
    
    NSString *shortcutstation2 = [NSString stringWithFormat:@"%@.station2", bundleId];
    
    NSString *shortcutstation3 = [NSString stringWithFormat:@"%@.station3", bundleId];
    
    NSString *shortcutstation4 = [NSString stringWithFormat:@"%@.station4", bundleId];
    
    if ([shortcutItem.type isEqualToString:shortcutstation1]) {
        handled = YES;
        QUICK_ACTION_ENABLED = @"station1";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QuickAction" object:nil];
    }
    
    if ([shortcutItem.type isEqualToString:shortcutstation2]) {
        handled = YES;
        QUICK_ACTION_ENABLED = @"station2";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QuickAction" object:nil];
    }
    
    if ([shortcutItem.type isEqualToString:shortcutstation3]) {
        handled = YES;
        QUICK_ACTION_ENABLED = @"station3";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QuickAction" object:nil];
    }
    
    if ([shortcutItem.type isEqualToString:shortcutstation4]) {
        handled = YES;
        QUICK_ACTION_ENABLED = @"station4";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QuickAction" object:nil];
    }
    return handled;
}

@end
