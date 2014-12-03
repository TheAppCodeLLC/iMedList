//
//  AddMedViewController.m
//  iMedList
//
//  Created by Kent Franks on 12/2/14.
//  Copyright (c) 2014 TheAppCodeLLC. All rights reserved.
//

#import "AddMedViewController.h"
#import "MedPickerViewController.h"


@interface AddMedViewController ()
@property (weak, nonatomic) IBOutlet UITextField *medNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *medDoseTextField;
@property (weak, nonatomic) IBOutlet UITextField *medFrequencyTextField;
@property (weak, nonatomic) IBOutlet UITextField *medNotesTextField;
@end

@implementation AddMedViewController

MedPickerViewController *pickerViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (pickerViewController)
    {
        self.medNameTextField.text = pickerViewController.selectedMed;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveMed:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // create instance on NSManagedObect for Med
    NSManagedObject	*med = [NSEntityDescription insertNewObjectForEntityForName:@"Med" inManagedObjectContext:_managedObjectContext];
    [med setValue:self.medNameTextField.text forKey:@"name"];
    [med setValue:self.medDoseTextField.text forKey:@"dose"];
    [med setValue:self.medFrequencyTextField.text forKey:@"frequency"];
    [med setValue:self.medNotesTextField.text forKey:@"notes"];
    NSError *error;
    
    // here’s where the actual save happens, and if it doesn’t we print something out to the console
    if (![_managedObjectContext save:&error])
    {
        NSLog(@"Problem saving: %@", [error localizedDescription]);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    [theTextField resignFirstResponder];
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    if ([[segue destinationViewController] isKindOfClass:[MedPickerViewController class]])
    {
        pickerViewController = [segue destinationViewController];
    }
    // Pass the selected object to the new view controller.
}

@end
