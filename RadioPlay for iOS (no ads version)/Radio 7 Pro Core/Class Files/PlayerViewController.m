//
//  PlayerViewController.m
//  Radio Play by Radiomyme
//

#import "PlayerViewController.h"
#import <QuartzCore/CAAnimation.h>
#import "UIImageView+LBBlurredImage.h"
#import "UIImageView+WebCache.h"
#import "Streamer.h"
#import "Settings.h"
#import "AppDelegate.h"
#import "UIImage+FX.h"
#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>
#import "ABITunesWrapper.h"
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>

#define SAFE_STRING(str) str != nil && str != NULL && [str isKindOfClass:[NSString class]] && [str conformsToProtocol:@protocol(NSCopying)] ? str : @""

MPMoviePlayerController *controller;

@implementation PlayerViewController

@synthesize metadataTitle = _metadataTitle;
@synthesize metadataArtist = _metadataArtist;
@synthesize metadataAlbum = _metadataAlbum;
@synthesize selectedStreamTitle;
@synthesize selectedStream;
@synthesize selectedStreamImage;
@synthesize bufferingLabel;
@synthesize streamName;
@synthesize albumArt;
@synthesize albumArtBlur;

static void InterruptionListenerCallback(void *inUserData, UInt32 interruptionState)
{
    PlayerViewController *playerViewController = (__bridge PlayerViewController *)inUserData;
    if(interruptionState == kAudioSessionBeginInterruption) {
        [playerViewController beginInterruption];
    } else if(interruptionState == kAudioSessionEndInterruption) {
        AudioSessionSetActive(true);
        [playerViewController endInterruption];
    }
}

//--------------------------------------
//-------- Adapt your Album Art  -------
//--------------------------------------

- (void)defaultalbumart
{
    if([selectedStreamImage isEqualToString:@""])
    {
        self.albumArt.image = [UIImage imageNamed:@"defaultalbum.png"];
    }
    else
    {
        NSString *filePath = [NSString stringWithFormat:@"%@", selectedStreamImage];
        if(filePath)
        {
            self.albumArt.image = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
        }
        else
        {
            self.albumArt.image = [UIImage imageNamed:@"defaultalbum.png"];
        }
    }

    if(Activate_Reflection_Effect)
    {
        self.albumArt.reflectionScale = 0.2f;
        self.albumArt.reflectionAlpha = 0.25f;
    }
    else
    {
        self.albumArt.reflectionScale = 0.0f;
        self.albumArt.reflectionAlpha = 0.0f;
    }
    self.albumArt.reflectionGap = 0.0f;

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if (appDelegate.uiIsVisible)
    {
        [self.albumArtBlur setImageToBlur:self.albumArt.image
                               blurRadius:kLBBlurredImageDefaultBlurRadius
                          completionBlock:^(NSError *error){

            if(Activate_Blur_Effect)
            {
                [UIImageView beginAnimations:nil context:NULL];
                [self.albumArtBlur setAlpha:0.4];
            }
            else
            {
                self.albumArtBlur.image = nil;
            }

            [UIImageView beginAnimations:nil context:NULL];
            [self.albumArt setAlpha:1];
        }];
    }

    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");

    if (playingInfoCenter)
    {
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];

        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:self.albumArt.image];

        NSLog(@"updateAlbumArtImageWithURL %@ - %@ -%@ - %@", self.metadataArtist, self.metadataTitle, self.metadataAlbum, artwork);

        [songInfo setObject:SAFE_STRING(self.metadataArtist) forKey:MPMediaItemPropertyArtist];
        [songInfo setObject:SAFE_STRING(self.metadataTitle) forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:SAFE_STRING(self.metadataAlbum) forKey:MPMediaItemPropertyAlbumTitle];
        [songInfo setObject:@(1) forKey:MPNowPlayingInfoPropertyPlaybackRate];
        [songInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
}

//--------------------------------------
//---------- PLAYER CREATION  ----------
//--------------------------------------

- (void)setButtonImage:(UIImage *)image
{

    if (!image)
    {
    }
    else
    {
        [button setImage:image forState:0];
    }
}

- (void)setMusicImage:(UIImage *)image
{

    if (!image)
    {
    }
    else
    {
        [open_music setImage:image forState:0];
    }
}

- (void)createStreamer
{
    _radio = [[Streamer alloc] initWithURL:[NSURL URLWithString:downloadSourceField.text]];

    if(_radio) {
        [_radio setDelegate:self];
        [_radio play];
    }
}

- (void)streamerPlay
{
    [downloadSourceField resignFirstResponder];

    [self createStreamer];
}

- (UILabel *)createLabelWithBackgroundInRect:(CGRect)rect withStartText:(NSString *)startText
{
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:55.0]];
    label.backgroundColor = [UIColor clearColor];
    [label setTextColor:[UIColor colorWithRed:255.0 / 255 green:255.0 / 255 blue:255.0 / 255 alpha:1.0]];

    [self.view addSubview:label];
    label.text = startText;
    label.textAlignment = NSTextAlignmentRight;
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    return label;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    UIApplication *application = [UIApplication sharedApplication];

    if([application respondsToSelector:@selector(beginReceivingRemoteControlEvents)])
        [application beginReceivingRemoteControlEvents];

    [self becomeFirstResponder];

    CGSize result = [[UIScreen mainScreen] bounds].size;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    AudioSessionInitialize(NULL, NULL, InterruptionListenerCallback, (__bridge void *)(self));

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshPlayer:)
                                                 name:@"refreshPlayer"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopPlayer:)
                                                 name:@"stopPlayer"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pausePlayer:)
                                                 name:@"pausePlayer"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(InAppPressed:)
                                                 name:@"InAppPressed"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(RestorePressed:)
                                                 name:@"RestorePressed"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(Play_pressed:)
                                                 name:@"Play_pressed"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(Stop_pressed:)
                                                 name:@"Stop_pressed"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(Pause_pressed:)
                                                 name:@"Pause_pressed"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChanged:)
                                                 name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];

    slider.value=[[MPMusicPlayerController applicationMusicPlayer] volume];

    [bufferingLabel setFrame:CGRectMake(110, 118, 100, 18)];

    [albumArt setFrame:CGRectMake(0, 140, 500, 500)];

    [button setFrame:CGRectMake(17, 431, 40, 40)];

    CGSize result = [[UIScreen mainScreen] bounds].size;

    [scrollStream setFrame:CGRectMake(8, result.width/2, 305, 30)];

    [metadataAll setFrame:CGRectMake(8, result.width/2, 305, 25)];

    int dimension = ((int)[[UIScreen mainScreen] nativeBounds].size.height);

    self.slider.hidden = YES;
    self.airplay.hidden = NO;

    if(Activate_Volume_Slider)
    {
        self.slider.hidden = NO;

        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame: CGRectMake(-1000, -1000, 100, 100)];
        [self.view addSubview:volumeView];

        for (UIView *view in [volumeView subviews]){
            if([view isKindOfClass:[UISlider class]]) {
                UISlider *slider_value = (UISlider*) view;
                CGFloat volume = slider_value.value; // this is the current volume
                self.slider.value = volume;
            }
        }

        self.airplay.hidden = NO;

        // Airplay Button
        if (@available(iOS 11.0, *)) {
            //UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            //CGPoint p = [self.airplay convertPoint:self.airplay.frame.origin fromView:window];

            NSLog(@"Frame %f X %f Y %f",self.airplay.frame.origin.y,(648*result.height/812),(335*result.width/375));

            self.routerPickerView = [[AVRoutePickerView alloc] initWithFrame:CGRectMake((335*result.width/375), (648*result.height/812)+5, 30, 30)];
            self.routerPickerView.activeTintColor = [UIColor clearColor];
            self.routerPickerView.delegate = self;
            [self.view addSubview:self.routerPickerView];

            self.routerPickerView.hidden = YES;
        } else {
            // Fallback on earlier versions
        }
    }

    [scrollStream setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:25.0]];

    [metadataAll setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0]];

    [bufferingLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]];

    downloadSourceField.text = selectedStream;

    streamName.text = selectedStreamTitle;

    [UILabel beginAnimations:nil context:NULL];
    [UILabel setAnimationDuration:0];
    [bufferingLabel setAlpha:0.2];
    [UILabel commitAnimations];

    removeAdsButton.hidden = YES;
    removeAdsButton.enabled = NO;
    restore.hidden = YES;
    restore.enabled = NO;

    [self streamerPlay];

    if ([Station_Title isEqualToString:@"NRJ"] || [Station_Title isEqualToString:@"Rire et Chansons"] || [Station_Title isEqualToString:@"CherieFM"] || [Station_Title isEqualToString:@"RMC"] || [Station_Title isEqualToString:@"FranceINFO"] || [Station_Title isEqualToString:@"FranceINTER"] || [Station_Title isEqualToString:@"Mouv'"] || [Station_Title isEqualToString:@"Nostalgie"] || [Station_Title isEqualToString:@"Fip"] || [Station_Title isEqualToString:@"Radio Nova"] || [Station_Title isEqualToString:@"Antenna 1"])
    {
        [self defaultalbumart];
        scrollStream.text = Station_Title;
        metadataAll.text = Station_Subtitle;
    }

    Album_size = [[NSNumber numberWithFloat:result.width] stringValue];
}

- (void)volumeChanged:(NSNotification *)notification
{
    float volume =[[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    self.slider.value = volume;
}

- (IBAction)removeAds:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Remove Ads"
                                                                             message:@"Remove any ads from Radio Play"
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Remove Ads"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
        [self tapsRemoveAds];
        [self updateAlbumCollectionName];
        [self updateAlbumArt];
    }];
    UIAlertAction *actionRestore = [UIAlertAction actionWithTitle:@"Restore your purchase"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
        [self restore];
        [self updateAlbumCollectionName];
        [self updateAlbumArt];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                   {
        [self updateAlbumCollectionName];
        [self updateAlbumArt];
    }];

    [alertController addAction:actionOk];
    [alertController addAction:actionRestore];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)sliderAction:(id)sender
{
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:self.slider.value];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPlayer" object:nil];
}

-(void) saveDebt:(CGFloat) debtAmount forName:(NSString *) debtorName
{
    // pointer to standart user defaults
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    // the mutalbe array of all debts
    NSMutableArray * alldebtRecords = [[defaults objectForKey:AD_KEY] mutableCopy];
    // create new record
    // to save CGFloat you need to wrap it into NSNumber
    NSNumber * amount = [NSNumber numberWithFloat:debtAmount];

    NSDictionary * newRecord = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:amount,debtorName, nil] forKeys:[NSArray arrayWithObjects:AD_KEY, nil]];
    [alldebtRecords addObject:newRecord];
    [defaults setObject:alldebtRecords forKey:AD_KEY];
    // do not forget to save changes
    [defaults synchronize];
}

- (void)stopPlayer:(NSNotification *)notification
{
    if(_radio) {

        [_radio shutdown];
        [_radio release];
        _radio = nil;
    }

    if([pub  isEqual: @"ON"])
    {
        [self streamerPlay];
    }
}

- (void)pausePlayer:(NSNotification *)notification
{
    if([_radio isPlaying]) {

        [_radio pause];
    }
    else
    {
        [_radio play];
    }
}

- (void)refreshPlayer:(NSNotification *)notification
{
    NSLog(@"refreshPlayer");

    if(metadataAll.text.length > 35)
    {
        [metadataAll scroll];
    }

    if(scrollStream.text.length > 30)
    {
        [scrollStream scroll];
    }

    NSUserDefaults *savedPlayerStatus = [NSUserDefaults standardUserDefaults];

    NSString *playing = [savedPlayerStatus stringForKey:@"Player"];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([playing isEqualToString:@"Playing"])
    {
        [self updateAlbumCollectionName];
    }
    else if ([playing isEqualToString:@"Paused"])
    {
        [self setButtonImage:[UIImage imageNamed:@"pausebtn.png"]];
        [self updateAlbumCollectionName];
    }
    else
    {
        [self setButtonImage:[UIImage imageNamed:@"playbtn.png"]];
        [self updateAlbumCollectionName];
    }
}

- (IBAction)buttonPressed:(id)sender
{
    [downloadSourceField resignFirstResponder];

    if([_radio isPlaying]) {

        [_radio pause];
    }
    else
    {
        [_radio play];
    }
}

//Facebook

- (IBAction)facebookPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PushFacebookView" object:nil];
}

//Twitter

- (IBAction)twitterPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PushTwitterView" object:nil];
}

//Open Music

- (IBAction)open_musicPressed:(id)sender {

    NSString *null_music = musicNSURL.absoluteString;

    if(Open_Music)
    {
        if(!musicNSURL)
        {
            SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:open_music_URL] entersReaderIfAvailable:NO];

            safariVC.delegate = self;
            [self presentViewController:safariVC animated:YES completion:nil];
        }
        else
        {
            [[UIApplication sharedApplication] openURL:musicNSURL];
            NSLog(@"musicNSURL : %@",musicNSURL);
        }
    }
    else
    {
        SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:open_music_URL] entersReaderIfAvailable:NO];

        safariVC.delegate = self;
        [self presentViewController:safariVC animated:YES completion:nil];
    }
}

//Airplay
- (IBAction)airplayPressed {
    UIButton *routePickerButton = self.routerPickerView.subviews.firstObject;
    //NSLog(@"Route Picker : %@",routePickerButton);
    [routePickerButton sendActionsForControlEvents: UIControlEventTouchUpInside];
}

//Share

- (IBAction)sharePressed {
    NSString *sample1 = @"Now Live on ";
    NSString *sample2 = @" : ";
    NSString *sample3 = @" by ";
    NSURL *url = [NSURL URLWithString:Default_URL];

    NSString *text = [NSString stringWithFormat:@"%@%@%@%@%@%@ %@", sample1, selectedStreamTitle, sample2, self.metadataTitle, sample3, self.metadataArtist, url];

    UIImage *image_share;

    if(Share_whith_station_logo)
    {
        if([selectedStreamImage isEqualToString:@""])
        {
            image_share = [UIImage imageNamed:@"defaultalbum.png"];
        }
        else
        {
            NSString *filePath = [NSString stringWithFormat:@"%@", selectedStreamImage];
            if(filePath)
            {
                image_share = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
            }
            else
            {
                image_share = [UIImage imageNamed:@"defaultalbum.png"];
            }
        }
    }else{
        if(albumArt.image)
        {
            image_share = [albumArt.image copy];
        }
        else
        {
            image_share = [UIImage imageNamed:@"defaultalbum.png"];
        }
    }

    UIActivityViewController *Sharecontroller = [[UIActivityViewController alloc] initWithActivityItems:@[text, image_share] applicationActivities:nil];

    Sharecontroller.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypeAssignToContact];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // For iPhone
        [self presentViewController:Sharecontroller animated:YES completion:nil];
    }
    else {
        // For iPad, present it as a popover as you already know
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:Sharecontroller];
        //Change rect according to where you need to display it. Using a junk value here
        [popup presentPopoverFromRect:CGRectMake((share.frame.origin.x), (share.frame.origin.y), 0, 0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }

    Sharecontroller.completionWithItemsHandler = ^(NSString *activityType,
                                                   BOOL completed,
                                                   NSArray *returnedItems,
                                                   NSError *error){
        // react to the completion
        if (completed) {
            // user shared an item
            [self updateAlbumCollectionName];
            [self updateAlbumArt];
            NSLog(@"We used activity type%@", activityType);
        } else {
            // user cancelled
            [self updateAlbumCollectionName];
            [self updateAlbumArt];
            NSLog(@"We didn't want to share anything after all.");
        }

        if (error) {
            NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
        }
    };
}

//The End

- (void)radioStateChanged:(Radio *)radio
{
    RadioState state = [_radio radioState];
    if(state == kRadioStateConnecting) {
    }
    else if(state == kRadioStateBuffering) {

        if(USE_PLAYER_V2){

        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"isNotPlaying" object:nil];

            [self setButtonImage:[UIImage imageNamed:@"pausebtn.png"]];

            [UILabel beginAnimations:nil context:NULL];
            [bufferingLabel setAlpha:1];
        }
    }
    else if(state == kRadioStatePlaying) {

        [[NSNotificationCenter defaultCenter] postNotificationName:@"isPlaying" object:nil];

        [self setButtonImage:[UIImage imageNamed:@"pausebtn.png"]];

        [UILabel beginAnimations:nil context:NULL];
        [bufferingLabel setAlpha:0.2];

        NSUserDefaults *playerStatus = [NSUserDefaults standardUserDefaults];

        [playerStatus setObject:@"Playing" forKey:@"Player"];
    }
    else if(state == kRadioStateStopped) {

        [[NSNotificationCenter defaultCenter] postNotificationName:@"isNotPlaying" object:nil];

        [self setButtonImage:[UIImage imageNamed:@"playbtn.png"]];

        [UILabel beginAnimations:nil context:NULL];
        [UILabel setAnimationDuration:0.5];
        [bufferingLabel setAlpha:0.2];
        [UILabel commitAnimations];

        NSUserDefaults *playerStatus = [NSUserDefaults standardUserDefaults];

        [playerStatus setObject:@"Stopped" forKey:@"Player"];

        [self defaultalbumart];
        scrollStream.text = Station_Title;
        metadataAll.text = @"Press Play";
    }
    else if(state == kRadioStateError) {

        [[NSNotificationCenter defaultCenter] postNotificationName:@"isNotPlaying" object:nil];

        [self setButtonImage:[UIImage imageNamed:@"playbtn.png"]];

        [UILabel beginAnimations:nil context:NULL];
        [bufferingLabel setAlpha:0.2];

        NSUserDefaults *playerStatus = [NSUserDefaults standardUserDefaults];

        [playerStatus setObject:@"Stopped" forKey:@"Player"];
    }

    RadioError error = [_radio radioError];
    if(error == kRadioErrorAudioQueueBufferCreate) {

    } else if(error == kRadioErrorAudioQueueCreate) {

        NSLog(@"kRadioErrorAudioQueueCreate");

    } else if(error == kRadioErrorAudioQueueEnqueue) {

        NSLog(@"kRadioErrorAudioQueueEnqueue");

    } else if(error == kRadioErrorAudioQueueStart) {

        NSLog(@"kRadioErrorAudioQueueStart");

    } else if(error == kRadioErrorFileStreamGetProperty) {

        NSLog(@"kRadioErrorFileStreamGetProperty");

    } else if(error == kRadioErrorFileStreamOpen) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Station Currently Offline" message:@"The selected station is currently offline. Please check back later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];

        [alert show];

    } else if(error == kRadioErrorPlaylistParsing) {

        NSLog(@"kRadioErrorPlaylistParsing");

    } else if(error == kRadioErrorDecoding) {

        NSLog(@"kRadioErrorDecoding");

    } else if(error == kRadioErrorHostNotReachable) {

        NSLog(@"kRadioErrorHostNotReachable");

    } else if(error == kRadioErrorNetworkError) {

        NSLog(@"kRadioErrorNetworkError");
    }
}

//Radio Name Tips

//Exemple if you want to change the name of one stream or more
//
//Tips : Make sure that the name is exactly the same from the name displayed in the Player

- (void)radioMetadataReady:(Radio *)radio
{
    scrollStream.text = @"";
    //scrollStream.text = [NSString stringWithFormat:@"%@", [radio radioName]];
}

- (void)radioTitleChanged:(Radio *)radio
{
    NSString *streamArtist;
    NSString *streamTitle;
    NSString *streamAlbum;

    NSArray *streamParts = [[radio radioTitle] componentsSeparatedByString:@" - "];
    if ([streamParts count] > 0)
    {
        streamArtist = [streamParts objectAtIndex:0];
    }
    else
    {
        streamArtist = @"";
    }

    if ([streamParts count] >= 2)
    {
        streamTitle = [streamParts objectAtIndex:1];
        if ([streamParts count] >= 3)
        {
            streamAlbum = [streamParts objectAtIndex:2];
        }
        else
        {
            streamAlbum = @"";
        }
    }
    else
    {
        streamArtist = Station_Title;
        streamTitle = Station_Subtitle;
        streamAlbum = @"";
    }
    if ([streamArtist isEqualToString:@"Targetspot"])
    {
        //Songs or Artist Name Tips

        //Exemple if you want to change the name of one artist or song
        //
        //Tips : Make sure that the name is exactly the same from the name displayed in the Player

        streamArtist = Station_Title;
        streamTitle = Station_Subtitle;

        [self defaultalbumart];
    }

    if ([self.metadataAlbum isEqual:@""])
    {
        metadataAll.text = self.metadataTitle;
    }

    self.metadataArtist = [NSString stringWithFormat:@"%@", streamArtist];
    self.metadataTitle = [NSString stringWithFormat:@"%@", streamTitle];
    self.metadataAlbum = [NSString stringWithFormat:@"%@", streamAlbum];

    scrollStream.text = self.metadataArtist;
    metadataAll.text = self.metadataTitle;

    if (streamAlbum.length == 0)
    {
        if([self.metadataArtist isEqual:Station_Title])
        {
            [self defaultalbumart];
        }
        else
        {
            [self updateAlbumCollectionName];
        }
    }
    else
    {
        [self updateAlbumCollectionName];
    }
}

#pragma mark ---

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if(self.connection){

        self.connection = nil;
        self.responseData = nil;

    }
}

- (void)dealloc
{
    [selectedStream release];
    [bufferingLabel release];
    [streamName release];
    [PlayerViewController release];
    [albumArt release];
    [albumArtBlur release];
    [twitter release];
    [facebook release];
    [button release];
    [bufferingLabel release];
    [selectedStream release];
    [scrollStream release];
    [metadataAll release];
    [removeAdsButton release];
    [restore release];
    [share release];
    [super dealloc];
}

- (void)beginInterruption
{
    if(_radio == nil) {
        return;
    }

    [_radio pause];
}

- (void)endInterruption
{
    if(_radio == nil) {
        return;
    }

    if([_radio isPaused]) {
        [_radio play];
    }
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeRemoteControlPlay) {
        if(_radio)
        {
            if([_radio isPaused]) {
                [_radio play];
            }
        }
    }
    if (event.subtype == UIEventSubtypeRemoteControlPause) {
        if(_radio)
        {
            if([_radio isPlaying]) {
                [_radio pause];
            }
        }
    }
}

- (UIViewController *)viewControllerForPresentingModalView
{
    // return the view controller that is currently presenting the ad unit.
    return self;
}

- (void)Play_pressed:(NSNotification *)notification
{
    if(USE_PLAYER_V2)
    {
        if(USE_m3u8){

            if([_radio isPlaying]) {

                NSLog(@"Shutdown -- Player V2");

                [_radio shutdown];
                [_radio release];
                _radio = nil;
            }

        }else{
            NSLog(@"Play -- Player V2");

            NSURL *url = [NSURL URLWithString:downloadSourceField.text];
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];

            if((radioPlayer.rate != 0) && (radioPlayer.error == nil)){

            }else{
                radioPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
                [radioPlayer play];
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:@"isPlaying" object:nil];

            [self setButtonImage:[UIImage imageNamed:@"pausebtn.png"]];

            [UILabel beginAnimations:nil context:NULL];
            [UILabel setAnimationDuration:0.5];
            [bufferingLabel setAlpha:0.2];
            [UILabel commitAnimations];

            NSUserDefaults *playerStatus = [NSUserDefaults standardUserDefaults];

            [playerStatus setObject:@"Playing" forKey:@"Player"];
        }
    }
}

- (void)Stop_pressed:(NSNotification *)notification
{
    if(USE_PLAYER_V2)
    {
        if(USE_m3u8){

            if([_radio isPlaying]) {
                [_radio shutdown];
            }

            USE_PLAYER_V2 = NO;
            USE_m3u8 = NO;
            M3u8_Play = NO;

        }else{
            [radioPlayer replaceCurrentItemWithPlayerItem:(nil)];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"isNotPlaying" object:nil];

            [self setButtonImage:[UIImage imageNamed:@"playbtn.png"]];

            [UILabel beginAnimations:nil context:NULL];
            [UILabel setAnimationDuration:0.5];
            [bufferingLabel setAlpha:0.2];
            [UILabel commitAnimations];

            NSUserDefaults *playerStatus = [NSUserDefaults standardUserDefaults];

            [playerStatus setObject:@"Stopped" forKey:@"Player"];
        }
    }
}

- (void)Pause_pressed:(NSNotification *)notification
{
    if(USE_PLAYER_V2)
    {
        if(USE_m3u8){

            if([_radio isPlaying]) {
                [_radio shutdown];
            }

            USE_PLAYER_V2 = NO;
            USE_m3u8 = NO;
            M3u8_Play = NO;

        }
        else{
            [radioPlayer replaceCurrentItemWithPlayerItem:(nil)];

            NSURL *url = [NSURL URLWithString:downloadSourceField.text];
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];

            if((radioPlayer.rate != 0) && (radioPlayer.error == nil)){

            }else{
                radioPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
                [radioPlayer play];
            }
        }
    }
}

#pragma mark Update Album Name Collection

- (void)updateAlbumCollectionName
{
    ABITunesWrapper *wrapper = [ABITunesWrapper new];
    ABITunesWrapperInfo *wrapperInfo = [ABITunesWrapperInfo new];
    wrapperInfo.trackName = [self.metadataTitle copy];
    wrapperInfo.artistName = [self.metadataArtist copy];

    __weak __typeof(self) weakSelf = self;
    [wrapper requestAlbumInfoFrom:wrapperInfo completion:^(ABITunesResultInfo *resultInfo, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                NSLog(@"Error occured during downloading album name: %@", error.localizedDescription);
                return;
            }


            NSString *albumName = resultInfo.collectionName;
            NSLog(@"COLLECTION NAME(albumName): %@", albumName);
            if(albumName && !([Station_Title isEqualToString:@"NRJ"] || [Station_Title isEqualToString:@"Rire et Chansons"] || [Station_Title isEqualToString:@"CherieFM"] || [Station_Title isEqualToString:@"RMC"] || [Station_Title isEqualToString:@"FranceINFO"] || [Station_Title isEqualToString:@"FranceINTER"] || [Station_Title isEqualToString:@"Mouv'"] || [Station_Title isEqualToString:@"Nostalgie"] || [Station_Title isEqualToString:@"Fip"] || [Station_Title isEqualToString:@"Radio Nova"] || [Station_Title isEqualToString:@"Antenna 1"]))
            {
                metadataAlbum = [albumName copy];
                scrollStream.text = self.metadataArtist;
                metadataAll.text = self.metadataTitle;
                [self updateAlbumArt];
            }
            else
            {
                if([Station_Title isEqualToString:@"NRJ"] || [Station_Title isEqualToString:@"Rire et Chansons"] || [Station_Title isEqualToString:@"CherieFM"] || [Station_Title isEqualToString:@"RMC"] || [Station_Title isEqualToString:@"FranceINFO"] || [Station_Title isEqualToString:@"FranceINTER"] || [Station_Title isEqualToString:@"Mouv'"] || [Station_Title isEqualToString:@"Nostalgie"] || [Station_Title isEqualToString:@"Fip"] || [Station_Title isEqualToString:@"Radio Nova"] || [Station_Title isEqualToString:@"Antenna 1"])
                {
                    //[self updateAlbumArtImageWithDEFAULT];
                    scrollStream.text = Station_Title;
                    metadataAll.text = Station_Subtitle;
                }
                else
                {
                    [self updateAlbumArt];
                }
            }
            NSURL *artworkURL = resultInfo.artworkURL;
            if (artworkURL)
            {
                NSLog(@"COLLECTION NAME(artworkURL): %@", artworkURL);
                if(!Use_Last_Fm)
                {
                    NSLog(@"Artwork found - Default Album");
                    [self updateAlbumArtImageWithDEFAULT];
                }
                else
                {
                    NSLog(@"Artwork found - Setting the album");
                    [self updateAlbumArtImageWithURL:artworkURL];
                }
            }
            else
            {
                NSLog(@"COLLECTION NAME(artworkURL): DefaultAlbum");
                [self updateAlbumArtImageWithDEFAULT];
            }

            musicNSURL = resultInfo.musicURL;
            NSLog(@"COLLECTION NAME(musicURL): %@", musicNSURL);

            NSString *music_string = musicNSURL.absoluteString;

            if (Open_Music && ![music_string isEqualToString:@""])
            {
                if(![Station_Title isEqualToString:scrollStream.text])
                {
                    [self setMusicImage:[UIImage imageNamed:@"US-UK_Apple_Music_Lockup_RGB_wht.png"]]; // Apple Music
                }
                else
                {
                    [self setMusicImage:[UIImage imageNamed:@"open_website.png"]]; //Apple Music not enabled
                }
            }
            else
            {
                [self setMusicImage:[UIImage imageNamed:@"open_website.png"]]; //Apple Music not enabled
            }
        });
    }];

}

#pragma mark Update Album Art

- (void)updateAlbumArt
{
    if([Station_Title isEqualToString:@"NRJ"] || [Station_Title isEqualToString:@"Rire et Chansons"] || [Station_Title isEqualToString:@"CherieFM"] || [Station_Title isEqualToString:@"RMC"] || [Station_Title isEqualToString:@"FranceINFO"] || [Station_Title isEqualToString:@"FranceINTER"] || [Station_Title isEqualToString:@"Mouv'"] || [Station_Title isEqualToString:@"Nostalgie"] || [Station_Title isEqualToString:@"Fip"] || [Station_Title isEqualToString:@"Radio Nova"] || [Station_Title isEqualToString:@"Antenna 1"])
    {
        scrollStream.text = Station_Title;
        metadataAll.text = Station_Subtitle;
        [self updateAlbumArtImageWithDEFAULT];
    }
    else
    {
    NSLog(@"Update Album Art");

    NSString *artistSearch = [self.metadataArtist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString *titleSearch = [self.metadataTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&limit=1", artistSearch];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            NSError* parseError;
            id parse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
            NSLog(@"%@", parse);
        }
    }];

    // comment this code out if using the below method
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=%@&api_key=%@&format=json", artistSearch, LAST_FM_API_KEY]]];

    // uncomment to get album that goes with current track
    NSString *albumSearch = [self.metadataTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    self.connection = [[NSURLConnection alloc]
                       initWithRequest:theRequest
                       delegate:self startImmediately:NO];

    [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                               forMode:NSDefaultRunLoopMode];

    if(self.connection){

        self.responseData = [[NSMutableData alloc] init];

        [self.connection start];

    }
    }
}

- (void)updateAlbumArtImageWithURL:(NSURL *)albumArtURL {
    self.albumArt.contentMode = UIViewContentModeScaleAspectFill;
    self.albumArt.asynchronous = YES;

    if(Activate_Reflection_Effect)
    {
        self.albumArt.reflectionScale = 0.2f;
        self.albumArt.reflectionAlpha = 0.25f;
    }
    else
    {
        self.albumArt.reflectionScale = 0.0f;
        self.albumArt.reflectionAlpha = 0.0f;
    }
    self.albumArt.reflectionGap = 0.0f;

    [self.albumArt setImageWithURL:albumArtURL
                  placeholderImage:nil
                           options:0
                           success:^(UIImage *image){
        NSLog(@"Setting Album Art with %@ %@", albumArtURL, image);

        if(musicNSURL)
        {
            self.albumArt.image = image;
            if(![Station_Title isEqualToString:scrollStream.text])
            {
                [self setMusicImage:[UIImage imageNamed:@"US-UK_Apple_Music_Lockup_RGB_wht.png"]]; // Apple Music
            }
            else
            {
                [self setMusicImage:[UIImage imageNamed:@"open_website.png"]]; //Apple Music not enabled
            }
        }
        else
        {
            NSString *filePath = [NSString stringWithFormat:@"%@", selectedStreamImage];
            if(filePath)
            {
                self.albumArt.image = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
            }
            else
            {
                self.albumArt.image = [UIImage imageNamed:@"defaultalbum.png"];
            }

            [self setMusicImage:[UIImage imageNamed:@"open_website.png"]]; //Apple Music not enabled
        }

        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        if (appDelegate.uiIsVisible)
        {
            [self.albumArtBlur setImageToBlur:image
                                   blurRadius:kLBBlurredImageDefaultBlurRadius
                              completionBlock:^(NSError *error){

                NSLog(@"Did Finish Updating Album Art and Album Art Blur");

                if(Activate_Blur_Effect)
                {
                    [UIImageView beginAnimations:nil context:NULL];
                    [self.albumArtBlur setAlpha:0.4];
                }
                else
                {
                    self.albumArtBlur.image = nil;
                }

                [UIImageView beginAnimations:nil context:NULL];
                [self.albumArt setAlpha:1];
            }];
        }

        Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");

        if (playingInfoCenter)
        {
            NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];

            MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:self.albumArt.image];

            NSLog(@"updateAlbumArtImageWithURL %@ - %@ -%@ - %@", self.metadataArtist, self.metadataTitle, self.metadataAlbum, artwork);

            [songInfo setObject:SAFE_STRING(self.metadataArtist) forKey:MPMediaItemPropertyArtist];
            [songInfo setObject:SAFE_STRING(self.metadataTitle) forKey:MPMediaItemPropertyTitle];
            [songInfo setObject:SAFE_STRING(self.metadataAlbum) forKey:MPMediaItemPropertyAlbumTitle];
            [songInfo setObject:@(1) forKey:MPNowPlayingInfoPropertyPlaybackRate];
            [songInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        }
    }
                           failure:^(NSError *error){

        NSLog(@"Setting Album Art with default album");

        [self defaultalbumart];

        [self setMusicImage:[UIImage imageNamed:@"open_website.png"]]; //Apple Music not enabled

        self.metadataArtist = Station_Title;
        self.metadataTitle = Station_Subtitle;

        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        if (appDelegate.uiIsVisible)
        {
            [self.albumArtBlur setImageToBlur:self.albumArt.image
                                   blurRadius:kLBBlurredImageDefaultBlurRadius
                              completionBlock:^(NSError *error){

                if(Activate_Blur_Effect)
                {
                    [UIImageView beginAnimations:nil context:NULL];
                    [self.albumArtBlur setAlpha:0.4];
                }
                else
                {
                    self.albumArtBlur.image = nil;
                }

                [UIImageView beginAnimations:nil context:NULL];
                [self.albumArt setAlpha:1];
            }];
        }

        Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");

        if (playingInfoCenter)
        {
            NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
            MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:self.albumArt.image];
            NSLog(@"updateAlbumArtImageWithURL %@ - %@ -%@ - %@", self.metadataArtist, self.metadataTitle, self.metadataAlbum, artwork);
            [songInfo setObject:SAFE_STRING(self.metadataArtist) forKey:MPMediaItemPropertyArtist];
            [songInfo setObject:SAFE_STRING(self.metadataTitle) forKey:MPMediaItemPropertyTitle];
            [songInfo setObject:SAFE_STRING(self.metadataAlbum) forKey:MPMediaItemPropertyAlbumTitle];
            [songInfo setObject:@(1) forKey:MPNowPlayingInfoPropertyPlaybackRate];
            [songInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        }
    }];

    self.connection = nil;
    self.responseData = nil;
}

- (void)updateAlbumArtImageWithDEFAULT
{
    self.albumArt.contentMode = UIViewContentModeScaleAspectFill;
    self.albumArt.asynchronous = YES;

    if(Activate_Reflection_Effect)
    {
        self.albumArt.reflectionScale = 0.2f;
        self.albumArt.reflectionAlpha = 0.25f;
    }
    else
    {
        self.albumArt.reflectionScale = 0.0f;
        self.albumArt.reflectionAlpha = 0.0f;
    }
    self.albumArt.reflectionGap = 0.0f;

    if([selectedStreamImage isEqualToString:@""])
    {
        self.albumArt.image = [UIImage imageNamed:@"defaultalbum.png"];
    }
    else
    {
        NSString *filePath = [NSString stringWithFormat:@"%@", selectedStreamImage];
        if(filePath)
        {
            self.albumArt.image = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
        }
        else
        {
            self.albumArt.image = [UIImage imageNamed:@"defaultalbum.png"];
        }
    }

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if (appDelegate.uiIsVisible)
    {

        [self.albumArtBlur setImageToBlur:self.albumArt.image
                               blurRadius:kLBBlurredImageDefaultBlurRadius
                          completionBlock:^(NSError *error){

            NSLog(@"Did Finish Updating Album Art and Album Art Blur");

            if(Activate_Blur_Effect)
            {
                [UIImageView beginAnimations:nil context:NULL];
                [self.albumArtBlur setAlpha:0.4];
            }
            else
            {
                self.albumArtBlur.image = nil;
            }

            [UIImageView beginAnimations:nil context:NULL];
            [self.albumArt setAlpha:1];
        }];
    }

    [self setMusicImage:[UIImage imageNamed:@"open_website.png"]]; //Apple Music not enabled

    self.metadataArtist = Station_Title;
    self.metadataTitle = Station_Subtitle;

    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");

    if (playingInfoCenter)
    {
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];

        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:self.albumArt.image];

        NSLog(@"updateAlbumArtImageWithDEFAULT %@ - %@ -%@ - %@", self.metadataArtist, self.metadataTitle, self.metadataAlbum, artwork);

        [songInfo setObject:SAFE_STRING(self.metadataArtist) forKey:MPMediaItemPropertyArtist];
        [songInfo setObject:SAFE_STRING(self.metadataTitle) forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:SAFE_STRING(self.metadataAlbum) forKey:MPMediaItemPropertyAlbumTitle];
        [songInfo setObject:@(1) forKey:MPNowPlayingInfoPropertyPlaybackRate];
        [songInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
}

#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.connection = nil;
    self.responseData = nil;

    NSString *msg = [NSString stringWithFormat:@"Failed: %@", [error description]];
    NSLog (@"%@",msg);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    if(self.responseData == nil)
    {
        // NSLog(@"responseData reported nil!");
    }
    else
    {
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves  error:&error];

        // NSLog(@"%@", res);

        self.albumArt.image = nil;
        self.albumArtBlur.image = nil;

        // comment this code out if using the below method
        NSArray *artistInfo = [res objectForKey:@"artist"];

        // uncomment to get album that goes with current track
        //NSArray *albumInfo = [res objectForKey:@"album"];

        NSArray *albumArtURL = [artistInfo valueForKey:@"image"];
        NSArray *mega = [albumArtURL objectAtIndex:4];

        NSURL *albumArtUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [mega valueForKey:@"#text"]]];

        // Main Album Art

        if(!Use_Last_Fm)
        {
            NSLog(@"Not Using Last FM - Default Album");
            [self updateAlbumArtImageWithDEFAULT];
        }
        else
        {
            NSLog(@"Using Last FM - Looking for Album");
            [self updateAlbumArtImageWithURL:albumArtUrl];
        }
    }
}

@end

