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
#import "Reachability.h"

@class ObservTableViewController;
@class ResistViewController;

@interface BoardViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) ObservTableViewController *observTableViewController;
//@property (strong, nonatomic) ResistViewController *resistViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (strong, atomic) NSFetchedResultsController *fetchedResultsController;
//@property (strong, atomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UILabel *dateMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *nikkeiLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarItemButton;
@property (weak, nonatomic) IBOutlet UISwitch *refreshSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBarItemButton;

@property (weak, nonatomic) IBOutlet BoardTableView *boardTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *refreshIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *remoteHostImageView;

- (IBAction)pushRefreshBarItemButton:(id)sender;
- (IBAction)changeRefreshSwitch:(id)sender;

//@property dispatch_source_t BackgraundTimerSource; // タイマーソース
//@property dispatch_source_t mainTimerSource; // タイマーソース
@property NSTimer *autoRefershTimer;
@property NSString *dateMessageLabelStr;
@property NSString *nikkeiLabelStr;
@property NSMutableArray *tempPriceMArray;
@property NSMutableArray *tempObserveImageMArray;
@property NSMutableArray *tempNoticeTimeMArray;

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@property int inetworkStatusFlag;
@property int wifiStatusFlag;
@property int refreshingFlag;
//@property int refreshSwitchOnCount;
@property NSTimer *inetRetryTimer;
@property NSTimer *wifiRetryTimer;
//@property int inetRetryCount;
//@property int wifiRetryCount;
@property BOOL IsDispatchSourceTimerExcute;

@end
