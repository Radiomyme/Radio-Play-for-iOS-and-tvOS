//
//  Level1ViewController.m
//  Radio 7 Pro
//
//  Created by Christopher Coudriet on 10/15/2012.
//  Copyright Christopher Coudriet 2012. All rights reserved.
//
//  Permission is given to license this source code file, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that this source code cannot be redistributed or sold (in part or whole) and must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "Level1ViewControllerArtist.h"
#import "UIImageView+WebCache.h"
#import "SVWebViewController.h"
#import "SVModalWebViewController.h"
#import "CustomTableCellArtist.h"
#import "AppDelegate.h"
#import "Settings.h"

@implementation Level1ViewControllerArtist

@synthesize listContentArtist, myImageViewArtist, myTableViewArtist, myImageWallpaperArtist;

- (void)dealloc
{
    [listContentArtist release];
	[myTableViewArtist release];
	
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
										         name:@"PushFacbookView"
									           object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
										     selector:@selector(pushTwitterView:)
										         name:@"PushTwitterView"
									           object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
										     selector:@selector(updateView:) 
										         name:@"UpdateLevel1" 
									           object:nil];
    // NowPlaying Support
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(isPlayingBtn:)
                                                 name:@"isPlaying" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeNowPlayingBtn:)
                                                 name:@"isNotPlaying" object:nil];
    // End Now Playing Support
    
    [myTableViewArtist setRowHeight:100.0];
    
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] &&
        (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable))
    {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
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
    
    [self.tabBarController.tabBar setBackgroundImage:[UIImage new]];
    self.tabBarController.tabBar.shadowImage = [UIImage new];
    self.tabBarController.tabBar.translucent = YES;
    self.tabBarController.tabBar.backgroundColor = [UIColor clearColor];

    _isLocalEnabled = LOCAL_ENABLED;
    
    if (_isLocalEnabled)
    {
        [self loadLocalStationsViewWillAppear];
    }
    else
    {
        [self loadRemoteStationsViewWillAppear];
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

// Single/Multi Station Support

// Load Local Stations
- (void)loadLocalStationsViewWillAppear
{
    if ([listContentArtist count ] <= 1)
    {
        // NSLog(@"%lu", (unsigned long)[listContent count]);
        
        self.navigationController.navigationBarHidden = YES;
        
        self.tabBarController.tabBar.hidden = YES;
        
        myTableViewArtist.alpha = 0;
        myImageViewArtist.alpha = 0;
        myImageWallpaperArtist.alpha = 0;
        
        [self performSelector:@selector(selectFirstRow) withObject:nil afterDelay:0.1];
    }
    else
    {
        [myTableViewArtist reloadData];
    }
}

- (void)loadLocalStationsUpdateView
{
    if ([listContentArtist count ] <= 1)
    {
        // NSLog(@"%lu", (unsigned long)[listContent count]);
        
        NSLog(@"Single Station Local Mode");
    }
    else
    {
        NSLog(@"Multi Station Local Mode");
        
        self.navigationController.navigationBarHidden = NO;
        
        self.tabBarController.tabBar.hidden = NO;
        
        self.navigationItem.title = @"Artists";
        
        myTableViewArtist.userInteractionEnabled = YES;
        myImageViewArtist.alpha = 1;
        myImageWallpaperArtist.alpha = 1;
        myTableViewArtist.alpha = 1;
        
        [myTableViewArtist reloadData];
    }
}
// End Load Local Stations


// Load Remote Stations
- (void)loadRemoteStationsViewWillAppear
{
    if ([listContentArtist count ] <= 1)
    {
        // NSLog(@"%lu", (unsigned long)[listContent count]);
        
        self.navigationController.navigationBarHidden = YES;
        
        self.tabBarController.tabBar.hidden = YES;
        
        myTableViewArtist.alpha = 0;
        myImageViewArtist.alpha = 0;
        myImageWallpaperArtist.alpha = 0;
    }
    else
    {
        [myTableViewArtist reloadData];
    }
}

- (void)loadRemoteStationsUpdateView
{
    if ([listContentArtist count ] <= 1)
    {
        NSLog(@"Single Station Remote Mode");
        
        // NSLog(@"%lu", (unsigned long)[listContent count]);
        
        [myTableViewArtist reloadData];
        
        [self performSelector:@selector(selectFirstRow) withObject:nil afterDelay:0.1];
    }
    else
    {
        NSLog(@"Multi Station Remote Mode");
        
        self.navigationController.navigationBarHidden = NO;
        
        self.tabBarController.tabBar.hidden = NO;
        
        self.navigationItem.title = @"Artists";
        
        myTableViewArtist.userInteractionEnabled = YES;
        myImageViewArtist.alpha = 1;
        myImageWallpaperArtist.alpha = 1;
        myTableViewArtist.alpha = 1;
       
        [myTableViewArtist reloadData];
    }
}
// Ene Load Remote Stations

- (void)selectFirstRow
{
	if ([self.myTableViewArtist numberOfSections] > 0 && [self.myTableViewArtist numberOfRowsInSection:0] > 0) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		[self.myTableViewArtist selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
		[self tableView:self.myTableViewArtist didSelectRowAtIndexPath:indexPath];
    }
}

// End Single/Multi Station Support


// NowPlaying Support
- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
										     selector:@selector(handleEnterForeground:)
										         name:UIApplicationWillEnterForegroundNotification
									           object:nil];

	UIApplication *application = [UIApplication sharedApplication];
	
	if([application respondsToSelector:@selector(beginReceivingRemoteControlEvents)])
		[application beginReceivingRemoteControlEvents];
	
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
// NowPlaying Support

- (void)handleEnterForeground:(UIApplication *)notification
{
    _didEnterForeground = YES;
}

- (void)pushFacebookView:(NSNotification *)notification
{
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:@"https://www.facebook.com/radiomyme"];
    
    //[self setHidesBottomBarWhenPushed: YES];
    
    [self.navigationController presentViewController:webViewController animated:YES completion:nil];
    
    // [self.navigationController pushViewController:webViewController animated:YES];
    
   // [self setHidesBottomBarWhenPushed: NO];
}

- (void)pushTwitterView:(NSNotification *)notification
{
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:@"https://twitter.com/radiomyme"];
    
    //[self setHidesBottomBarWhenPushed: YES];
    
    [self.navigationController presentViewController:webViewController animated:YES completion:nil];
    
    //[self.navigationController pushViewController:webViewController animated:YES];
    
   // [self setHidesBottomBarWhenPushed: NO];
}

#pragma mark UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [listContentArtist count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopPlayer" object:nil];
    
    NSString *selectedStream;
    NSString *selectedStreamTitle;
	
	NSDictionary* item = [listContentArtist objectAtIndex:indexPath.row];
    selectedStreamTitle = [item objectForKey:kItemTitleKey];
	selectedStream = [item objectForKey:kItemTitle2Key];
    
    // Single Station Support For Either Local or Remote
    if ([listContentArtist count ] <= 1)
    {
        // NSLog(@"%lu", (unsigned long)[listContent count]);
        
        [self setHidesBottomBarWhenPushed: YES];
        
        self.navigationController.navigationBarHidden = NO;
        
        self.tabBarController.tabBar.hidden = NO;
    }
    else
    {
        [self setHidesBottomBarWhenPushed: YES];
        
    }
    // End Single Station Support For Either Local or Remote
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"customCellArtist";
    
    CustomTableCellArtist *cell = (CustomTableCellArtist *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        NSArray * topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomTableCellArtist" owner:self options:nil];
        
        for(id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (CustomTableCellArtist *)currentObject;
                break;
            }
        }
    }
	
    cell.backgroundColor = [UIColor clearColor];
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:108.0 / 255 green:100.0 / 255 blue:192.0 / 255 alpha:0.6]];
    [cell setSelectedBackgroundView:bgColorView];
    
    // get the view controller's info dictionary based on the indexPath's row
	NSDictionary* item = [listContentArtist objectAtIndex:indexPath.row];
	
    cell.myTitleViewArtist.textColor = [UIColor colorWithRed:255.0 / 255 green:255.0 / 255 blue:255.0 / 255 alpha:1.0];
	cell.myTitleViewArtist.text = [item objectForKey:kItemTitleKeyArtist];
	
	cell.mySubtitleViewArtist.textColor = [UIColor colorWithRed:255.0 / 255 green:255.0 / 255 blue:255.0 / 255 alpha:1.0];
	cell.mySubtitleViewArtist.text = [item objectForKey:@"subtitleArtist"];

    NSString *urlAsString = [item objectForKey:kImageFilePathKeyArtist];;
	NSURL *imageURLArtist = [NSURL URLWithString:urlAsString];
    
    //[cell.myImageView setOptimizedImageWithURL:imageURL];
    [cell.myImageWallpaperArtist setOptimizedImageWithURL:imageURLArtist];

	return cell;
}

- (BOOL)isForceTouchAvailable {
    BOOL isForceTouchAvailable = NO;
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        isForceTouchAvailable = self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    }
    return isForceTouchAvailable;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    
    [self showDetailViewController:viewControllerToCommit sender:self];
}


@end