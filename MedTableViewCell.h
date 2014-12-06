//
//  MedTableViewCell.h
//  iMedList
//
//  Created by kent franks on 12/6/14.
//  Copyright (c) 2014 TheAppCodeLLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *doseLabel;
@property (weak, nonatomic) IBOutlet UILabel *frequencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;

@end
