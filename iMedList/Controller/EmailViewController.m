//
//  EmailViewController.m
//  iMedList
//
//  Created by Kent Franks on 12/2/14.
//  Copyright (c) 2014 TheAppCodeLLC. All rights reserved.
//

#import "EmailViewController.h"
#import "Med.h"


@interface EmailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *recipientEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *sendersNameTextField;
@property (weak, nonatomic) Med *medication;
@property (nonatomic, strong) NSMutableArray *medsArray;
@property (strong, nonatomic) NSMutableString *emailBody;
@end

@implementation EmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - email

- (IBAction)sendEmail:(id)sender
{
    [self buildEmailBody];
    if ([MFMailComposeViewController canSendMail])
    {
        // set the sendTo address
        NSArray *recipients = [[NSArray alloc] initWithObjects:self.recipientEmailTextField.text, nil];
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.navigationBar.barStyle = UIBarStyleBlack;
        NSString *emailSubject = [[NSString alloc] initWithFormat:@"%@'s %@", self.sendersNameTextField.text, @"Medication List"];
        [controller setSubject:emailSubject];
        controller.mailComposeDelegate = self;
        [controller setMessageBody:self.emailBody isHTML:NO];
        [controller setToRecipients:recipients];
        
        // Present mail view controller on screen
        [self presentViewController:controller animated:YES completion:NULL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Your device is not set up for email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)buildEmailBody
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Med" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil)
    {
        // Handle the error.
        NSLog(@"mutableFetchResults == nil");
    }
    
    [self setMedsArray:mutableFetchResults];
    
    // create the email body
    self.emailBody = [NSMutableString stringWithFormat:@"Medication list for %@:", self.sendersNameTextField.text];
    [self.emailBody appendString:@"\n"];
    [self.emailBody appendString:@"\n"];
    for (int i = 0; i < [self.medsArray count]; i++)
    {
        self.medication = [self.medsArray objectAtIndex:i];
        [self.emailBody appendString:self.medication.name];
        [self.emailBody appendString:@",   "];
        [self.emailBody appendString:self.medication.dose];
        [self.emailBody appendString:@"  -  "];
        [self.emailBody appendString:self.medication.frequency];
        [self.emailBody appendString:@"\n"];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Email Failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
            break;
    }
    
    [self becomeFirstResponder];
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
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
