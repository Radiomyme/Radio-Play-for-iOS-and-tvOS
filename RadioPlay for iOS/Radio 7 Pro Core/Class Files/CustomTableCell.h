//
//  CustomTableCell.h
//  Radio Play by Radiomyme
//

#import <UIKit/UIKit.h>

@interface CustomTableCell : UITableViewCell {
    
    IBOutlet UILabel     *myTitleView;
    IBOutlet UILabel     *mySubtitleView;
    IBOutlet UIImageView *radioIconImageView;
    IBOutlet UIImageView *radioWallpaperImageView;
    IBOutlet UIImageView *liveIconImageView;
    IBOutlet UIButton *playButton;
}

@property (nonatomic,retain) UILabel     *myTitleView;
@property (nonatomic,retain) UILabel     *mySubtitleView;
@property (nonatomic,retain) UIImageView *radioIconImageView;
@property (nonatomic,retain) UIImageView *radioWallpaperImageView;
@property (nonatomic,retain) UIImageView *liveIconImageView;
@property (nonatomic,retain) UIButton *playButton;

@end
