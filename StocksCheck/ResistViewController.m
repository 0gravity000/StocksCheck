//
//  ResistViewController.m
//  StocksCheck
//
//  Created by SASAKIAI on 2016/03/05.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

#import "ResistViewController.h"

@interface ResistViewController ()

@end

@implementation ResistViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    self.codeSearchBar.delegate = self;
    self.codeSearchBar.showsCancelButton = true;
    
    self.stocksArray = [NSMutableArray array];
    self.searchResultArray = [NSMutableArray array];
    [self.stocksArray removeAllObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // called when keyboard search button pressed
    [searchBar resignFirstResponder];
    
    //close View
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //NSLog(@"%lu", (unsigned long)[[self.fetchedResultsController sections] count]);
    //return [[self.fetchedResultsController sections] count];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    //return [sectionInfo numberOfObjects];
    //return [self.stocksArray count];
    return [self.searchResultArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    ResistTableViewCell *cell = (ResistTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(ResistTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //if ([self.stocksArray count] > 0) {
    if ([self.searchResultArray count] > 0) {
//        NSDictionary *dic;
//        dic = [self.searchResultArray objectAtIndex:indexPath.row];
//        //Code
//        cell.textLabel.text = [dic objectForKey:@"key1"];
//        //銘柄名
//        cell.detailTextLabel.text = [dic objectForKey:@"key3"];
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        /*
         NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
         [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
         
         NSError *error = nil;
         if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
         }
         */
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
}

@end
