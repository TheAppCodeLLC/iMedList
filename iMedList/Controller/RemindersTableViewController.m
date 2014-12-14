//
//  RemindersTableViewController.m
//  iMedList
//
//  Created by Kent Franks on 12/2/14.
//  Copyright (c) 2014 TheAppCodeLLC. All rights reserved.
//

#import "RemindersTableViewController.h"
#import "AddReminderViewController.h"
#import "Reminder.h"
#import "ReminderTableViewCell.h"
#import "ReminderTableView.h"

@interface RemindersTableViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) Reminder *reminder;
@end

@implementation RemindersTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // lazily instantiate our property
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create an instance of a fetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //Create an instance of NSEntityDescription that references our Reminder entity.
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Reminder" inManagedObjectContext:self.managedObjectContext];
    
    // our fetch request needs an entity, so we set it with the one we just created
    [fetchRequest setEntity:entity];
    
    // though not required, we can use a NSSortDescriptor to sort the results, we'll sort by id here.
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"id" ascending:NO];
    
    // set the sort descriptor in the fetchRequest
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    // We tell the fetchRequest to return 20 items at a time, probably more than we will need for this app
    // and not a requirement
    [fetchRequest setFetchBatchSize:20];
    
    //And finally create the NSFetchedResultsController using our fetchRequest and managedObjectContext
    NSFetchedResultsController *fetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    _fetchedResultsController = fetchedResultsController;
    
    // set the delegate to our self
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(ReminderTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)configureCell:(ReminderTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    self.reminder = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.customTextLabel.text = self.reminder.customMessage;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMMM dd yyy, hh:mm a"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EST"]];
    NSString *fireDate = [formatter stringFromDate:self.reminder.fireDate];
    cell.fireDateLabel.text = fireDate;
    cell.frequencyLabel.text = self.reminder.frequency;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (ReminderTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReminderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reminderCell" forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // check to see if want to delete
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // get the reminder we want to delete using the indexPath
        _reminder  = [_fetchedResultsController objectAtIndexPath:indexPath];
        NSString *notifIdToDelete = [NSString stringWithFormat:@"%@", _reminder.id];
        
        // set the reminder to delete
        // this will delete it from core data
        [self.managedObjectContext deleteObject:_reminder];
        NSError *error;
        
        // call save to perform the delete
        if (![self.managedObjectContext save:&error])
        {
            NSLog(@"Problem deleting reminder: %@", [error localizedDescription]);
        }
        
        // now delete from notification center
        UIApplication *app = [UIApplication sharedApplication];
        NSArray *notifArray = [app scheduledLocalNotifications];
        for (int i=0; i<[notifArray count]; i++)
        {
            UILocalNotification *tempNotif = [notifArray objectAtIndex:i];
            NSDictionary *userInfoCurrent = tempNotif.userInfo;
            NSString *notifId=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"notifId"]];
            if ([notifId isEqualToString:notifIdToDelete])
            {
                //Cancelling local notification
                [app cancelLocalNotification:tempNotif];
                break;
            }
        }
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the segue identifier
    NSString *segueIdentifier = [segue identifier];
    if ([segueIdentifier isEqualToString:@"addReminder"]) // This matches what we set it to in Interface Builder
    {
        // Get the new view controller using [segue destinationViewController].
        AddReminderViewController *addReminderViewController = [segue destinationViewController];
        // Pass the selected object to the new view controller.
        addReminderViewController.managedObjectContext = self.managedObjectContext;
    }
}

@end
