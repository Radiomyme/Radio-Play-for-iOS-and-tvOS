//
//  Level1ViewController.h
//  Radio Play by Radiomyme
//

#import "PlayerViewController.h"
#import "AppDelegate.h"
#import <UIKit/UIKit.h>

@import SafariServices;

@class PlayerViewController, AppDelegate;

@interface Level1ViewController : UIViewController <UIViewControllerPreviewingDelegate, UISearchResultsUpdating, UISearchBarDelegate, SFSafariViewControllerDelegate>
{
	NSArray					*listContent;
    NSArray					*filteredListContent;
    UIImageView				*myImageView;
	UITableView				*myTableView;
    UIImageView             *myImageWallpaper;
	
    PlayerViewController    *streamViewController;
	AppDelegate				*appDelegate;
}

// Local or Remote Database Support

@property (assign) BOOL isLocalEnabled;

// End Local or Remote Database Support

@property (assign) BOOL didEnterForeground;

@property (nonatomic, retain) NSArray                         *listContent;
@property (nonatomic, retain) NSArray                         *filteredListContent;
@property (nonatomic, retain) IBOutlet UIImageView            *myImageView;
@property (nonatomic, retain) IBOutlet UITableView            *myTableView;
@property (nonatomic, retain) IBOutlet UIImageView            *myImageWallpaper;
@property (nonatomic, strong) id previewingContext;

@property (nonatomic, strong) UISearchController *searchController;
@property (assign, readonly, getter=isSearchActive) BOOL searchActive;

@end
