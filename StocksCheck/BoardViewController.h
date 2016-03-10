//
//  BoardViewController.h
//  StocksCheck
//
//  Created by SASAKIAI on 2016/03/05.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BoardTableView.h"
#import "BoardTableViewCell.h"
#import "AppDelegate.h"

//@class DetailViewController;
@class ObservTableViewController;
@class ResistViewController;

@interface BoardViewController : UIViewController <NSFetchedResultsControllerDelegate>

//@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) ObservTableViewController *observTableViewController;
//@property (strong, nonatomic) ResistViewController *resistViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property NSTimer *autoRefershTimer;

@property (weak, nonatomic) IBOutlet UILabel *dateMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *nikkeiLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarItemButton;
@property (weak, nonatomic) IBOutlet UISwitch *refreshSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBarItemButton;

@property (weak, nonatomic) IBOutlet BoardTableView *boardTableView;

- (IBAction)pushRefreshBarItemButton:(id)sender;
- (IBAction)changeRefreshSwitch:(id)sender;

@property dispatch_source_t timerSource; // タイマーソース

@end
