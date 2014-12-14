//
//  ReminderTableViewCell.h
//  iMedList
//
//  Created by Kent Franks on 12/13/14.
//  Copyright (c) 2014 TheAppCodeLLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReminderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *customTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *fireDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *frequencyLabel;

@end
