//
//  MedPickerViewController.m
//  iMedList
//
//  Created by Kent Franks on 12/2/14.
//  Copyright (c) 2014 TheAppCodeLLC. All rights reserved.
//

#import "MedPickerViewController.h"
#import <sqlite3.h>

@interface MedPickerViewController ()
- (void) makeDBCopyAsNeeded;
- (void) getMedsFromDB;
@end

@implementation MedPickerViewController

NSArray *medsArray;
sqlite3 *database;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self makeDBCopyAsNeeded];
    [self getMedsFromDB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - picker view methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [medsArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [medsArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"%s, med selected:%@", __PRETTY_FUNCTION__, [medsArray objectAtIndex:row]);
    _selectedMed = [[NSString alloc]initWithString:[medsArray objectAtIndex:row]];
}

#pragma mark DB methods

- (void) makeDBCopyAsNeeded
{
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"iMedFullList.sqlite"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success)
    {
        return;
    }
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iMedFullList.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success)
    {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

- (void) getMedsFromDB
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iMedFullList.sqlite"];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        
        const char *sql = "select * from medications";
        
        sqlite3_stmt *searchStatement;
        
        if (sqlite3_prepare_v2(database, sql, -1, &searchStatement, NULL) == SQLITE_OK)
        {
            NSMutableArray *tempMedArray = [[NSMutableArray alloc]init];
            while (sqlite3_step(searchStatement) == SQLITE_ROW)
            {
                NSString *medCommonName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(searchStatement, 1)];
                NSLog(@"%s, %@ is a med", __PRETTY_FUNCTION__, medCommonName);
                [tempMedArray addObject:medCommonName];
            }
            medsArray = [[NSArray alloc] initWithArray:tempMedArray];
        }
        sqlite3_finalize(searchStatement);
    }
    
}

#pragma mark - Navigation

-(IBAction)goBackToAddMedView:(id)sender
{
    NSLog(@"%s, selectedMed:%@", __PRETTY_FUNCTION__, _selectedMed);
    [self dismissViewControllerAnimated:YES completion:nil];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
