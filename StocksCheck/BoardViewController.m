//
//  BoardViewController.m
//  StocksCheck
//
//  Created by SASAKIAI on 2016/03/05.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

#import "BoardViewController.h"
#import "ObservTableViewController.h"
#import "ResistViewController.h"

@interface BoardViewController ()

@end

@implementation BoardViewController

- (void)viewDidLoad {
    //    NSLog(@"*** Now viewDidLoad");
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"リスト";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //    self.navigationItem.rightBarButtonItem = addButton;
    
    //self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    //self.resistViewController = (ResistViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    //initialize variables
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.IsBackResistView = FALSE;
    appDelegate.addedCode = @"";
    
    self.dateMessageLabelStr = @"";
    self.nikkeiLabelStr = @"";
    
    //initialize autoRefresh array
    self.tempPriceMArray = [NSMutableArray array];
    self.tempObserveImageMArray = [NSMutableArray array];
    self.tempNoticeTimeMArray = [NSMutableArray array];
    
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];

    //タイマー作成 viewdidLoadで
    [self prepareAutoRefresh];
    
    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

    //Change the host name here to change the server you want to monitor.
//    NSString *remoteHostName = @"www.apple.com";
//    NSString *remoteHostName = @"http://stocks.finance.yahoo.co.jp/stocks";
    
    self.IsDispatchSourceTimerExcute = NO;
    self.inetworkStatusFlag = 0;
    self.wifiStatusFlag = 0;
    self.refreshingFlag = 0;
//    self.inetRetryCount = 0;
//    self.wifiRetryCount = 0;
//    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
//    [self.hostReachability startNotifier];
//    [self updateInterfaceWithReachability:self.hostReachability];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];
    [self updateInterfaceWithReachability:self.wifiReachability];

}

- (void)viewWillAppear:(BOOL)animated {
    //    NSLog(@"*** Now viewWillAppear");
    //self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;  ///NG
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.IsBackResistView == TRUE) {
        
        //NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
        //NSIndexPath *indexPath;
        //NSManagedObject *object;
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
        NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
        //        NSLog(@"Error !: %@", [error localizedDescription]);
        //        NSLog(@"CoreData count = %ld", count);
        
        //        for (int j=0; j < count; j++) {
        //            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:0];
        //            NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        //            NSLog(@"object rowPosition[%d] = %@", j ,[object valueForKey:@"rowPosition"]);
        //        }
        
        //rowPosition = count-1 の object(最後に追加したもの)を検索
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
        
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rowPosition == %@", [NSString stringWithFormat:@"%ld",(count-1)]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rowPosition == %d", (count-1)];
        [request setPredicate:predicate];
        NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (array != nil) {
            if ([appDelegate.addedCode isEqualToString:@""]) {
                // Delete the Last Object
                //[context deleteObject:object];
                for (NSManagedObject *object in array) {
                    [self.managedObjectContext deleteObject:object];
                }
            } else {
                //indexPath = [NSIndexPath indexPathForRow:count-1 inSection:0];
                //object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
                //[object setValue:appDelegate.addedCode forKey:@"code"];
                for (NSManagedObject *object in array) {
                    [object setValue:appDelegate.addedCode forKey:@"code"];
                }
            }
        } else {
            NSLog(@"fetch result is 0");
        }
        
        //        for (int j=0; j < count; j++) {
        //            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:0];
        //            NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        //            NSLog(@"object rowPosition[%d] = %@", j ,[object valueForKey:@"rowPosition"]);
        //        }
        
        // Save the context.
        //indexPath = [NSIndexPath indexPathForRow:count-1 inSection:0];
        if (![self.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        appDelegate.IsBackResistView = FALSE;
        appDelegate.addedCode = @"";
        
        //---reload table view
        [self.boardTableView reloadData];
        
        [self createTemporaryArrays];
    }
    
    [self refreshHedderLabelMainThread];
    [self initializeCoreData];
    [self checkObserveVaulesMainThread];
    [self createTemporaryArrays];
    
}

//-(void)viewWillDisappear:(BOOL)animated {
//    NSLog(@"*** Now viewWillDisappear");
//}

- (void)didReceiveMemoryWarning {
    //    NSLog(@"*** Now didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject {
    //    NSLog(@"*** Now insertNewObject");
    self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:self.managedObjectContext];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    //[newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    NSError *error = nil;
    NSString* code = @"---";
    [newManagedObject setValue:code forKey:@"code"];
    NSString* place = @"---";
    [newManagedObject setValue:place forKey:@"place"];
    [newManagedObject setValue:@"0" forKey:@"price"];
    //    [newManagedObject setValue:@"0" forKey:@"changeVal"];   //NOT Use
    //    [newManagedObject setValue:@"0" forKey:@"changeRate"];  //NOT Use
    [newManagedObject setValue:@"0" forKey:@"yesterdayPrice"];
    [newManagedObject setValue:@"---" forKey:@"name"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    //[newManagedObject setValue:[NSString stringWithFormat:@"%ld", count-1] forKey:@"rowPosition"];
    [newManagedObject setValue:[NSNumber numberWithInteger:(count-1)] forKey:@"rowPosition"];
    NSDate* now = [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone systemTimeZone] secondsFromGMT]];
    [newManagedObject setValue:now forKey:@"timeStamp"];
    [newManagedObject setValue:@"" forKey:@"noticeTime"];
    
    [newManagedObject setValue:@"" forKey:@"observePrice1"];
    [newManagedObject setValue:@"" forKey:@"observePrice2"];
    [newManagedObject setValue:@"" forKey:@"observeChangeVal1"];
    [newManagedObject setValue:@"" forKey:@"observeChangeVal2"];
    [newManagedObject setValue:@"" forKey:@"observeChangeRate1"];
    [newManagedObject setValue:@"" forKey:@"observeChangeRate2"];
    [newManagedObject setValue:@"1" forKey:@"observeImage"];
    
    // Save the context.
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self createTemporaryArrays];
}


-(void)initializeCoreData {
    //    NSLog(@"*** Now initializeCoreData");
    
    NSString *url;
    NSError *error = nil;
    
    self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
    NSIndexPath *indexPath;
    NSManagedObject *object;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
    //NSFetchRequest *fetchRequest;
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    //    NSLog(@"Error !: %@", [error localizedDescription]);
    //    NSLog(@"CoreData count = %ld", count);
    
    for (int i=0; i < count; i++) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSString *codebuf;
        NSString *placebuf;
        
        //code
        codebuf = [object valueForKey:@"code"];
        //        NSLog(@"code %@", codebuf);
        
        //place
        placebuf = [object valueForKey:@"place"];
        //        NSLog(@"place %@", placebuf);
        
        //--- Show Stock Page in WebView
        //http://stocks.finance.yahoo.co.jp/stocks/detail/?code=9984.T
        url = [NSString stringWithFormat:@"http://stocks.finance.yahoo.co.jp/stocks/detail/?code="];
        url = [url stringByAppendingString:codebuf];
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
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        NSString *html_ = [NSString stringWithContentsOfURL:transUrl
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
        NSString *html = [html_ stringByReplacingOccurrencesOfString:@"\n"
                                                          withString:@""];
        //NSLog(@"%@", html);
        if (html != nil) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            
            //--- Search for stockName from html　銘柄名
            // 正規表現の中で.*?とやると最短マッチする
            NSError *error = nil;
            NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"<th class=\"symbol\"><h1>(.*?)</h1></th>"
                                                                                    options:0
                                                                                      error:&error];
            NSArray *arr;
            if (regexp != nil) {
                if (error == nil) {
                    arr = [regexp matchesInString:html
                                          options:0
                                            range:NSMakeRange(0, html.length)];
                    
                    for (NSTextCheckingResult *match in arr) {
                        NSString *codeNamebuf = [html substringWithRange:[match rangeAtIndex:1]];
                        [object setValue:codeNamebuf forKey:@"name"];
                        //            NSLog(@"name %@", codeNamebuf);
                    }
                } else {
                    //nothing to do
                }
            }
            
            //--- Search for yesterday stock price from html 前日終値
            // 正規表現の中で.*?とやると最短マッチする
            //<dl class="tseDtlDelay"><dd class="ymuiEditLink mar0"><strong>5,585</strong><span class="date yjSt">（02/26）</span></dd><dt class="title">前日終値
            error = nil;
            regexp = [NSRegularExpression regularExpressionWithPattern:@"<dl class=\"tseDtlDelay\"><dd class=\"ymuiEditLink mar0\"><strong>(.*)</strong><span class=\"date yjSt\">(.*)</span></dd><dt class=\"title\">前日終値"
                                                               options:0
                                                                 error:&error];
            if (regexp != nil) {
                if (error == nil) {
                    arr = [regexp matchesInString:html
                                          options:0
                                            range:NSMakeRange(0, html.length)];
                    
                    for (NSTextCheckingResult *match in arr) {
                        NSString *yesterdayPricebuf = [html substringWithRange:[match rangeAtIndex:1]];
                        [object setValue:yesterdayPricebuf forKey:@"yesterdayPrice"];
                        //            NSLog(@"yesterdayPricebuf %@", yesterdayPricebuf);
                    }
                } else {
                    //nothing to do
                }
            }
            //--- Search for Now stock price from html 現在値
            // 正規表現の中で.*?とやると最短マッチする
            error = nil;
            regexp = [NSRegularExpression regularExpressionWithPattern:@"<td class=\"stoksPrice\">(.*?)</td>"
                                                               options:0
                                                                 error:&error];
            
            if (regexp != nil) {
                if (error == nil) {
                    arr = [regexp matchesInString:html
                                          options:0
                                            range:NSMakeRange(0, html.length)];
                    
                    for (NSTextCheckingResult *match in arr) {
                        NSString *pricebuf = [html substringWithRange:[match rangeAtIndex:1]];
                        [object setValue:pricebuf forKey:@"price"];
                        //            NSLog(@"price %@", pricebuf);
                    }
                } else {
                    //nothing to do
                }
            }
            //監視値 イメージ
            //[object setValue:@"1" forKey:@"observeImage"];
            
            // Save the context.
            if (![self.managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        } else {
            //nothing to do
        }
    }
    
    //---reload table view
    [self.boardTableView reloadData];
}

-(void)copyTemporaryArraysToCoredata {
    //    NSLog(@"*** Now copyTemporaryArraysToCoredata");
    
    self.dateMessageLabel.text = self.dateMessageLabelStr;
    self.nikkeiLabel.text = self.nikkeiLabelStr;
    
    NSError *error = nil;
    self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    //    NSLog(@"Error !: %@", [error localizedDescription]);
    //    NSLog(@"CoreData count = %ld", count);
    
    NSIndexPath *indexPath;
    NSManagedObject *object;
    for (int i=0; i < count; i++) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        NSString *price = [self.tempPriceMArray objectAtIndex:i];
        [object setValue:price forKey:@"price"];
        //        NSLog(@"price %@", price);
        
        NSString *observeImage = [self.tempObserveImageMArray objectAtIndex:i];
        [object setValue:observeImage forKey:@"observeImage"];
        //        NSLog(@"observeImage %@", observeImage);
        
        NSString *noticeTime = [self.tempNoticeTimeMArray objectAtIndex:i];
        [object setValue:noticeTime forKey:@"noticeTime"];
        //        NSLog(@"noticeTime %@", noticeTime);
    }
}

-(void)createTemporaryArrays {
    //    NSLog(@"*** Now createTemporaryArrays");
    
    NSError *error = nil;
    self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    //    NSLog(@"Error !: %@", [error localizedDescription]);
    //    NSLog(@"CoreData count = %ld", count);
    
    NSIndexPath *indexPath;
    NSManagedObject *object;
    [self.tempPriceMArray removeAllObjects];
    [self.tempObserveImageMArray removeAllObjects];
    [self.tempNoticeTimeMArray removeAllObjects];
    for (int i=0; i < count; i++) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        NSString *price = [object valueForKey:@"price"];
        [self.tempPriceMArray addObject:price];
        //        NSLog(@"price %@", price);
        
        NSString *observeImage = [object valueForKey:@"observeImage"];
        [self.tempObserveImageMArray addObject:observeImage];
        //        NSLog(@"observeImage %@", observeImage);
        
        NSString *noticeTime = [object valueForKey:@"noticeTime"];
        [self.tempNoticeTimeMArray addObject:noticeTime];
        //        NSLog(@"noticeTime %@", noticeTime);
    }
}

- (IBAction)pushRefreshBarItemButton:(id)sender {
    //    NSLog(@"*** Now pushRefreshBarItemButton");
//    [self performSelector:@selector(excuteIndicatorStart) withObject:nil];
    
    self.refreshBarItemButton.enabled = NO;
    self.addBarItemButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = nil;
    self.refreshingFlag = 1;
    
    //load image
    if (self.inetworkStatusFlag == 2 && self.wifiStatusFlag == 2) {
        self.remoteHostImageView.image = [UIImage imageNamed:@"stop_01.png"];
    } else if (self.wifiStatusFlag == 1) {
        self.remoteHostImageView.image = [UIImage imageNamed:@"Airport_01.png"];
    } else {
        self.remoteHostImageView.image = [UIImage imageNamed:@"WWAN_01.png"];
    }
    
    [self.view setNeedsDisplay];
    
    [self.refreshIndicator startAnimating];
//    [self.refreshIndicator setNeedsDisplay];
    
//    // 通知を作成する for Activity Indicator
//    NSNotification *n = [NSNotification notificationWithName:@"Tuchi" object:self];
//    // 通知実行
//    [[NSNotificationCenter defaultCenter] postNotification:n];

    [NSTimer scheduledTimerWithTimeInterval:0.1f
                                     target:self
                                   selector:@selector(excuteRefreshProcesses:)
                                   userInfo:nil
                                    repeats:NO];
    
}

-(void)excuteRefreshProcesses:(NSTimer*)timer {

//    dispatch_queue_t global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
//    dispatch_async(global_queue, ^{
//    });
    
    [self refreshHedderLabelMainThread];
    [self refreshPriceValueMainThread];
    [self checkObserveVaulesMainThread];
    
    self.refreshBarItemButton.enabled = YES;
    self.addBarItemButton.enabled = YES;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.refreshingFlag = 0;
    
    //load image
    if (self.inetworkStatusFlag == 2 && self.wifiStatusFlag == 2) {
        self.remoteHostImageView.image = [UIImage imageNamed:@"stop_01.png"];
    } else if (self.wifiStatusFlag == 1) {
        self.remoteHostImageView.image = [UIImage imageNamed:@"Airport_02.png"];
    } else {
        self.remoteHostImageView.image = [UIImage imageNamed:@"WWAN_02.png"];
    }
    
    [self.view setNeedsDisplay];

    [self.refreshIndicator stopAnimating];
    
}

- (IBAction)changeRefreshSwitch:(id)sender {
    //    NSLog(@"*** Now changeRefreshSwitch");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (self.refreshSwitch.on == YES) {
        //なぜか２回呼ばれるため回避判定処理
        if (self.IsDispatchSourceTimerExcute == NO) {
            //ON
            self.refreshBarItemButton.enabled = NO;
            self.addBarItemButton.enabled = NO;
            self.navigationItem.rightBarButtonItem = nil;
            [self createTemporaryArrays];
            
            //load image
            if (self.inetworkStatusFlag == 2 && self.wifiStatusFlag == 2) {
                self.remoteHostImageView.image = [UIImage imageNamed:@"stop_01.png"];
            } else if (self.wifiStatusFlag == 1) {
                self.remoteHostImageView.image = [UIImage imageNamed:@"Airport_01.png"];
            } else {
                self.remoteHostImageView.image = [UIImage imageNamed:@"WWAN_01.png"];
            }
            
            //タイマー作成 viewdidLoadで
            //        [self prepareAutoRefresh];
            
            // タイマー開始
            dispatch_resume(appDelegate.BackgraundTimerSource);
            dispatch_resume(appDelegate.mainTimerSource);

            self.IsDispatchSourceTimerExcute = YES;
        }
    } else {
//        //なぜか２回呼ばれるため回避判定処理
        if (self.IsDispatchSourceTimerExcute == YES) {
            //OFF
            self.refreshBarItemButton.enabled = YES;
            self.addBarItemButton.enabled = YES;
            self.navigationItem.rightBarButtonItem = self.editButtonItem;
            [self copyTemporaryArraysToCoredata];
            //        // タイマ一時停止
            //        if(self.timerSource){
            //            dispatch_suspend(self.timerSource);
            //        }
            // タイマ一時停止
            if(appDelegate.BackgraundTimerSource){
                dispatch_suspend(appDelegate.BackgraundTimerSource);
                //                dispatch_source_cancel(appDelegate.BackgraundTimerSource);
            }
            if(appDelegate.mainTimerSource){
                dispatch_suspend(appDelegate.mainTimerSource);
                //                dispatch_source_cancel(appDelegate.mainTimerSource);
            }
            self.IsDispatchSourceTimerExcute = NO;
            
            //load image
            if (self.inetworkStatusFlag == 2 && self.wifiStatusFlag == 2) {
                self.remoteHostImageView.image = [UIImage imageNamed:@"stop_01.png"];
            } else if (self.wifiStatusFlag == 1) {
                self.remoteHostImageView.image = [UIImage imageNamed:@"Airport_02.png"];
            } else {
                self.remoteHostImageView.image = [UIImage imageNamed:@"WWAN_02.png"];
            }
            
        }

    }
    
//    [self.view setNeedsDisplay];
    //---reload table view necessary
    [self.boardTableView reloadData];
}


-(void)prepareAutoRefresh {
    //    NSLog(@"*** Now prepareAutoRefresh");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // Queue作成
    dispatch_queue_t global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    
    // タイマーソース作成
//    if(appDelegate.BackgraundTimerSource == nil){
        appDelegate.BackgraundTimerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, global_queue);
//    }
    
//    if(appDelegate.mainTimerSource == nil){
        appDelegate.mainTimerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, main_queue);
//    }
    //    self.timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    //    self.timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    //self.timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    //dispatch_retain(_timerSource);
    
    dispatch_async(global_queue, ^{
        // Background operations
        // タイマーキャンセルハンドラ設定
        dispatch_source_set_cancel_handler(appDelegate.BackgraundTimerSource, ^{
            if(appDelegate.BackgraundTimerSource){
//                dispatch_release(appDelegate.BackgraundTimerSource); // releaseを忘れずに
                appDelegate.BackgraundTimerSource = nil;
            }
        });
        // タイマーイベントハンドラ
        dispatch_source_set_event_handler(appDelegate.BackgraundTimerSource, ^{
            // ここに定期的に行う処理を記述
            //            NSLog(@"*** Now global_queue in TimerEventHandler");
            [self autoRefreshByBackgraundTimer];
        });
        // インターバル等を設定
        dispatch_source_set_timer(appDelegate.BackgraundTimerSource,
                                  dispatch_time(DISPATCH_TIME_NOW, 0), NSEC_PER_SEC * 3, NSEC_PER_SEC / 2); // 直後に開始、3秒間隔で 0.5秒の揺らぎを許可
    });
    
    dispatch_async(main_queue, ^{  // async? or sync?
        //dispatch_async(main_queue, ^{
        // Main Thread
        // タイマーキャンセルハンドラ設定
        dispatch_source_set_cancel_handler(appDelegate.mainTimerSource, ^{
            if(appDelegate.mainTimerSource){
                //dispatch_release(_timerSource); // releaseを忘れずに
                appDelegate.mainTimerSource = nil;
            }
        });
        // タイマーイベントハンドラ
        dispatch_source_set_event_handler(appDelegate.mainTimerSource, ^{
            // ここに定期的に行う処理を記述
            //            NSLog(@"*** Now global_queue in TimerEventHandler");
            [self copyTemporaryArraysToCoredata];
        });
        // インターバル等を設定
        dispatch_source_set_timer(appDelegate.mainTimerSource,
                                  dispatch_time(DISPATCH_TIME_NOW, 0), NSEC_PER_SEC * 1, NSEC_PER_SEC / 2); // 直後に開始、1秒間隔で 0.5秒の揺らぎを許可
        
    });
    
}

//-(void)prepareAutoRefresh {
//    NSLog(@"*** Now prepareAutoRefresh");
//    if (self.autoRefershTimer == nil || (![self.autoRefershTimer isValid])) {
//        self.autoRefershTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                                                 target:self
//                                                               selector:@selector(autoRefreshByTimer)
//                                                               userInfo:nil
//                                                                repeats:YES];
//    }
//    //[[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
//}

-(void)autoRefreshByBackgraundTimer {
    //    NSLog(@"*** Now autoRefreshByBackgraundTimer");
    [self refreshHedderLabelBackgroundThread];
    [self refreshPriceValueBackgroundThread];
    [self checkObserveVaulesBackgroundThread];
}

//-(void)autoRefreshByMainThreadTimer {
//    NSLog(@"*** Now autoRefreshByMainThreadTimer");
//    [self refreshHedderLabelMainThread];
//    [self refreshPriceValueMainThread];
//    [self checkObserveVaulesMainThread];
//}

- (void)createLocalNotification:(NSString *)name :(NSString *)time {
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil) {
        return;
    }
    
    localNotif.fireDate = [NSDate  dateWithTimeIntervalSinceNow:1.0];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    //localNotif.repeatInterval = NSCalendarUnitMinute;
    //localNotif.alertTitle = name;
    localNotif.alertBody = [NSString stringWithFormat:@"%@\n株価が監視値になりました。\n%@",name ,time];
    //localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    localNotif.alertAction = @"Open";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber++;
    //NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"test" forKey:@"key1"];
    NSDictionary *infoDict = @{name :@"name",
                               time :@"time"};
    localNotif.userInfo = infoDict;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:name
                                                                   message:[NSString stringWithFormat:@"株価が監視値になりました。\n%@",time]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

-(NSInteger)checkObserveVaules:(NSInteger)indexRow {
    //    NSLog(@"*** Now checkObserveVaules");
    
    //    NSError *error = nil;
    //    self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
    //    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
    //    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
    //    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    //    NSLog(@"Error !: %@", [error localizedDescription]);
    //    NSLog(@"CoreData count = %ld", count);
    
    //監視値チェック
    NSIndexPath *indexPath;
    NSManagedObject *object;
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
    //    NSLog(@"*** Now checkObserveVaulesMainThread");
    
    NSError *error = nil;
    self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    //    NSLog(@"Error !: %@", [error localizedDescription]);
    //    NSLog(@"CoreData count = %ld", count);
    
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
                //                NSLog(@"Condition true. Notification");
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
    
    //---reload table view
    [self.boardTableView reloadData];
    
}

-(void)checkObserveVaulesBackgroundThread {
    //    NSLog(@"*** Now checkObserveVaulesBackgroundThread");
    
    NSError *error = nil;
    self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    //    NSLog(@"Error !: %@", [error localizedDescription]);
    //    NSLog(@"CoreData count = %ld", count);
    
    NSIndexPath *indexPath;
    NSManagedObject *object;
    for (int i=0; i < count; i++) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSInteger observeFlag = [self checkObserveVaules:i];
        
        if (observeFlag != 0) {
            //監視値　イメージ
            //タイミングによってArrayに要素が全てない場合エラーとなるのを回避
            if (self.tempObserveImageMArray != nil) {
                if ( i < [self.tempObserveImageMArray count]) {
                    //[object setValue:@"3" forKey:@"observeImage"];
                    [self.tempObserveImageMArray replaceObjectAtIndex:i withObject:@"3"];
                }
            }
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
                //タイミングによってArrayに要素が全てない場合エラーとなるのを回避
                if (self.tempNoticeTimeMArray != nil) {
                    if ( i < [self.tempNoticeTimeMArray count]) {
                        //[object setValue:noticeTime forKey:@"noticeTime"];
                        [self.tempNoticeTimeMArray replaceObjectAtIndex:i withObject:noticeTime];
                    }
                }
                //銘柄名
                NSString *codePlaceName;
                NSString *code = [[object valueForKey:@"code"] description];
                NSString *place = [[object valueForKey:@"place"] description];
                NSString *name = [[object valueForKey:@"name"] description];
                
                codePlaceName = [code stringByAppendingString:place];
                codePlaceName = [codePlaceName stringByAppendingString:@" "];
                codePlaceName = [codePlaceName stringByAppendingString:name];
                //MainThreadで実施
                [self createLocalNotification:codePlaceName :noticeTime];
                //                NSLog(@"Condition true. Notification");
            }
        }
    }
}


-(NSString *)refreshPriceValue:(NSInteger)indexRow {
    //    NSLog(@"*** Now refreshPriceValue");
    
    NSString *url;
    NSString *codebuf;
    NSString *placebuf;
    NSString *pricebuf;
    NSIndexPath *indexPath;
    NSManagedObject *object;
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
    if (html != nil) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        // 正規表現の中で.*?とやると最短マッチする。
        NSError *error = nil;
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"<td class=\"stoksPrice\">(.*?)</td>"
                                                                                options:0
                                                                                  error:&error];
        if (regexp != nil) {
            if (error == nil) {
                NSArray *arr = [regexp matchesInString:html
                                               options:0
                                                 range:NSMakeRange(0, html.length)];
                
                for (NSTextCheckingResult *match in arr) {
                    pricebuf = [html substringWithRange:[match rangeAtIndex:1]];
                    //            [object setValue:pricebuf forKey:@"price"];
                    //            NSLog(@"price %@", pricebuf);
                }
            } else {
                pricebuf = @"error";
            }
        } else {
            pricebuf = @"error";
        }
    } else {
        pricebuf = @"error";
    }
    return pricebuf;
    
}

-(void)refreshPriceValueMainThread {
    //    NSLog(@"*** Now refreshPriceValueMainThread");
    
    NSError *error = nil;
    self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    //    NSLog(@"Error !: %@", [error localizedDescription]);
    //    NSLog(@"CoreData count = %ld", count);
    
    NSIndexPath *indexPath;
    NSManagedObject *object;
    for (int i=0; i < count; i++) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSString *price = [self refreshPriceValue:i];
        if (![price isEqualToString:@"error"]) {
            [object setValue:price forKey:@"price"];
        } else {
            //nothing to do
        }
        //[self.tempPriceMArray replaceObjectAtIndex:i withObject:price];
        //        NSLog(@"price %@", price);
    }
    
    // Save the context.
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    //---reload table view
    [self.boardTableView reloadData];
    
}


-(void)refreshPriceValueBackgroundThread {
    //    NSLog(@"*** Now refreshPriceValueBackgroundThread");
    
    NSError *error = nil;
    self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    //    NSLog(@"Error !: %@", [error localizedDescription]);
    //    NSLog(@"CoreData count = %ld", count);
    
    NSIndexPath *indexPath;
    //NSManagedObject *object;
    for (int i=0; i < count; i++) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        //object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSString *price = [self refreshPriceValue:i];
        if (price != nil) {
            if (![price isEqualToString:@"error"]) {
                //タイミングによってArrayに要素が全てない場合エラーとなるのを回避
                if (self.tempPriceMArray != nil) {
                    if ( i < [self.tempPriceMArray count]) {
                        [self.tempPriceMArray replaceObjectAtIndex:i withObject:price];
                        //        NSLog(@"price %@", price);
                    }
                }
            } else {
                //nothing to do
            }
        }
    }
}

-(NSString *)refreshHadderDateMessageLabel {
    //    NSLog(@"*** Now refreshHadderDateMessageLabel");
    NSString *url;
    url = [NSString stringWithFormat:@"http://stocks.finance.yahoo.co.jp/stocks/detail/?code=998407.O"];
    
    NSURL *transUrl = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:transUrl]) {
        //[[UIApplication sharedApplication] openURL:transUrl];
        //NSURLRequest *urlReq = [NSURLRequest requestWithURL:self.transUrl];
        //[self.StockWebView loadRequest:urlReq];
    } else {
        //error
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"通信エラー" message:@"サーバーとの接続に失敗しました。" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    //--- Search for stock price from html
    NSString *html_ = [NSString stringWithContentsOfURL:transUrl
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
    NSString *html = [html_ stringByReplacingOccurrencesOfString:@"\n"
                                                      withString:@""];
    NSString *strbuf;
    if (html != nil) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        
        // 正規表現の中で.*?とやると最短マッチする
        //<p>現在の日時：<strong>3月 9日 23:31</strong> -- 日本の証券市場は終了しました。</p></div>
        //@"<td class=\"stoksPrice\">(.*?)</td>"
        //nowtime and Message
        NSError *error = nil;
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"<p>現在の日時：<strong>(.*?)月 (.*?)日 (.*?):(.*?)</strong>(.*?)</p>"
                                                                                options:0
                                                                                  error:&error];
        if (regexp != nil) {
            if (error == nil) {
                //
                NSArray *arr = [regexp matchesInString:html
                                               options:0
                                                 range:NSMakeRange(0, html.length)];
                
                for (NSTextCheckingResult *match in arr) {
                    //        NSString *strbuf1 = [html substringWithRange:[match rangeAtIndex:1]];
                    //        NSString *strbuf2 = [html substringWithRange:[match rangeAtIndex:2]];
                    //        NSString *strbuf3 = [html substringWithRange:[match rangeAtIndex:3]];
                    //        NSString *strbuf4 = [html substringWithRange:[match rangeAtIndex:4]];
                    //        NSString *strbuf5 = [html substringWithRange:[match rangeAtIndex:5]];
                    strbuf = [html substringWithRange:[match rangeAtIndex:5]];
                }
                strbuf = [strbuf substringFromIndex:3];
            } else {
                strbuf = @"***";
            }
        } else {
            strbuf = @"***";
        }
    } else {
        strbuf = @"***";
    }
    return strbuf;
}

-(NSString *)refreshHedderNikkeiLabel {
    //    NSLog(@"*** Now refreshHedderNikkeiLabel");
    NSString *url;
    url = [NSString stringWithFormat:@"http://stocks.finance.yahoo.co.jp/stocks/detail/?code=998407.O"];
    
    NSURL *transUrl = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:transUrl]) {
        //[[UIApplication sharedApplication] openURL:transUrl];
        //NSURLRequest *urlReq = [NSURLRequest requestWithURL:self.transUrl];
        //[self.StockWebView loadRequest:urlReq];
    } else {
        //error
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"通信エラー" message:@"サーバーとの接続に失敗しました。" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    //--- Search for stock price from html
    NSString *html_ = [NSString stringWithContentsOfURL:transUrl
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
    NSString *html = [html_ stringByReplacingOccurrencesOfString:@"\n"
                                                      withString:@""];
    
    NSString *strNikkeiPrice;
    NSString *strChange;
    if (html != nil) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        
        // 正規表現の中で.*?とやると最短マッチする
        //Nikkei average
        NSError *error = nil;
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"<td class=\"stoksPrice\">(.*?)</td>"
                                                                                options:0
                                                                                  error:&error];
        NSArray *arr;
        if (regexp != nil) {
            if (error == nil) {
                arr = [regexp matchesInString:html
                                      options:0
                                        range:NSMakeRange(0, html.length)];
                for (NSTextCheckingResult *match in arr) {
                    strNikkeiPrice = [html substringWithRange:[match rangeAtIndex:1]];
                }
            } else {
                strNikkeiPrice = @"***";
            }
        } else {
            strNikkeiPrice = @"***";
        }
        
        //changeValue and changeRate
        //<td class="change"><span class="yjSt">前日比</span><span class="icoDownRed yjMSt">-140.95（-0.84%）</span></td>
        error = nil;
        regexp = [NSRegularExpression regularExpressionWithPattern:@"<td class=\"change\"><span class=\"yjSt\">前日比</span><span class=\"(.*?)\">(.*?)</span></td>"
                                                           options:0
                                                             error:&error];
        //
        if (regexp != nil) {
            if (error == nil) {
                arr = [regexp matchesInString:html
                                      options:0
                                        range:NSMakeRange(0, html.length)];
                
                for (NSTextCheckingResult *match in arr) {
                    strChange = [html substringWithRange:[match rangeAtIndex:2]];
                }
            } else {
                strChange = @"***";
            }
        } else {
            strChange = @"***";
        }
    } else {
        strNikkeiPrice = @"***";
        strChange = @"***";
    }
    NSString *strbuf = [NSString stringWithFormat:@"日経平均:%@    %@" ,strNikkeiPrice ,strChange];
    return strbuf;
}

-(void)refreshHedderLabelMainThread {
    //    NSLog(@"*** Now refreshHedderLabelMainThread");
    NSString *dateMessage;
    if ([self.dateMessageLabelStr isEqualToString:@""]) {
        dateMessage = [self refreshHadderDateMessageLabel];
    } else {
        dateMessage = self.dateMessageLabelStr;
    }
    self.dateMessageLabel.text = dateMessage;
    
    NSString *nikkei;
    if ([self.nikkeiLabelStr isEqualToString:@""]) {
        nikkei = [self refreshHedderNikkeiLabel];
    } else {
        nikkei = self.nikkeiLabelStr;
    }
    self.nikkeiLabel.text = nikkei;
}

-(void)refreshHedderLabelBackgroundThread {
    //    NSLog(@"*** Now refreshHedderLabelBackgroundThread");
    NSString *dateMessage = [self refreshHadderDateMessageLabel];
    self.dateMessageLabelStr = dateMessage;
    
    NSString *nikkei = [self refreshHedderNikkeiLabel];
    self.nikkeiLabelStr = nikkei;
}


#pragma mark - Navigation Controller

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    //    NSLog(@"*** Now setEditing");
    [super setEditing:editing animated:animated];
    [self.boardTableView setEditing:editing animated:YES];

    //desable add button
    if (editing) {
        self.addBarItemButton.enabled = NO;
        self.refreshBarItemButton.enabled = NO;
        self.refreshSwitch.enabled = NO;
    } else {
        self.addBarItemButton.enabled = YES;
        self.refreshBarItemButton.enabled = YES;
        self.refreshSwitch.enabled = YES;
    }
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //    NSLog(@"*** Now prepareForSegue");
    NSIndexPath *indexPath;
    NSManagedObject *object;
    NSError *error = nil;
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        indexPath = [self.boardTableView indexPathForSelectedRow];
        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        //DetailViewController *controller = (DetailViewController *)[segue destinationViewController];
        [object setValue:@"" forKey:@"noticeTime"];
        ObservTableViewController *controller = (ObservTableViewController *)[segue destinationViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        
    } else if ([[segue identifier] isEqualToString:@"showResist"]) {
        [self insertNewObject];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
        NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
        //        NSLog(@"Error !: %@", [error localizedDescription]);
        //        NSLog(@"CoreData count = %ld", count);
        //        indexPath = [NSIndexPath indexPathForRow:count-1 inSection:0];
        //        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        //rowPosition = count-1 の object(最後に追加したもの)を検索
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rowPosition == %@", [NSString stringWithFormat:@"%ld",(count-1)]];
        [request setPredicate:predicate];
        NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
        if (array != nil) {
            for (NSManagedObject *object in array) {
                ResistViewController *controller = (ResistViewController *)[segue destinationViewController];
                [controller setDetailItem:object];
            }
        } else {
            NSLog(@"fetch result is 0");
        }
        
    }
}

#pragma mark - Table View

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Detemine if it's in editing mode
    if (self.editing) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.refreshingFlag == 0) {
//    if(self.refreshBarItemButton.enabled == YES) {
        if (self.refreshSwitch.on == YES) {
            return nil;
        } else {
            return indexPath;
        }
    } else {
        return nil;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //    NSLog(@"*** Now numberOfSectionsInTableView");
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    NSLog(@"*** Now numberOfRowsInSection");
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"*** Now cellForRowAtIndexPath");
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    BoardTableViewCell *cell = (BoardTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(BoardTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"*** Now configureCell");
    //    NSLog(@"Now configureCell index=%ld", indexPath.row);
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (self.refreshSwitch.on == YES) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    //銘柄名
    //cell.textLabel.text = [[object valueForKey:@"code"] description];
    NSString *str;
    NSString *code = [[object valueForKey:@"code"] description];
    NSString *place = [[object valueForKey:@"place"] description];
    NSString *name = [[object valueForKey:@"name"] description];
    
    str = [code stringByAppendingString:place];
    str = [str stringByAppendingString:@" "];
    str = [str stringByAppendingString:name];
    cell.codeNameLabel.text = str;
    //    NSLog(@"cell.codeNameLabel.text(code+place+name) =%@", cell.codeNameLabel.text);
    
    //現在値
    NSString *strPrice;
    //NSString *strPrice = [[object valueForKey:@"price"] description];
    if (self.refreshSwitch.on == YES) {
        strPrice = [self.tempPriceMArray objectAtIndex:indexPath.row];
    } else {
        strPrice = [[object valueForKey:@"price"] description];
    }
    //am7:00-9:00の間、現在値がWebで”---”となるので、前日終値を表示する
    if ([strPrice isEqualToString:@"---"]) {
        cell.priceLabel.text = [[object valueForKey:@"yesterdayPrice"] description];
    } else {
        if (self.refreshSwitch.on == YES) {
            cell.priceLabel.text = [self.tempPriceMArray objectAtIndex:indexPath.row];
        } else {
            cell.priceLabel.text = [[object valueForKey:@"price"] description];
        }
    }
    //    NSLog(@"cell.priceLabel.text =%@", cell.priceLabel.text);
    
    //前日比、騰落率
    float priceValTemp = 0;
    float changeVal = 0;
    float changeValTemp = 0;
    float changeRate = 0;
    NSString *valTemp;
    NSString *rateTemp;
    
    NSString *setString = [NSString stringWithFormat:@"%@",cell.priceLabel.text];
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
        cell.priceLabel.textColor = [UIColor blackColor];
        cell.changeValLabel.textColor = [UIColor blackColor];
        cell.changeRateLabel.textColor = [UIColor blackColor];
    } else if (changeVal > 0){
        valTemp = [@"+" stringByAppendingString:valTemp];
        rateTemp = [@"+" stringByAppendingString:rateTemp];
        cell.priceLabel.textColor = [UIColor blueColor];
        cell.changeValLabel.textColor = [UIColor blueColor];
        cell.changeRateLabel.textColor = [UIColor blueColor];
    } else if (changeVal < 0) {
        cell.priceLabel.textColor = [UIColor redColor];
        cell.changeValLabel.textColor = [UIColor redColor];
        cell.changeRateLabel.textColor = [UIColor redColor];
    }
    rateTemp = [rateTemp stringByAppendingString:@"%"];
    cell.changeValLabel.text = valTemp;
    cell.changeRateLabel.text = rateTemp;
    
    //    NSLog(@"cell.changeValLabel.text %@", cell.changeValLabel.text);
    //    NSLog(@"cell.changeRateLabel.text %@", cell.changeRateLabel.text);
    
    //監視値 イメージ
    NSString *observe;
    NSInteger image;
    if (self.refreshSwitch.on == YES) {
        image = [[self.tempObserveImageMArray objectAtIndex:indexPath.row] integerValue];
    } else {
        image = [[object valueForKey:@"observeImage"] intValue];
    }
    switch (image) {
        case 1:
            observe = @"button_01.png";
            break;
        case 2:
            observe = @"button_02.png";
            break;
        case 3:
            observe = @"button_03.png";
            break;
        default:
            break;
    }
    cell.observeImage.image = [UIImage imageNamed:observe];
    
    //通知日時
    //NSDate *noticeDate = [object valueForKey:@"noticeTime"];
    //if (![noticeDate isEqual:[NSNull null]]) {
    //cell.noticeTimeLabel.text = [[object valueForKey:@"noticeTime"] description];
    if (self.refreshSwitch.on == YES) {
        cell.noticeTimeLabel.text = [self.tempNoticeTimeMArray objectAtIndex:indexPath.row];
    } else {
        cell.noticeTimeLabel.text = [[object valueForKey:@"noticeTime"] description];
    }
    //    NSLog(@"cell.noticeTimeLabel.text =%@", cell.noticeTimeLabel.text);
    //}
    
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"*** Now canMoveRowAtIndexPath");
    // The table view should not be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    //    NSLog(@"*** Now moveRowAtIndexPath");
    //for example
    //    NSString *stringToMove = [self.reorderingRows objectAtIndex:sourceIndexPath.row];
    //    [self.reorderingRows removeObjectAtIndex:sourceIndexPath.row];
    //    [self.reorderingRows insertObject:stringToMove atIndex:destinationIndexPath.row];
    
    NSError *error = nil;
    self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
    NSIndexPath *indexPath;
    NSManagedObject *object;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
    //    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    //    NSLog(@"Error !: %@", [error localizedDescription]);
    //    NSLog(@"CoreData count = %ld", count);
    
    //    for (int j=0; j < count; j++) {
    //        indexPath = [NSIndexPath indexPathForRow:j inSection:0];
    //        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    //        NSLog(@"object rowPosition[%d] = %@", j ,[object valueForKey:@"rowPosition"]);
    //    }
    
    NSString *sorceRowbuf = [NSString stringWithFormat:@"%ld", sourceIndexPath.row];
    NSString *destRowbuf = [NSString stringWithFormat:@"%ld", destinationIndexPath.row];
    
    object = [[self fetchedResultsController] objectAtIndexPath:sourceIndexPath];
    //[object setValue:destRowbuf forKey:@"rowPosition"];
    [object setValue:[NSNumber numberWithInteger:destinationIndexPath.row] forKey:@"rowPosition"];
    
    NSInteger startRow;
    NSInteger endRow;
    NSInteger cnt;
    NSInteger index;
    NSString *rowTemp;
    NSInteger valTemp;
    
    if ([sorceRowbuf integerValue] < [destRowbuf integerValue]) {
        //move up -> down
        startRow = [sorceRowbuf integerValue]+1;
        endRow = [destRowbuf integerValue];
        index = sourceIndexPath.row +1;
        for (cnt = startRow; cnt <= endRow; cnt++) {
            indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            //            NSLog(@"indexPath.row = @%ld", indexPath.row);
            rowTemp = [object valueForKey:@"rowPosition"];
            valTemp = [rowTemp integerValue];
            valTemp--;
            //[object setValue:[NSString stringWithFormat:@"%d", valTemp] forKey:@"rowPosition"];
            [object setValue:[NSNumber numberWithInteger:valTemp] forKey:@"rowPosition"];
            //            NSLog(@"indexPath.row = @%ld", indexPath.row);
            index++;
        }
        
    } else if([sorceRowbuf integerValue] > [destRowbuf integerValue]){
        //move down -> up
        startRow = [destRowbuf integerValue];
        endRow = [sorceRowbuf integerValue]-1;
        index = destinationIndexPath.row;
        for (cnt = startRow; cnt <= endRow; cnt++) {
            indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            //            NSLog(@"indexPath.row = @%ld", indexPath.row);
            rowTemp = [object valueForKey:@"rowPosition"];
            valTemp = [rowTemp integerValue];
            valTemp++;
            //[object setValue:[NSString stringWithFormat:@"%d", valTemp] forKey:@"rowPosition"];
            [object setValue:[NSNumber numberWithInteger:valTemp] forKey:@"rowPosition"];
            index++;
        }
    } else {
        //Nothing to do
    }
    
    //    for (int j=0; j < count; j++) {
    //        indexPath = [NSIndexPath indexPathForRow:j inSection:0];
    //        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    //        NSLog(@"object rowPosition[%d] = %@", j ,[object valueForKey:@"rowPosition"]);
    //    }
    
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self createTemporaryArrays];
    
    //---reload table view
    [self.boardTableView reloadData];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"*** Now canEditRowAtIndexPath");
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"*** Now commitEditingStyle");
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
        NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
        //        NSLog(@"CoreData count = %ld", count);
        
        //        for (int j=0; j < count; j++) {
        //            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:0];
        //            NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        //            NSLog(@"object rowPosition[%d] = %@", j ,[object valueForKey:@"rowPosition"]);
        //        }
        
        //delete coredata
        self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
        [self.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
        count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
        //        NSLog(@"CoreData count = %ld", count);
        
        //削除行以降のrowPositionを全て-1する
        NSManagedObject *object;
        NSInteger startRow;
        NSInteger endRow;
        NSInteger cnt;
        NSInteger index;
        NSString *rowTemp;
        NSInteger valTemp;
        
        startRow = indexPath.row;
        endRow = count;
        index = indexPath.row;
        for (cnt = startRow; cnt < endRow; cnt++) {
            indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            //            NSLog(@"indexPath.row = @%ld", indexPath.row);
            rowTemp = [object valueForKey:@"rowPosition"];
            valTemp = [rowTemp intValue];
            valTemp--;
            //[object setValue:[NSString stringWithFormat:@"%d", valTemp] forKey:@"rowPosition"];
            [object setValue:[NSNumber numberWithInteger:valTemp] forKey:@"rowPosition"];
            //            NSLog(@"indexPath.row = @%ld", indexPath.row);
            index++;
        }
        
        //        for (int j=0; j < count; j++) {
        //            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:0];
        //            NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        //            NSLog(@"object rowPosition[%d] = %@", j ,[object valueForKey:@"rowPosition"]);
        //        }
        
        if (![self.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [self createTemporaryArrays];
    }
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    //    NSLog(@"*** Now fetchedResultsController");
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    //    NSLog(@"*** Now controllerWillChangeContent");
    [self.boardTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    //    NSLog(@"*** Now didChangeSection");
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.boardTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.boardTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    //    NSLog(@"*** Now didChangeObject");
    UITableView *tableView = self.boardTableView;
    
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self createTemporaryArrays];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self createTemporaryArrays];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            //[self createTemporaryArrays];     //No need
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self createTemporaryArrays];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //    NSLog(@"*** Now controllerDidChangeContent");
    [self.boardTableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

#pragma mark - Ovserve Network

/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
    
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
//    if (reachability == self.hostReachability)
//    {
//        //２回呼ばれる。２回目のコールは、CompleteでFlagが0になる
//        //このコールは無視する。
////        self.hostReachabilityCallCount++;
////        if (self.hostReachabilityCallCount == 1) {
//            NSLog(@"reachability == self.hostReachability");
//            //        [self configureTextField:self.remoteHostStatusField imageView:self.remoteHostImageView reachability:reachability];
//            [self configureTextField:self.remoteHostImageView reachability:reachability];
//            
//            //        NetworkStatus netStatus = [reachability currentReachabilityStatus];
//            BOOL connectionRequired = [reachability connectionRequired];
//            
//            //        self.summaryLabel.hidden = (netStatus != ReachableViaWWAN);
//            NSString* baseLabelText = @"";
//            
//            if (connectionRequired)
//            {
//                baseLabelText = NSLocalizedString(@"Cellular data network is available.\nInternet traffic will be routed through it after a connection is established.", @"Reachability text if a connection is required");
//            }
//            else
//            {
//                baseLabelText = NSLocalizedString(@"Cellular data network is active.\nInternet traffic will be routed through it.", @"Reachability text if a connection is not required");
//            }
//            //        self.summaryLabel.text = baseLabelText;
////        } else {
////            self.hostReachabilityCallCount = 0;
////        }
//    }
    
    if (reachability == self.internetReachability)
    {
        NSLog(@"reachability == self.internetReachability");
        
//        [self configureTextField:self.internetConnectionStatusField imageView:self.internetConnectionImageView reachability:reachability];
        [self configureTextField:self.remoteHostImageView reachability:reachability];
        
        if (self.refreshSwitch.on == YES) {
//            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//            // タイマ破棄
//            if(appDelegate.BackgraundTimerSource){
//                dispatch_source_cancel(appDelegate.BackgraundTimerSource);
//                //            appDelegate.BackgraundTimerSource = nil;
//            }
//            if(appDelegate.mainTimerSource){
//                dispatch_source_cancel(appDelegate.mainTimerSource);
//                //            appDelegate.mainTimerSource = nil;
//            }
            
            if (![self.inetRetryTimer isValid]) {
                self.inetRetryTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                                   target:self
                                                                 selector:@selector(inetRetryTimer:)
                                                                 userInfo:reachability
                                                                  repeats:YES];
            }
        }
    }
    
    if (reachability == self.wifiReachability)
    {
        NSLog(@"reachability == self.wifiReachability");
//        [self configureTextField:self.localWiFiConnectionStatusField imageView:self.localWiFiConnectionImageView reachability:reachability];
        [self configureTextField:self.remoteHostImageView reachability:reachability];

        if (self.refreshSwitch.on == YES) {
            if (![self.wifiRetryTimer isValid]) {
                self.wifiRetryTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                                       target:self
                                                                     selector:@selector(wifiRetryTimer:)
                                                                     userInfo:reachability
                                                                      repeats:YES];
            }
        }
    }
    
}

// Template Sorce Code
//
//    if (reachability == self.hostReachability)
//    {
//        [self configureTextField:self.remoteHostStatusField imageView:self.remoteHostImageView reachability:reachability];
//        NetworkStatus netStatus = [reachability currentReachabilityStatus];
//        BOOL connectionRequired = [reachability connectionRequired];
//        
//        self.summaryLabel.hidden = (netStatus != ReachableViaWWAN);
//        NSString* baseLabelText = @"";
//        
//        if (connectionRequired)
//        {
//            baseLabelText = NSLocalizedString(@"Cellular data network is available.\nInternet traffic will be routed through it after a connection is established.", @"Reachability text if a connection is required");
//        }
//        else
//        {
//            baseLabelText = NSLocalizedString(@"Cellular data network is active.\nInternet traffic will be routed through it.", @"Reachability text if a connection is not required");
//        }
//        self.summaryLabel.text = baseLabelText;
//    }
//    
//    if (reachability == self.internetReachability)
//    {
//        [self configureTextField:self.internetConnectionStatusField imageView:self.internetConnectionImageView reachability:reachability];
//    }
//    
//    if (reachability == self.wifiReachability)
//    {
//        [self configureTextField:self.localWiFiConnectionStatusField imageView:self.localWiFiConnectionImageView reachability:reachability];
//    }
//}

-(void)inetRetryTimer:(NSTimer *)timer{
    
    Reachability *reachability = [timer userInfo];
    if (reachability == self.internetReachability)
    {
        NSLog(@"retrying  reachability == self.internetReachability");
        //        [self configureTextField:self.internetConnectionStatusField imageView:self.internetConnectionImageView reachability:reachability];
        [self configureTextField:self.remoteHostImageView reachability:reachability];
    }

    if (self.inetworkStatusFlag == 2 && self.wifiStatusFlag == 2) {
        Reachability *reachability = [timer userInfo];
        if (reachability == self.internetReachability)
        {
            NSLog(@"retrying  reachability == self.internetReachability");
            //        [self configureTextField:self.internetConnectionStatusField imageView:self.internetConnectionImageView reachability:reachability];
            [self configureTextField:self.remoteHostImageView reachability:reachability];
        }
//        self.inetRetryCount++;
    } else {
//        self.inetRetryCount = 0;
        [timer invalidate];
    }
    
}

-(void)wifiRetryTimer:(NSTimer *)timer{

    Reachability *reachability = [timer userInfo];
    if (reachability == self.wifiReachability)
    {
        NSLog(@"retrying  reachability == self.wifiReachability");
        //        [self configureTextField:self.localWiFiConnectionStatusField imageView:self.localWiFiConnectionImageView reachability:reachability];
        [self configureTextField:self.remoteHostImageView reachability:reachability];
    }
    
    if (self.inetworkStatusFlag == 2 && self.wifiStatusFlag == 2) {
        Reachability *reachability = [timer userInfo];
        if (reachability == self.wifiReachability)
        {
            NSLog(@"retrying  reachability == self.wifiReachability");
            //        [self configureTextField:self.localWiFiConnectionStatusField imageView:self.localWiFiConnectionImageView reachability:reachability];
            [self configureTextField:self.remoteHostImageView reachability:reachability];
        }
//        self.wifiRetryCount++;
    } else {
//        if (!(self.inetworkStatusFlag == 2 && self.wifiStatusFlag == 2)) {
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        //タイマー作成 viewdidLoadで
//        [self prepareAutoRefresh];
//        // タイマー開始
//        dispatch_resume(appDelegate.BackgraundTimerSource);
//        dispatch_resume(appDelegate.mainTimerSource);
//        }
        [timer invalidate];
    }
    
}



- (void)configureTextField:(UIImageView *)imageView reachability:(Reachability *)reachability
{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
//    NSString* statusString = @"";
    
    switch (netStatus)
    {
        case NotReachable:        {
//            statusString = NSLocalizedString(@"Access Not Available", @"Text field text for access is not available");
            if (reachability == self.internetReachability) {
                self.inetworkStatusFlag = 2;
            }
            if (reachability == self.wifiReachability) {
                self.wifiStatusFlag = 2;
            }
            /*
             Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
             */
            connectionRequired = NO;
            break;
        }
            
        case ReachableViaWWAN:        {
//            statusString = NSLocalizedString(@"Reachable WWAN", @"");
//            if (self.networkStatusFlag == 12 || self.networkStatusFlag == 13) {
            self.inetworkStatusFlag = 1;
            break;
        }
        case ReachableViaWiFi:        {
//            statusString= NSLocalizedString(@"Reachable WiFi", @"");
//            if (self.networkStatusFlag == 12 || self.networkStatusFlag == 13) {
            self.wifiStatusFlag = 1;
            break;
        }
        case IgnoreReachable:        {
            break;
        }
    }
    
    //load image
    if (self.inetworkStatusFlag == 2 && self.wifiStatusFlag == 2) {
        imageView.image = [UIImage imageNamed:@"stop_01.png"];
    } else if (self.wifiStatusFlag == 1) {
        if (self.refreshSwitch.on == YES) {
            imageView.image = [UIImage imageNamed:@"Airport_01.png"];
        } else {
            imageView.image = [UIImage imageNamed:@"Airport_02.png"];
        }
    } else {
        if (self.refreshSwitch.on == YES) {
            imageView.image = [UIImage imageNamed:@"WWAN_01.png"];
        } else {
            imageView.image = [UIImage imageNamed:@"WWAN_02.png"];
        }
    }
    
    [self.view setNeedsDisplay];
    
//    if (connectionRequired)
//    {
//        NSString *connectionRequiredFormatString = NSLocalizedString(@"%@, Connection Required", @"Concatenation of status string with connection requirement");
//        statusString= [NSString stringWithFormat:connectionRequiredFormatString, statusString];
//    }
//    textField.text= statusString;
}


//- (void)configureTextField:(UITextField *)textField imageView:(UIImageView *)imageView reachability:(Reachability *)reachability
//{
//    NetworkStatus netStatus = [reachability currentReachabilityStatus];
//    BOOL connectionRequired = [reachability connectionRequired];
//    NSString* statusString = @"";
//    
//    switch (netStatus)
//    {
//        case NotReachable:        {
//            statusString = NSLocalizedString(@"Access Not Available", @"Text field text for access is not available");
//            imageView.image = [UIImage imageNamed:@"stop-32.png"] ;
//            /*
//             Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
//             */
//            connectionRequired = NO;
//            break;
//        }
//            
//        case ReachableViaWWAN:        {
//            statusString = NSLocalizedString(@"Reachable WWAN", @"");
//            imageView.image = [UIImage imageNamed:@"WWAN5.png"];
//            break;
//        }
//        case ReachableViaWiFi:        {
//            statusString= NSLocalizedString(@"Reachable WiFi", @"");
//            imageView.image = [UIImage imageNamed:@"Airport.png"];
//            break;
//        }
//    }
//    
//    if (connectionRequired)
//    {
//        NSString *connectionRequiredFormatString = NSLocalizedString(@"%@, Connection Required", @"Concatenation of status string with connection requirement");
//        statusString= [NSString stringWithFormat:connectionRequiredFormatString, statusString];
//    }
//    textField.text= statusString;
//}



@end
