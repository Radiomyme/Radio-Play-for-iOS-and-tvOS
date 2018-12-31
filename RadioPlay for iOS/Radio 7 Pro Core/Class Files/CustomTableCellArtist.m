//
//  CustomTableCell.m
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

#import "CustomTableCellArtist.h"


@implementation CustomTableCellArtist;

@synthesize myTitleViewArtist, mySubtitleViewArtist, myImageViewArtist, myImageWallpaperArtist;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
    
    [myTitleViewArtist release];
    [mySubtitleViewArtist release];
    [myImageViewArtist release];
    [myImageWallpaperArtist release];
    
    [super dealloc];
}

@end
