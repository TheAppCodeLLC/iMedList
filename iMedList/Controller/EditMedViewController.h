//
//  EditMedViewController.h
//  iMedList
//
//  Created by Kent Franks on 12/2/14.
//  Copyright (c) 2014 TheAppCodeLLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Med.h"

@interface EditMedViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Med *medDetail;

@end
