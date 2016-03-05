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

@class DetailViewController;
@class ResistViewController;

@interface BoardViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
//@property (strong, nonatomic) ResistViewController *resistViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet BoardTableView *boardTableView;

@end
