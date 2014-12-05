//
//  AddReminderViewController.m
//  iMedList
//
//  Created by Kent Franks on 12/2/14.
//  Copyright (c) 2014 TheAppCodeLLC. All rights reserved.
//

#import "AddReminderViewController.h"
#import "Reminder.h"


@interface AddReminderViewController ()
@property (weak, nonatomic) IBOutlet UITextField *customMessageTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *notifDatePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *frequencySegmentedControl;
@property (nonatomic, strong) NSString *notifID;
@property (nonatomic, strong) NSMutableDictionary *notifDict;
@end

@implementation AddReminderViewController

bool allowNotif;
bool allowsSound;
bool allowsBadge;
bool allowsAlert;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNotificationTypesAllowed
{
    NSLog(@"%s:", __PRETTY_FUNCTION__);
    // get the current notification settings
    UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    allowNotif = (currentSettings.types != UIUserNotificationTypeNone);
    allowsSound = (currentSettings.types & UIUserNotificationTypeSound) != 0;
    allowsBadge = (currentSettings.types & UIUserNotificationTypeBadge) != 0;
    allowsAlert = (currentSettings.types & UIUserNotificationTypeAlert) != 0;
}

- (IBAction)saveReminder:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self setNotificationTypesAllowed];
    
    _notifID = [[NSString alloc] initWithFormat:@"%f",[self.notifDatePicker.date timeIntervalSinceReferenceDate]];
    
    // New for iOS 8 - Register the notifications
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];

    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification)
    {
        if (allowNotif)
        {
            notification.fireDate = self.notifDatePicker.date;
            notification.timeZone = [NSTimeZone defaultTimeZone];
            switch (_frequencySegmentedControl.selectedSegmentIndex) {
                case 0:
                    notification.repeatInterval = NSCalendarUnitDay;
                    break;
                case 1:
                    notification.repeatInterval = NSCalendarUnitWeekOfYear;
                    break;
                case 2:
                    notification.repeatInterval = NSCalendarUnitYear;
                    break;
                default:
                    notification.repeatInterval = 0;
                    break;
            }
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:_notifID forKey:@"notifId"];
            notification.userInfo = userInfo;

        }
        if (allowsAlert)
        {
            notification.alertBody = self.customMessageTextField.text;
        }
        if (allowsBadge)
        {
            notification.applicationIconBadgeNumber = 1;
        }
        if (allowsSound)
        {
            notification.soundName = UILocalNotificationDefaultSoundName;
        }
    }
    
    // this will schedule the notification to fire at the fire date
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];

    //For development and debugging purposes only
    // we're creating a string of the date so we can log the time the notif is supposed to fire
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM-dd-yyy hh:mm"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EST"]];
    NSString *notifDate = [formatter stringFromDate:self.notifDatePicker.date];
    NSLog(@"%s: fire time = %@", __PRETTY_FUNCTION__, notifDate);

    [self saveReminderToCoreData];
}

- (IBAction)saveReminderToCoreData
{
    
    NSLog(@"%s:", __PRETTY_FUNCTION__);
    // get an instance of Reminder
    Reminder *reminder = (Reminder *)[NSEntityDescription insertNewObjectForEntityForName:@"Reminder" inManagedObjectContext:_managedObjectContext];
    //populate the reminder object
    reminder.customMessage = self.customMessageTextField.text;
    reminder.fireDate = self.notifDatePicker.date;
    reminder.id = _notifID;
    switch (_frequencySegmentedControl.selectedSegmentIndex)
    {
        case 0:
            reminder.frequency = @"Daily";
            break;
        case 1:
            reminder.frequency = @"Weekly";
            break;
        case 2:
            reminder.frequency = @"Monthyly";
            break;
        default:
            reminder.frequency = 0;
            break;
    }
    
    NSError *error;
    
    // here's where the actual save happens, and if it doesn't we print something out to the console
    if (![_managedObjectContext save:&error])
    {
        NSLog(@"Problem saving: %@", [error localizedDescription]);
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error"
                                                         message:@"Saving the reminder failed"
                                                        delegate:self
                                               cancelButtonTitle:@"ok"
                                               otherButtonTitles: nil];
        [alert show];
    }
    
    [self.navigationController popViewControllerAnimated:YES];

}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    [theTextField resignFirstResponder];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
