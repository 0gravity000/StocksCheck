//
//  AppDelegate.m
//  StocksCheck
//
//  Created by SASAKIAI on 2016/03/05.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

#import "AppDelegate.h"
//#import "MasterViewController.h"
#import "BoardViewController.h"
//#import "DetailViewController.h"
//#import "ResistViewController.h"
#import "ObservTableViewController.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    //UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    //navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    //splitViewController.delegate = self;

    //UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
    //MasterViewController *controller = (MasterViewController *)masterNavigationController.topViewController;
    BoardViewController *controller = (BoardViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
    
    //Load CSV File from web
    self.stocksArray = [NSMutableArray array];
    [self loadCSVFromRemote];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    //Load CSV File from web
    self.stocksArray = [NSMutableArray array];
    [self loadCSVFromRemote];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

//#pragma mark - Split view
//
//- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
//    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
//        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
//        return YES;
//    } else {
//        return NO;
//    }
//}

#pragma mark - Load Stocks CSV Data

// HTTP からファイルをロード
- (void)loadCSVFromRemote
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
            NSLog(@"fail delete. file not exist");
            NSLog(@"Error !: %@", [error localizedDescription]);
        }
    }
    
    NSLog(@"loading CSV File");
    // 別のスレッドでファイル読み込みをキューに加える
    NSOperationQueue *queue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc]
                                        initWithTarget:self
                                        selector:@selector(loadCSVFromWeb)
                                        object:nil];
    [queue addOperation:operation];

}

-(void)loadCSVFromWeb {
    // 読み込むファイルの URL を作成
    NSURL *url = [NSURL URLWithString:@"http://0gravity000.web.fc2.com/xxx_stockList/stocks.txt"];
    
    NSError *error = nil;
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

}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "ne.jp.0gravity000.StocksCheck" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"StocksCheck" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"StocksCheck.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
