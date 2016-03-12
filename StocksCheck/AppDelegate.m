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
    NSLog(@"*** Now application didFinishLaunchingWithOptions");
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
    
    [self resisterLocalNotification];
    application.applicationIconBadgeNumber = 0;
    
    //Load CSV File from web
    self.stocksArray = [NSMutableArray array];
    [self loadCSVFromRemote];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"*** Now applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    //Start Background Fetch
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"*** Now applicationDidEnterBackground");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"*** Now applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    application.applicationIconBadgeNumber = 0;
    //Stop background Fetch
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
    
    //Load CSV File from web
    self.stocksArray = [NSMutableArray array];
    [self loadCSVFromRemote];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"*** Now applicationDidBecomeActive");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"*** Now applicationWillTerminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    
    // タイマ破棄
    if(self.BackgraundTimerSource){
        dispatch_source_cancel(self.BackgraundTimerSource);
    }
    if(self.mainTimerSource){
        dispatch_source_cancel(self.mainTimerSource);
    }
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


#pragma mark - Background Fetch
// バックグラウンド実行の際に呼び出される
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    // ここにバックグラウンド処理
    NSLog(@"execute Background Fetch");
    [self refreshPriceValueMainThread];
    [self checkObserveVaulesMainThread];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

-(NSString *)refreshPriceValue:(NSInteger)indexRow {
    NSLog(@"*** Now refreshPriceValue");
    
    //    //--- Show Stock Page in WebView
    //    NSError *error = nil;
    //    self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
    //    NSIndexPath *indexPath;
    //    NSManagedObject *object;
    //    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
    //    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
    //    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    //    NSLog(@"Error !: %@", [error localizedDescription]);
    //    NSLog(@"CoreData count = %ld", count);
    
    NSString *url;
    NSString *codebuf;
    NSString *placebuf;
    NSString *pricebuf;
    NSIndexPath *indexPath;
    NSManagedObject *object;
    //    for (int i=0; i < count; i++) {
    //    indexPath = [NSIndexPath indexPathForRow:i inSection:0];
    indexPath = [NSIndexPath indexPathForRow:indexRow inSection:0];
    object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    //--- Show Stock Page in WebView
    url = [NSString stringWithFormat:@"http://stocks.finance.yahoo.co.jp/stocks/detail/?code="];
    codebuf = [object valueForKey:@"code"];
    url = [url stringByAppendingString:codebuf];
    placebuf = [object valueForKey:@"place"];
    url = [url stringByAppendingString:placebuf];
    
    NSURL *transUrl = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:transUrl]) {
        //[[UIApplication sharedApplication] openURL:transUrl];
        //NSURLRequest *urlReq = [NSURLRequest requestWithURL:self.transUrl];
        //[self.StockWebView loadRequest:urlReq];
    } else {
        //error
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"通信エラー" message:@"サーバーとの接続に失敗しました。" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        BoardViewController *controller;
        [controller presentViewController:alert animated:YES completion:nil];
    }
    
    //--- Search for stock price from html
    NSString *html_ = [NSString stringWithContentsOfURL:transUrl
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
    NSString *html = [html_ stringByReplacingOccurrencesOfString:@"\n"
                                                      withString:@""];
    //NSLog(@"%@", html);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    // 正規表現の中で.*?とやると最短マッチするらしい。
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"<td class=\"stoksPrice\">(.*?)</td>"
                                                                            options:0
                                                                              error:nil];
    //
    NSArray *arr = [regexp matchesInString:html
                                   options:0
                                     range:NSMakeRange(0, html.length)];
    
    for (NSTextCheckingResult *match in arr) {
        pricebuf = [html substringWithRange:[match rangeAtIndex:1]];
        //            [object setValue:pricebuf forKey:@"price"];
        //            NSLog(@"price %@", pricebuf);
    }
    //    }
    return pricebuf;
    
}

-(void)refreshPriceValueMainThread {
    NSLog(@"*** Now refreshPriceValueMainThread");
    
    NSError *error = nil;
    self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    NSLog(@"Error !: %@", [error localizedDescription]);
    NSLog(@"CoreData count = %ld", count);
    
    NSIndexPath *indexPath;
    NSManagedObject *object;
    for (int i=0; i < count; i++) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSString *price = [self refreshPriceValue:i];
        [object setValue:price forKey:@"price"];
        //[self.tempPriceMArray replaceObjectAtIndex:i withObject:price];
        NSLog(@"price %@", price);
    }
    
    // Save the context.
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

}


-(NSInteger)checkObserveVaules:(NSInteger)indexRow {
    NSLog(@"*** Now checkObserveVaules");
    
    NSError *error = nil;
    self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
    NSIndexPath *indexPath;
    NSManagedObject *object;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    NSLog(@"Error !: %@", [error localizedDescription]);
    NSLog(@"CoreData count = %ld", count);
    
    //監視値チェック
    //    for (int i=0; i < count; i++) {
    //        NSLog(@"checkObserveVaules i = %d", i);
    indexPath = [NSIndexPath indexPathForRow:indexRow inSection:0];
    object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    //画面に表示されていないセルはnilになる
    //BoardTableViewCell *cell = (BoardTableViewCell *)[self.boardTableView cellForRowAtIndexPath:indexPath];
    
    NSInteger iHitFlag = 0;
    NSString *targetString;
    //NSString *BasicPrice = cell.priceLabel.text;
    //現在値
    NSString *BasicPrice = [object valueForKey:@"price"];
    //am7:00-9:00の間、現在値がWebで”---”となるので、この場合、チェック処理を行わない。
    if (![BasicPrice isEqualToString:@"---"]) {
        //前日比、騰落率
        float priceValTemp = 0;
        float changeVal = 0;
        float changeValTemp = 0;
        float changeRate = 0;
        NSString *valTemp;
        NSString *rateTemp;
        
        NSString *setString = [NSString stringWithFormat:@"%@",BasicPrice];
        NSString *setString2 = [setString stringByReplacingOccurrencesOfString:@"," withString:@""];
        priceValTemp = [setString2 floatValue];
        
        valTemp = [[object valueForKey:@"yesterdayPrice"] description];
        setString = [NSString stringWithFormat:@"%@",valTemp];
        setString2 = [setString stringByReplacingOccurrencesOfString:@"," withString:@""];
        changeValTemp = [setString2 floatValue];
        
        changeVal = priceValTemp - changeValTemp;
        changeRate = (changeVal / changeValTemp) *100;
        
        valTemp = [NSString stringWithFormat : @"%.0f", changeVal];
        rateTemp = [NSString stringWithFormat : @"%.2f", changeRate];
        //    [object setValue:valTemp forKey:@"changeVal"];
        //    [object setValue:rateTemp forKey:@"changeRate"];
        
        if (changeVal == 0) {
            valTemp = @"0";
        } else if (changeVal > 0){
            valTemp = [@"+" stringByAppendingString:valTemp];
            rateTemp = [@"+" stringByAppendingString:rateTemp];
        } else if (changeVal < 0) {
            
        }
        //rateTemp = [rateTemp stringByAppendingString:@"%"];
        NSString *BasicChangeVal = valTemp;
        NSString *BasicchangeRate = rateTemp;
        
        //-----------------
        //cell.observeImage.image = [UIImage imageNamed:@"button_01.png"];
        if (![BasicPrice isEqualToString:@"0"]) {
            BasicPrice = [BasicPrice stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            targetString = [object valueForKey:@"observePrice1"];
            if (![targetString isEqualToString:@""]) {
                if ([BasicPrice intValue] >= [targetString intValue]) {
                    iHitFlag = 1;
                }
            }
            targetString = [object valueForKey:@"observePrice2"];
            if (![targetString isEqualToString:@""]) {
                if ([BasicPrice intValue] <= [targetString intValue]) {
                    iHitFlag = 2;
                }
            }
            
            //NSString *BasicChangeVal = cell.changeValLabel.text;
            //NSString *BasicChangeVal = [object valueForKey:@"changeVal"];
            targetString = [object valueForKey:@"observeChangeVal1"];
            if (![targetString isEqualToString:@""]) {
                if ([BasicChangeVal intValue] >= [targetString intValue]) {
                    iHitFlag = 3;
                }
            }
            targetString = [object valueForKey:@"observeChangeVal2"];
            if (![targetString isEqualToString:@""]) {
                if ([BasicChangeVal intValue] <= [targetString intValue]) {
                    iHitFlag = 4;
                }
            }
            
            //NSString *BasicchangeRate = cell.changeRateLabel.text;
            //BasicchangeRate = [BasicchangeRate stringByReplacingOccurrencesOfString:@"%" withString:@""];
            targetString = [object valueForKey:@"observeChangeRate1"];
            if (![targetString isEqualToString:@""]) {
                if ([BasicchangeRate intValue] >= [targetString intValue]) {
                    iHitFlag = 5;
                }
            }
            targetString = [object valueForKey:@"observeChangeRate2"];
            if (![targetString isEqualToString:@""]) {
                if ([BasicchangeRate intValue] <= [targetString intValue]) {
                    iHitFlag = 6;
                }
            }
        }
    }
    return iHitFlag;
}

-(void)checkObserveVaulesMainThread {
    NSLog(@"*** Now checkObserveVaulesMainThread");
    
    NSError *error = nil;
    self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    NSLog(@"Error !: %@", [error localizedDescription]);
    NSLog(@"CoreData count = %ld", count);
    
    NSIndexPath *indexPath;
    NSManagedObject *object;
    for (int i=0; i < count; i++) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSInteger observeFlag = [self checkObserveVaules:i];
        
        if (observeFlag != 0) {
            //監視値　イメージ
            [object setValue:@"3" forKey:@"observeImage"];
            //[self.tempObserveImageMArray replaceObjectAtIndex:i withObject:@"3"];
            
            //NSString *noticeDate = [object valueForKey:@"noticeTime"];
            //if ([noticeDate isEqual:[NSNull null]]) {
            //if (noticeDate == nil) {
            //if ([cell.noticeTimeLabel.text isEqualToString:@""]) {
            NSString *noticeStr = [object valueForKey:@"noticeTime"];
            if ([noticeStr isEqualToString:@""]) {
                //--- Local Notification
                //時間
                NSDate* now = [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone systemTimeZone] secondsFromGMT]];
                //[object setValue:now forKey:@"noticeTime"];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [formatter setDateFormat:@"MM/dd HH:mm:ss"];
                NSString *noticeTime = [formatter stringFromDate:now];
                [object setValue:noticeTime forKey:@"noticeTime"];
                //[self.tempNoticeTimeMArray replaceObjectAtIndex:i withObject:noticeTime];
                
                //銘柄名
                NSString *codePlaceName;
                NSString *code = [[object valueForKey:@"code"] description];
                NSString *place = [[object valueForKey:@"place"] description];
                NSString *name = [[object valueForKey:@"name"] description];
                
                codePlaceName = [code stringByAppendingString:place];
                codePlaceName = [codePlaceName stringByAppendingString:@" "];
                codePlaceName = [codePlaceName stringByAppendingString:name];
                
                [self createLocalNotification:codePlaceName :noticeTime];
                NSLog(@"Condition true. Notification");
            }
        }
    }
    
    // Save the context.
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
}

#pragma mark - Notification

-(void)resisterLocalNotification {
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notif {
    
    application.applicationIconBadgeNumber = 0;
//    NSString *infoName = [notif.userInfo objectForKey:@"name"];
//    NSString *infoTime = [notif.userInfo objectForKey:@"time"];
//    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"通知"
//                                                                   message:[NSString stringWithFormat:@"%@\n株価が監視値になりました。\n%@",infoName ,infoTime]
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
//    BoardViewController *controller;
//    [controller presentViewController:alert animated:YES completion:nil];
}

- (void)createLocalNotification:(NSString *)name :(NSString *)time {
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil) {
        return;
    }
    
    localNotif.fireDate = [NSDate  dateWithTimeIntervalSinceNow:15.0];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    //localNotif.repeatInterval = NSCalendarUnitMinute;
    //localNotif.alertTitle = name;
    localNotif.alertBody = [NSString stringWithFormat:@"%@\n株価が監視値になりました。\n%@",name ,time];
    //localNotif.alertAction = NSLocalizedString(@"View Details", nil);aaaaa
    localNotif.alertAction = @"Open";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber++;
    //NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"test" forKey:@"key1"];
    NSDictionary *infoDict = @{name :@"name",
                               time :@"time"};
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

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
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        NSError *error = nil;
        //NSURL *transUrl = [NSURL URLWithString:url];
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
    } else {
        //error
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"通信エラー" message:@"サーバーとの接続に失敗しました。" preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
//        BoardViewController *controller;
//        [controller presentViewController:alert animated:YES completion:nil];
        NSLog(@"サーバーとの接続に失敗しました。");
   }
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
    //最後の1行は空データで不要なので削除
    [self.stocksArray removeObjectsInRange:NSMakeRange(([self.stocksArray count]-1), 1)];
    NSLog(@"self.stocksArray count: %ld", [self.stocksArray count]);    // 行数

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

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    NSLog(@"*** Now fetchedResultsController");
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rowPosition" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

@end
