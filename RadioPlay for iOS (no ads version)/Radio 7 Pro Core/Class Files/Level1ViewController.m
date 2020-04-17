//
//  Level1ViewController.m
//  Radio Play by Radiomyme
//

#import "Level1ViewController.h"
#import "UIImageView+WebCache.h"
#import "CustomTableCell.h"
#import "AppDelegate.h"
#import "Settings.h"
#import "PlayerViewController.h"

@import AVFoundation;
@import AVKit;

#define degreesToRadian(x) (M_PI * (x) / 180.0)

static const CGFloat kWallpaperImageSideMargin = 55.0f;

@implementation Level1ViewController

@synthesize listContent, filteredListContent, myImageView, myTableView, myImageWallpaper;

- (void)dealloc
{
    [listContent release];
    [filteredListContent release];
	[myTableView release];
	[super dealloc];
}

#pragma mark UIViewController delegates

- (void)viewDidLoad
{    
	[super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@""
                                             style:UIBarButtonItemStyleBordered
                                             target:nil
                                             action:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
										     selector:@selector(pushFacebookView:)
										         name:@"PushFacebookView"
									           object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
										     selector:@selector(pushTwitterView:)
										         name:@"PushTwitterView"
									           object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushChatView:)
                                                 name:@"PushChatView"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushInApp:)
                                                 name:@"PushInApp"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushRestore:)
                                                 name:@"PushRestore"
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
										     selector:@selector(updateView:) 
										         name:@"UpdateLevel1" 
									           object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(isPlayingBtn:)
                                                 name:@"isPlaying" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeNowPlayingBtn:)
                                                 name:@"isNotPlaying" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(QuickAction:)
                                                 name:@"QuickAction" object:nil];
    
    //[myTableView setRowHeight: CGRectGetWidth(self.view.frame)];
    
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] &&
        (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable))
    {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
    
    //self.extendedLayoutIncludesOpaqueBars = YES;
    
    [self setupSearchBar];
}


- (void)viewWillAppear:(BOOL)animated
{ 
	[super viewWillAppear:animated];
    
    if (self.isSearchActive)
    {
        return;
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.view.tintColor = [UIColor whiteColor];
    
    [self.tabBarController.tabBar setBackgroundImage:[UIImage new]];
    self.tabBarController.tabBar.shadowImage = [UIImage new];
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
    
    self.tabBarController.tabBar.translucent = YES;
    self.navigationController.navigationBar.translucent = NO;

    _isLocalEnabled = LOCAL_ENABLED;
    
    if (_isLocalEnabled)
    {
        [self loadLocalStationsViewWillAppear];
    }
    else
    {
        [self loadRemoteStationsViewWillAppear];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
    }
}

- (void)updateView:(NSNotification *)notification
{
    _isLocalEnabled = LOCAL_ENABLED;
    
    if (_isLocalEnabled)
    {
        [self loadLocalStationsUpdateView];
    }
    else
    {
        [self loadRemoteStationsUpdateView];
    }
}

- (void)loadLocalStationsViewWillAppear
{
    // Single Station Tips
    // If the app is using only one station then the player will start automatically
    
    if ([[self tableContent] count ] <= 1 && !self.isSearchActive)
    {
        self.navigationController.navigationBarHidden = YES;
        
        self.tabBarController.tabBar.hidden = YES;
        
        myTableView.alpha = 0;
        myImageView.alpha = 0;
        myImageWallpaper.alpha = 0;
        
        [self performSelector:@selector(selectFirstRow) withObject:nil afterDelay:0.1];
    }
    else
    {
        [myTableView reloadData];
    }
}

- (void)loadLocalStationsUpdateView
{
    if ([[self tableContent] count ] <= 1)
    {
        NSLog(@"Single Station Local Mode");

    }
    else
    {
        NSLog(@"Multi Station Local Mode");
        
        self.navigationController.navigationBarHidden = NO;
        
        self.tabBarController.tabBar.hidden = NO;
        
        self.navigationItem.title = Home_Title;
        
        [self.navigationController.navigationItem.rightBarButtonItem setAction:@selector(showWithLabel)];
        [self.navigationController.navigationItem.rightBarButtonItem setTarget:self];
        
        myTableView.userInteractionEnabled = YES;
        myImageView.alpha = 1;
        myImageWallpaper.alpha = 1;
        myTableView.alpha = 1;
        
        [myTableView reloadData];
    }
}

- (void)loadRemoteStationsViewWillAppear
{
    [myTableView reloadData];
}

- (void)loadRemoteStationsUpdateView
{
        self.navigationController.navigationBarHidden = NO;
        
        self.tabBarController.tabBar.hidden = NO;
        
        self.navigationItem.title = Home_Title;
        
        myTableView.userInteractionEnabled = YES;
        myImageView.alpha = 1;
        myImageWallpaper.alpha = 1;
        myTableView.alpha = 1;
        
        [myTableView reloadData];
}

- (void)selectFirstRow
{
    if ([self.myTableView numberOfSections] > 0 && [self.myTableView numberOfRowsInSection:0] > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.myTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.myTableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
										     selector:@selector(handleEnterForeground:)
										         name:UIApplicationWillEnterForegroundNotification
									           object:nil];

	UIApplication *application = [UIApplication sharedApplication];
	
	if([application respondsToSelector:@selector(beginReceivingRemoteControlEvents)])
		[application beginReceivingRemoteControlEvents];
    
    ViewDidAppear = YES;
	
	[self becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)isPlayingBtn:(NSNotification *)notification
{
    UIButton *nowPlayingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nowPlayingBtn setImage:[UIImage imageNamed:@"chevron.png"] forState:UIControlStateNormal];
    [nowPlayingBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 40.0f, 0.0f, 0.0f)];
    [nowPlayingBtn setTitle:@"Now\nPlaying" forState:UIControlStateNormal];
    [nowPlayingBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, -40.0f, 0.0f, 0.0f)];
    nowPlayingBtn.font = [UIFont systemFontOfSize:11];
    nowPlayingBtn.titleLabel.numberOfLines = 0;
    nowPlayingBtn.titleLabel.textAlignment = UITextAlignmentRight;
    
    [nowPlayingBtn addTarget:self action:@selector(pushToNowPlayingView) forControlEvents:UIControlEventTouchUpInside];
    
    [nowPlayingBtn sizeToFit];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:nowPlayingBtn];
}

- (void)removeNowPlayingBtn:(NSNotification *)notification
{
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)pushToNowPlayingView
{
    if (_didEnterForeground == YES)
    {
        _didEnterForeground = NO;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPlayer" object:nil];
    
    [self setHidesBottomBarWhenPushed: YES];
    
    [self.navigationController pushViewController:streamViewController animated:YES];
    
    [self setHidesBottomBarWhenPushed: NO];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeRemoteControlPlay) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pausePlayer" object:nil];
    }
    if (event.subtype == UIEventSubtypeRemoteControlPause) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pausePlayer" object:nil];
    }
}

- (void)handleEnterForeground:(UIApplication *)notification
{
    _didEnterForeground = YES;
}

- (void)pushFacebookView:(NSNotification *)notification
{
    NSString *GetID = [NSString stringWithFormat:@"fb://profile/%@", Facebook_URL];
    NSURL *facebookURL = [NSURL URLWithString:GetID];
    
    if ([[UIApplication sharedApplication] canOpenURL:facebookURL])
    {
        [[UIApplication sharedApplication] openURL:facebookURL];
    }
    else
    {
        NSString *DefaultURL = [NSString stringWithFormat:@"https://facebook.com/%@", Facebook_URL];
        SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:DefaultURL] entersReaderIfAvailable:NO];
        safariVC.delegate = self;
        [self presentViewController:safariVC animated:NO completion:nil];
    }
}

- (void)pushTwitterView:(NSNotification *)notification
{
    if(Use_Twitter)
    {
        NSString *GetID = [NSString stringWithFormat:@"twitter://user?screen_name=%@", Account_ID];
        NSURL *twitterURL = [NSURL URLWithString:GetID];
        
        if ([[UIApplication sharedApplication] canOpenURL:twitterURL])
        {
            [[UIApplication sharedApplication] openURL:twitterURL];
        }
        else
        {
            NSString *DefaultURL = [NSString stringWithFormat:@"https://twitter.com/%@", Account_ID];
            SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:DefaultURL] entersReaderIfAvailable:NO];
            safariVC.delegate = self;
            [self presentViewController:safariVC animated:NO completion:nil];
        }
    }
    else
    {
        NSString *GetID = [NSString stringWithFormat:@"instagram://user?username=%@", Account_ID];
        NSURL *instagramURL = [NSURL URLWithString:GetID];
        
        if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
        {
            [[UIApplication sharedApplication] openURL:instagramURL];
        }
        else
        {
            NSString *DefaultURL = [NSString stringWithFormat:@"https://instagram.com/%@", Account_ID];
            SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:DefaultURL] entersReaderIfAvailable:NO];
            safariVC.delegate = self;
            [self presentViewController:safariVC animated:NO completion:nil];
        }
    }
}

- (void)pushInstagramView:(NSNotification *)notification
{
    NSString *GetID = [NSString stringWithFormat:@"instagram://user?username=%@", Account_ID];
    NSURL *instagramURL = [NSURL URLWithString:GetID];
    
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
    else
    {
        NSString *DefaultURL = [NSString stringWithFormat:@"https://instagram.com/%@", Account_ID];
        SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:DefaultURL] entersReaderIfAvailable:NO];
        safariVC.delegate = self;
        [self presentViewController:safariVC animated:NO completion:nil];
    }
    
}

- (void)pushInApp:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InAppPressed" object:nil];
}

- (void)pushRestore:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RestorePressed" object:nil];
}

// If you want to add a Custom Pushed View
//
// Tips : you can change the name of the URL or the URL in the Settings.m & Settings.h (definition)

- (void)pushChatView:(NSNotification *)notification
{
    SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:open_music_URL] entersReaderIfAvailable:NO];
    
    //SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"your url here"] entersReaderIfAvailable:NO];
    
    safariVC.delegate = self;
    [self presentViewController:safariVC animated:YES completion:nil];
    
}

#pragma mark UITableView delegates


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self tableContent] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* item = [[self tableContent] objectAtIndex:indexPath.row];
    NSString *selectedStream;
    NSString *selectedStreamTitle;
    NSString *m3u8;
    
    selectedStreamTitle = [item objectForKey:kItemTitleKey];
    selectedStream = [item objectForKey:kItemTitle2Key];
    m3u8 = [item objectForKey:km3u8];
    
    Station_Title = [item objectForKey:kItemTitleKey];
    Station_Subtitle = [item objectForKey:ksubtitle];
    
    if([m3u8 isEqualToString:@""]){
        USE_m3u8 = NO;
        USE_PLAYER_V2 = NO;
    }else{
        USE_m3u8 = YES;
        USE_PLAYER_V2 = YES;
        selectedStream = [item objectForKey:km3u8];
        NSLog(@"m3u8");
    }
    
    if(USE_m3u8){
        
        NSLog(@"Start m3u8 stream");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopPlayer" object:nil];
        
        NSLog(@"Play m3u8 -- Player V2");
        
        CGSize result = [[UIScreen mainScreen] bounds].size;
        
        NSURL *url = [NSURL URLWithString:selectedStream];
        AVPlayer *player = [AVPlayer playerWithURL:url];
        
        AVPlayerViewController *playercontroller = [[AVPlayerViewController alloc] init];
        
        // Play video in Landscape
        
        playercontroller.view.transform = CGAffineTransformIdentity;
        playercontroller.view.transform = CGAffineTransformMakeRotation(degreesToRadian(90));
        
        // Present the Player
        
        [self presentViewController:playercontroller animated:YES completion:nil];
        playercontroller.player = player;
        [player play];
        
    }else{
        
        if(streamViewController.selectedStreamTitle == selectedStreamTitle && USE_m3u8)
        {
            [self pushToNowPlayingView];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopPlayer" object:nil];
            
            Facebook_URL = [item objectForKey:kFacebook];
            Account_ID = [item objectForKey:kTwitter];
            
            streamViewController = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
            
            streamViewController.selectedStream = selectedStream;
            
            streamViewController.selectedStreamTitle = selectedStreamTitle;
            
            NSString *urlAsString2 = [item objectForKey:kImageFilePath2Key];
            
            streamViewController.selectedStreamImage = urlAsString2;
        
            [self setHidesBottomBarWhenPushed: YES];
            
            if(_isLocalEnabled)
            {
                [self.navigationController pushViewController:streamViewController animated:YES];
            }
            else
            {
                [self.navigationController pushViewController:streamViewController animated:YES];
            }
            
            [self setHidesBottomBarWhenPushed: NO];
        }
    }
    
    [self dissmissSearch];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"customCell";
    
    CustomTableCell *cell = (CustomTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        NSArray * topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomTableCell" owner:self options:nil];
        
        for(id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (CustomTableCell *)currentObject;
                break;
            }
        }
    }
	
    cell.backgroundColor = [UIColor clearColor];
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:0.0 / 255 green:0.0 / 255 blue:0.0 / 255 alpha:0.6]];
    [cell setSelectedBackgroundView:bgColorView];
    
    if([[self tableContent] count ] > indexPath.row)
    {
        // get the view controller's info dictionary based on the indexPath's row
        NSDictionary* item = [[self tableContent] objectAtIndex:indexPath.row];
        
        cell.myTitleView.textColor = [UIColor colorWithRed:255.0 / 255 green:255.0 / 255 blue:255.0 / 255 alpha:1.0];
        cell.myTitleView.text = [item objectForKey:kItemTitleKey];
        
        cell.mySubtitleView.textColor = [UIColor colorWithRed:255.0 / 255 green:255.0 / 255 blue:255.0 / 255 alpha:1.0];
        cell.mySubtitleView.text = [item objectForKey:ksubtitle];
        
        NSString *urlAsString = [item objectForKey:kImageFilePathKey];
        NSURL *wallpaperURL = [NSURL URLWithString:urlAsString];
        NSString *urlAsString2 = [item objectForKey:kImageFilePath2Key];
        NSURL *iconImageURL = [NSURL URLWithString:urlAsString2];
        
        [cell.radioWallpaperImageView setOptimizedImageWithURL:wallpaperURL];
        [cell.radioIconImageView setOptimizedImageWithURL:iconImageURL];
    }
    
    if(UIUserInterfaceIdiomPad)
    {
        //myTableView.rowHeight = 200;
    }

	return cell;
}

- (void)QuickAction:(NSNotification *)notification
{
    if([QUICK_ACTION_ENABLED isEqualToString:@""])
    {
        NSLog(@"Quick Action Player is not enabled");
    }
    else
    {
        if(ViewDidAppear){
            [self forceStation];
            NSLog(@"QuickAction Level 1 Controller - Force Station");
        }else{
            
        }
    }
}

- (void)forceStation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopPlayer" object:nil];
    
    streamViewController = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
    
    if([QUICK_ACTION_ENABLED isEqualToString:@"station1"])
    {
        NSLog(@"Play Station 1");
        
        Station_Title = Station_Name1;
        Station_Subtitle = Station_Sub1;
        streamViewController.selectedStream = Station_Stream1;
        streamViewController.selectedStreamTitle = Station_Name1;
        streamViewController.selectedStreamImage = Station_Logo1;
        Facebook_URL = Station_Facebook1;
        Account_ID = Station_Twitter1;
    }
    if([QUICK_ACTION_ENABLED isEqualToString:@"station2"])
    {
        Station_Title = Station_Name2;
        Station_Subtitle = Station_Sub2;
        streamViewController.selectedStream = Station_Stream2;
        streamViewController.selectedStreamTitle = Station_Name2;
        streamViewController.selectedStreamImage = Station_Logo2;
        Facebook_URL = Station_Facebook2;
        Account_ID = Station_Twitter2;
    }
    if([QUICK_ACTION_ENABLED isEqualToString:@"station3"])
    {
        Station_Title = Station_Name3;
        Station_Subtitle = Station_Sub3;
        streamViewController.selectedStream = Station_Stream3;
        streamViewController.selectedStreamTitle = Station_Name3;
        streamViewController.selectedStreamImage = Station_Logo3;
        Facebook_URL = Station_Facebook3;
        Account_ID = Station_Twitter3;
    }
    if([QUICK_ACTION_ENABLED isEqualToString:@"station4"])
    {
        Station_Title = Station_Name4;
        Station_Subtitle = Station_Sub4;
        streamViewController.selectedStream = Station_Stream4;
        streamViewController.selectedStreamTitle = Station_Name4;
        streamViewController.selectedStreamImage = Station_Logo4;
        Facebook_URL = Station_Facebook4;
        Account_ID = Station_Twitter4;
    }
    
    [self setHidesBottomBarWhenPushed: YES];
    
    [self.navigationController pushViewController:streamViewController animated:YES];
    
    [self setHidesBottomBarWhenPushed: NO];
     
    QUICK_ACTION_ENABLED = @"";
}

#pragma mark Customer Getters

- (NSArray *)tableContent
{
    return self.isSearchActive ? self.filteredListContent : self.listContent;
}

- (BOOL)isSearchActive
{
    return self.searchController.isActive;
}

#pragma mark Search delegate

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self filterResultsWithQueue:nil];
    [self dissmissSearch];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    // Help123 : Categories Switch. If you want to add more than 4 categories, please contact us at contact@radiomyme.com
    
    switch (selectedScope) {
        case 0:
            // Category all
            NSLog(@"All");
            Category = @"";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Categories" object:nil];
            break;
            
        case 1:
            // Category 1
            NSLog(@"1");
            Category = @"1";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Categories" object:nil];
            break;
            
        case 2:
            // Category 2
            NSLog(@"2");
            Category = @"2";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Categories" object:nil];
            break;
            
        case 3:
            // Category 3
            NSLog(@"3");
            Category = @"3";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Categories" object:nil];
            break;
            
        default:
            Category = @"";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Categories" object:nil];
            break;
    }
}

//-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    [self filterResultsWithQueue:searchText];
//}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self filterResultsWithQueue:searchController.searchBar.text];
}

// Wrapper-methods

- (void)setupSearchBar
{
    if(!Allow_Search)
    {
        return;
    }
    
    self.searchController=[[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater=self;
    self.searchController.dimsBackgroundDuringPresentation= YES;
    self.searchController.searchBar.delegate=self;
    self.searchController.searchBar.translucent = YES;
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.searchController.searchBar.barStyle = UIBarStyleBlackTranslucent;
    self.searchController.searchBar.barTintColor = [UIColor blackColor];
    self.myTableView.tableHeaderView=self.searchController.searchBar;
    self.definesPresentationContext=YES;
    [self.searchController.searchBar sizeToFit];
    
    
    // Help123 : Categories Names
    
    _isLocalEnabled = LOCAL_ENABLED;
    if(_isLocalEnabled && Enable_Categories)
    {
        self.searchController.searchBar.scopeButtonTitles = @[@"France", @"Electro", @"Techno", @"TV"];
        [self.searchController.searchBar setScopeBarButtonTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        [self.searchController.searchBar setScopeBarButtonTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    }
    
    //[self.myTableView setContentOffset:CGPointMake(0,55)];
}

- (void)dissmissSearch
{
    [self.searchController dismissViewControllerAnimated:YES completion:nil];
}

- (void)filterResultsWithQueue:(NSString *)queue
{
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf)
        {
            return;
        }
        
        
        if (queue.length > 0)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K contains[c] %@ OR %K contains[c] %@", kItemTitleKey, queue, kItemTitle2Key, queue];
            strongSelf.filteredListContent = [strongSelf.listContent filteredArrayUsingPredicate:predicate];
        }
        else
        {
            strongSelf.filteredListContent = strongSelf.listContent.copy;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.myTableView reloadData];
        });
        
    });
}

@end
