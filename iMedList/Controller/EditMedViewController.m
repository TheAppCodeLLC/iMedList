//
//  EditMedViewController.m
//  iMedList
//
//  Created by Kent Franks on 12/2/14.
//  Copyright (c) 2014 TheAppCodeLLC. All rights reserved.
//

#import "EditMedViewController.h"

@interface EditMedViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *doseTextField;
@property (weak, nonatomic) IBOutlet UITextField *frequencyTextField;
@property (weak, nonatomic) IBOutlet UITextField *notesTextField;
@end

@implementation EditMedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _nameTextField.text = _medDetail.name;
    _doseTextField.text = _medDetail.dose;
    _frequencyTextField.text = _medDetail.frequency;
    _notesTextField.text = _medDetail.notes;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editMed:(id)sender
{
    _nameTextField.enabled = YES;
    _doseTextField.enabled = YES;
    _frequencyTextField.enabled = YES;
    _notesTextField.enabled = YES;
}

- (IBAction)saveMed:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [_medDetail setValue:_nameTextField.text forKey:@"name"];
    [_medDetail setValue:_doseTextField.text forKey:@"dose"];
    [_medDetail setValue:_frequencyTextField.text forKey:@"frequency"];
    [_medDetail setValue:_notesTextField.text forKey:@"notes"];
    
    NSError *error;
    
    if (![_managedObjectContext save:&error])
    {
        NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
