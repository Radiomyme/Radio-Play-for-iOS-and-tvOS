//
//  CustomTableCell.h
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

#import <UIKit/UIKit.h>

@interface CustomTableCellArtist : UITableViewCell {
    
    IBOutlet UILabel     *myTitleViewArtist;
    IBOutlet UILabel     *mySubtitleViewArtist;
    IBOutlet UIImageView *myImageViewArtist;
    IBOutlet UIImageView *myImageWallpaperArtist;
}

@property (nonatomic,retain) UILabel     *myTitleViewArtist;
@property (nonatomic,retain) UILabel     *mySubtitleViewArtist;
@property (nonatomic,retain) UIImageView *myImageViewArtist;
@property (nonatomic,retain) UIImageView *myImageWallpaperArtist;

@end
