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
    
    [self loadImageFromRemote];
    NSLog(@"load from remote");

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// HTTP からファイルをロード
- (void)loadImageFromRemote
{
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray* possibleURLs = [sharedFM URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL* documentsDir = nil;
    NSURL* documentsNameWithDir = nil;
    NSString *fileName = @"stocks.txt";
    NSError *error = nil;
    //NSURL *sorceUrl = [NSURL URLWithString:@"http://0gravity000.web.fc2.com/xxx_stockList/stocks.txt"];
    BOOL IsSuccess;
    
    if ([possibleURLs count] >= 1) {
        // Use the first directory (if multiple are returned)
        documentsDir = [possibleURLs objectAtIndex:0];
        documentsNameWithDir = [documentsDir URLByAppendingPathComponent:fileName];
        //delete file
        IsSuccess = [sharedFM removeItemAtURL:documentsNameWithDir error:&error];
        if (IsSuccess) {
            NSLog(@"success delete");
        } else {
            NSLog(@"fail delete");
            NSLog(@"Error !: %@", [error localizedDescription]);
        }
    }
    // 読み込むファイルの URL を作成
    NSURL *url = [NSURL URLWithString:@"http://0gravity000.web.fc2.com/xxx_stockList/stocks.txt"];
    
    NSString *strData = [[NSString alloc] initWithContentsOfURL:url  encoding:NSUTF16StringEncoding error:&error];
    NSLog(@"Error !: %@", [error localizedDescription]);
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"stocks.txt"];
    
    //NSString *data;
    BOOL success = [fileManager fileExistsAtPath:dataPath];
    if (success) {
        strData = [NSString stringWithContentsOfFile:dataPath encoding:NSUTF16StringEncoding error:nil];
    } else {
        [strData writeToFile:dataPath atomically:YES encoding:NSUTF16StringEncoding error:&error];
    }
    NSLog(@"Error !: %@", [error localizedDescription]);
    
    [self readStocksTextdata:strData];
    
}

-(void) readStocksTextdata:(NSString *)data {
    
    // UTF16 エンコードされた CSV ファイル
    //    NSString *filePath = @"/Users/rakuishi/Desktop/test.csv";
    //    NSString *text = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    // 改行文字で区切って配列に格納する
    //NSArray *lines = [text componentsSeparatedByString:@"\n"];
    NSArray *lines = [data componentsSeparatedByString:@"\n"];
    NSLog(@"lines count: %ld", lines.count);    // 行数
    
    NSString *key;
    NSString *value;
    
    for (NSString *row in lines) {
        // コンマで区切って配列に格納する
        NSArray *items = [row componentsSeparatedByString:@","];
        NSMutableDictionary *stocksDic = [NSMutableDictionary dictionary];
        
        int cnt = 1;
        for (NSString *column in items) {
            //[self.keyArray addObject:[@"key" stringByAppendingString:[NSString stringWithFormat:@"%d", cnt]]];
            //[self.valueArray addObject:column];
            key = [@"key" stringByAppendingString:[NSString stringWithFormat:@"%d", cnt]];
            value = column;
            [stocksDic setObject:value forKey:key];
            cnt++;
        }
        [self.stocksArray addObject:stocksDic];
        //NSLog(@"%@", items);778
    }
    //先頭の2行はヘッダーデータで不要なので削除
    [self.stocksArray removeObjectsInRange:NSMakeRange(0, 2)];
    NSLog(@"self.stocksArray count: %ld", lines.count);    // 行数
    
    //---reload table view
    //[self.resistTableView reloadData];
}


#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // called when text changes (including clear)
    [self.searchResultArray removeAllObjects];
    NSString *searchStr = self.codeSearchBar.text;
    
    if (![searchStr isEqualToString:@""]) {
        //search in array
        int i=0;
        BOOL bHitFlag;
        for (i=0; i < [self.stocksArray count]; i++) {
            bHitFlag = false;
            NSDictionary *dic = [self.stocksArray objectAtIndex:i];
            NSString *code = [dic objectForKey:@"key1"];
            NSString *name = [dic objectForKey:@"key3"];
            
            NSRange codeRange = [code rangeOfString:searchStr];
            if (codeRange.location != NSNotFound) {
                bHitFlag = true;
            }
            NSRange nameRange = [name rangeOfString:searchStr];
            if (nameRange.location != NSNotFound) {
                bHitFlag = true;
            }
            
            if (bHitFlag == true) {
                [self.searchResultArray addObject:dic];
            }
        }
    }
    //---reload table view
    [self.resistTableView reloadData];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // called when keyboard search button pressed
    [searchBar resignFirstResponder];
    //close View
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // called when text starts editing
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic;
    dic = [self.searchResultArray objectAtIndex:indexPath.row];
    //Code
    NSString *code  = [dic objectForKey:@"key1"];
    [self.detailItem setValue:code forKey:@"code"];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.IsBackResistView = TRUE;
    appDelegate.addedCode = code;
    
    //close View
    [self dismissViewControllerAnimated:YES completion:nil];
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
        NSDictionary *dic;
        dic = [self.searchResultArray objectAtIndex:indexPath.row];
        //Code
        cell.textLabel.text = [dic objectForKey:@"key1"];
        //銘柄名
        cell.detailTextLabel.text = [dic objectForKey:@"key3"];
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
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
