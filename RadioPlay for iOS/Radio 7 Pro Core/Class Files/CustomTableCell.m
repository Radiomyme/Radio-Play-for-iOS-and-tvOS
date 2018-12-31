//
//  CustomTableCell.m
//  Radio Play by Radiomyme
//

#import "CustomTableCell.h"


@implementation CustomTableCell;

@synthesize myTitleView, mySubtitleView, radioIconImageView, radioWallpaperImageView, liveIconImageView, playButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}


@end
