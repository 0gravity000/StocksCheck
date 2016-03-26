//
//  AppDelegate.h
//  StocksCheck
//
//  Created by SASAKIAI on 2016/03/05.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (strong, atomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property bool IsBackResistView;
@property NSString *addedCode;

@property NSMutableArray *stocksArray;

@property dispatch_source_t BackgraundTimerSource; // タイマーソース
@property dispatch_source_t mainTimerSource; // タイマーソース

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

