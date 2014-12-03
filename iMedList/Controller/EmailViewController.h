//
//  EmailViewController.h
//  iMedList
//
//  Created by Kent Franks on 12/2/14.
//  Copyright (c) 2014 TheAppCodeLLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <CoreData/CoreData.h>

@interface EmailViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
