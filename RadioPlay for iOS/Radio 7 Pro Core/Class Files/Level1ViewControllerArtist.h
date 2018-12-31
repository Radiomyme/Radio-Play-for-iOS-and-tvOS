//
//  Level1ViewController.h
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

#import "PlayerViewController.h"
#import "AppDelegate.h"
#import <UIKit/UIKit.h>

@class AppDelegate;

@interface Level1ViewControllerArtist : UIViewController <UIViewControllerPreviewingDelegate>
{
	NSArray					*listContentArtist;
    UIImageView				*myImageViewArtist;
	UITableView				*myTableViewArtist;
    UIImageView             *myImageWallpaperArtist;
	
    AppDelegate				*appDelegate;
}

// Local or Remote Database Support

@property (assign) BOOL isLocalEnabled;

// End Local or Remote Database Support

@property (assign) BOOL didEnterForeground;

@property (nonatomic, retain) NSArray                         *listContentArtist;
@property (nonatomic, retain) IBOutlet UIImageView            *myImageViewArtist;
@property (nonatomic, retain) IBOutlet UITableView            *myTableViewArtist;
@property (nonatomic, retain) IBOutlet UIImageView            *myImageWallpaperArtist;
@property (nonatomic, strong) id previewingContext;

@end
