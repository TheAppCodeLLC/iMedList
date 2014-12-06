//
//  MedListTableViewController.m
//  iMedList
//
//  Created by Kent Franks on 12/2/14.
//  Copyright (c) 2014 TheAppCodeLLC. All rights reserved.
//

#import "MedListTableViewController.h"
#import "AddMedViewController.h"
#import "Med.h"
#import "EditMedViewController.h"
#import "MedTableViewCell.h"

@interface MedListTableViewController ()
@property (nonatomic, strong) Med *med;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation MedListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%s, %@", __PRETTY_FUNCTION__, self.managedObjectContext);
    [self fetchTheData];
}


- (void)fetchTheData
{
    //  create fetch object, this object fetch’s the objects out of the database
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Med" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = nil;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:(NSFetchRequest *)fetchRequest
                                 managedObjectContext:(NSManagedObjectContext *)self.managedObjectContext
                                 sectionNameKeyPath:nil
                                 cacheName:nil];
    _fetchedResultsController.delegate = self;
    NSError *error;
    BOOL success = [_fetchedResultsController performFetch:&error];
    NSLog(@"%s: performFetch = %@", __PRETTY_FUNCTION__, success ? @"Yes" : @"No");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MedTableViewCell *cell = (MedTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"medCell" forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(MedTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    self.med = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.nameLabel.text = self.med.name;
    cell.doseLabel.text = self.med.dose;
    cell.frequencyLabel.text = self.med.frequency;
    cell.noteLabel.text = self.med.notes;
}


#pragma mark FetchedResultsDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self tableView:tableView cellForRowAtIndexPath:newIndexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
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
        // get the med we want to delete using the indexPath
        _med  = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        // set the med to delete
        [self.managedObjectContext deleteObject:_med];
        NSError *error;
        
        // call save to perform the delete
        if (![self.managedObjectContext save:&error])
        {
            NSLog(@"Problem deleting med: %@", [error localizedDescription]);
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSString *segueIdentifier = [segue identifier];
    if ([segueIdentifier isEqualToString:@"addMed"]) // This can be defined via Interface Builder
    {
        AddMedViewController *addMedViewController = [segue destinationViewController];
        addMedViewController.managedObjectContext = self.managedObjectContext;
    }
    else if ([segueIdentifier isEqualToString:@"medDetail"]) // This can be defined via Interface Builder
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        _med  = [_fetchedResultsController objectAtIndexPath:indexPath];
        EditMedViewController *editMedViewController = [segue destinationViewController];
        editMedViewController.managedObjectContext = self.managedObjectContext;
        editMedViewController.medDetail = _med;
    }}

@end
