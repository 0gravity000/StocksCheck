//
//  BoardViewController.m
//  StocksCheck
//
//  Created by SASAKIAI on 2016/03/05.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

#import "BoardViewController.h"
//#import "DetailViewController.h"
#import "ObservTableViewController.h"
#import "ResistViewController.h"

@interface BoardViewController ()

@end

@implementation BoardViewController

- (void)viewDidLoad {
    NSLog(@"*** Now viewDidLoad");
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

    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"*** Now viewWillAppear");
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
        NSLog(@"Error !: %@", [error localizedDescription]);
        NSLog(@"CoreData count = %ld", count);

        for (int j=0; j < count; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:0];
            NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            NSLog(@"object rowPosition[%d] = %@", j ,[object valueForKey:@"rowPosition"]);
        }
        
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
                // Save the context.
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
        
        for (int j=0; j < count; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:0];
            NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            NSLog(@"object rowPosition[%d] = %@", j ,[object valueForKey:@"rowPosition"]);
        }
        
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
    }
    [self initializeCoreData];

    [self checkObserveVaules];
    
}

- (void)didReceiveMemoryWarning {
    NSLog(@"*** Now didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject {
    NSLog(@"*** Now insertNewObject");
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
}


//- (void)insertNewObject:(id)sender {
//    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
//    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
//    
//    // If appropriate, configure the new managed object.
//    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
//    //[newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
//    NSDate* now = [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone systemTimeZone] secondsFromGMT]];
//    [newManagedObject setValue:now forKey:@"timeStamp"];
//    
//    // Save the context.
//    NSError *error = nil;
//    if (![context save:&error]) {
//        // Replace this implementation with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//}

-(void)initializeCoreData {
    NSLog(@"*** Now initializeCoreData");
    
    NSString *url;
    NSError *error = nil;
    
    self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
    NSIndexPath *indexPath;
    NSManagedObject *object;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
    //NSFetchRequest *fetchRequest;
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    NSLog(@"Error !: %@", [error localizedDescription]);
    NSLog(@"CoreData count = %ld", count);
    
    for (int i=0; i < count; i++) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSString *codebuf;
        NSString *placebuf;
        
        //code
        codebuf = [object valueForKey:@"code"];
        NSLog(@"code %@", codebuf);
        
        //place
        placebuf = [object valueForKey:@"place"];
        NSLog(@"place %@", placebuf);
        
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
        }
        
        NSString *html_ = [NSString stringWithContentsOfURL:transUrl
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
        NSString *html = [html_ stringByReplacingOccurrencesOfString:@"\n"
                                                          withString:@""];
        //NSLog(@"%@", html);
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        
        //--- Search for stockName from html　銘柄名
        // 正規表現の中で.*?とやると最短マッチするらしい。
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"<th class=\"symbol\"><h1>(.*?)</h1></th>"
                                                                                options:0
                                                                                  error:nil];
        //
        //ここの処理を見直すこと。エラー処理も必要か？
        NSArray *arr = [regexp matchesInString:html
                                       options:0
                                         range:NSMakeRange(0, html.length)];
        
        for (NSTextCheckingResult *match in arr) {
            NSString *codeNamebuf = [html substringWithRange:[match rangeAtIndex:1]];
            [object setValue:codeNamebuf forKey:@"name"];
            NSLog(@"name %@", codeNamebuf);
        }
        
        
        //--- Search for yesterday stock price from html 前日終値
        // 正規表現の中で.*?とやると最短マッチするらしい。
        
        //<dl class="tseDtlDelay"><dd class="ymuiEditLink mar0"><strong>5,585</strong><span class="date yjSt">（02/26）</span></dd><dt class="title">前日終値
        
        regexp = [NSRegularExpression regularExpressionWithPattern:@"<dl class=\"tseDtlDelay\"><dd class=\"ymuiEditLink mar0\"><strong>(.*)</strong><span class=\"date yjSt\">(.*)</span></dd><dt class=\"title\">前日終値"
                                                           options:0
                                                             error:nil];
        //
        //ここの処理を見直すこと。エラー処理も必要か？
        arr = [regexp matchesInString:html
                              options:0
                                range:NSMakeRange(0, html.length)];
        
        for (NSTextCheckingResult *match in arr) {
            NSString *yesterdayPricebuf = [html substringWithRange:[match rangeAtIndex:1]];
            [object setValue:yesterdayPricebuf forKey:@"yesterdayPrice"];
            NSLog(@"yesterdayPricebuf %@", yesterdayPricebuf);
        }
        
        //--- Search for Now stock price from html 現在値
        // 正規表現の中で.*?とやると最短マッチするらしい。
        regexp = [NSRegularExpression regularExpressionWithPattern:@"<td class=\"stoksPrice\">(.*?)</td>"
                                                           options:0
                                                             error:nil];
        
        //
        //ここの処理を見直すこと。エラー処理も必要か？
        arr = [regexp matchesInString:html
                              options:0
                                range:NSMakeRange(0, html.length)];
        
        for (NSTextCheckingResult *match in arr) {
            NSString *pricebuf = [html substringWithRange:[match rangeAtIndex:1]];
            [object setValue:pricebuf forKey:@"price"];
            NSLog(@"price %@", pricebuf);
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
        
    }
    
    //---reload table view
    [self.boardTableView reloadData];
}


- (IBAction)pushRefreshBarItemButton:(id)sender {
    NSLog(@"*** Now pushRefreshBarItemButton");
    [self refreshPriceValue];
    [self checkObserveVaules];
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
    localNotif.alertBody = [NSString stringWithFormat:@"%@\n監視値成立\n%@",name ,time];
    //localNotif.alertAction = NSLocalizedString(@"View Details", nil);aaaaa
    localNotif.alertAction = @"Open";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    //localNotif.applicationIconBadgeNumber = 1;
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"test" forKey:@"key1"];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

-(void)checkObserveVaules {
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
    

    for (int i=0; i < count; i++) {
        NSLog(@"checkObserveVaules i = %d", i);
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        BoardTableViewCell *cell = (BoardTableViewCell *)[self.boardTableView cellForRowAtIndexPath:indexPath];
        
        int iHitFlag = 0;
        NSString *BasicPrice = cell.priceLabel.text;
        NSString *targetString;
        
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
            
            NSString *BasicChangeVal = cell.changeValLabel.text;
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
            
            NSString *BasicchangeRate = cell.changeRateLabel.text;
            BasicchangeRate = [BasicchangeRate stringByReplacingOccurrencesOfString:@"%" withString:@""];
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
        
        
        if (iHitFlag != 0) {
            //監視値　イメージ
            [object setValue:@"3" forKey:@"observeImage"];
            
            //NSString *noticeDate = [object valueForKey:@"noticeTime"];
            //if ([noticeDate isEqual:[NSNull null]]) {
            //if (noticeDate == nil) {
            if ([cell.noticeTimeLabel.text isEqualToString:@""]) {
                //--- Local Notification
                //時間
                NSDate* now = [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone systemTimeZone] secondsFromGMT]];
                //[object setValue:now forKey:@"noticeTime"];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [formatter setDateFormat:@"MM/dd HH:mm:ss"];
                NSString *noticeTime = [formatter stringFromDate:now];
                [object setValue:noticeTime forKey:@"noticeTime"];
                
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
        
        // Save the context.
        if (![self.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
    }
    //---reload table view
    [self.boardTableView reloadData];
    
}

-(void)refreshPriceValue {
    NSLog(@"*** Now refreshPriceValue");
    NSString *url;
    NSString *codebuf;
    NSString *placebuf;
    
    //--- Show Stock Page in WebView
    NSError *error = nil;
    self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
    NSIndexPath *indexPath;
    NSManagedObject *object;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext]];
    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    NSLog(@"Error !: %@", [error localizedDescription]);
    NSLog(@"CoreData count = %ld", count);
    
    for (int i=0; i < count; i++) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
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
        //ここの処理を見直すこと。エラー処理も必要か？
        NSArray *arr = [regexp matchesInString:html
                                       options:0
                                         range:NSMakeRange(0, html.length)];
        
        for (NSTextCheckingResult *match in arr) {
            NSString *pricebuf = [html substringWithRange:[match rangeAtIndex:1]];
            [object setValue:pricebuf forKey:@"price"];
            NSLog(@"price %@", pricebuf);
        }
        // Save the context.
        if (![self.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    //---reload table view
    [self.boardTableView reloadData];
}

#pragma mark - Navigation Controller

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    NSLog(@"*** Now setEditing");
    [super setEditing:editing animated:animated];
    [self.boardTableView setEditing:editing animated:YES];
    //desable add button
    
    if (editing) {
        self.addBarItemButton.enabled = NO;
    } else {
        self.addBarItemButton.enabled = YES;
    }
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"*** Now prepareForSegue");
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"*** Now numberOfSectionsInTableView");
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"*** Now numberOfRowsInSection");
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"*** Now cellForRowAtIndexPath");
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    BoardTableViewCell *cell = (BoardTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(BoardTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"*** Now configureCell");
    NSLog(@"Now configureCell index=%ld", indexPath.row);
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //cell.textLabel.text = [[object valueForKey:@"code"] description];
    NSString *str;
    NSString *code = [[object valueForKey:@"code"] description];
    NSString *place = [[object valueForKey:@"place"] description];
    NSString *name = [[object valueForKey:@"name"] description];
    
    //銘柄名
    str = [code stringByAppendingString:place];
    str = [str stringByAppendingString:@" "];
    str = [str stringByAppendingString:name];
    cell.codeNameLabel.text = str;
    NSLog(@"cell.codeNameLabel.text(code+place+name) =%@", cell.codeNameLabel.text);
    //現在値
    cell.priceLabel.text = [[object valueForKey:@"price"] description];
    NSLog(@"cell.priceLabel.text(code+place+name) =%@", cell.priceLabel.text);
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
    
    NSLog(@"cell.changeValLabel.text %@", cell.changeValLabel.text);
    NSLog(@"cell.changeRateLabel.text %@", cell.changeRateLabel.text);

    //監視値 イメージ
    NSString *observe;
    switch ([[object valueForKey:@"observeImage"] intValue]) {
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
        cell.noticeTimeLabel.text = [[object valueForKey:@"noticeTime"] description];
        NSLog(@"cell.noticeTimeLabel.text =%@", cell.noticeTimeLabel.text);
    //}
    
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"*** Now canMoveRowAtIndexPath");
    // The table view should not be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSLog(@"*** Now moveRowAtIndexPath");
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
    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    NSLog(@"Error !: %@", [error localizedDescription]);
    NSLog(@"CoreData count = %ld", count);
    
    for (int j=0; j < count; j++) {
        indexPath = [NSIndexPath indexPathForRow:j inSection:0];
        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSLog(@"object rowPosition[%d] = %@", j ,[object valueForKey:@"rowPosition"]);
    }
    
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
            NSLog(@"indexPath.row = @%ld", indexPath.row);
            rowTemp = [object valueForKey:@"rowPosition"];
            valTemp = [rowTemp integerValue];
            valTemp--;
            //[object setValue:[NSString stringWithFormat:@"%d", valTemp] forKey:@"rowPosition"];
            [object setValue:[NSNumber numberWithInteger:valTemp] forKey:@"rowPosition"];
            NSLog(@"indexPath.row = @%ld", indexPath.row);
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
            NSLog(@"indexPath.row = @%ld", indexPath.row);
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

    self.managedObjectContext = [self.fetchedResultsController managedObjectContext];

    for (int j=0; j < count; j++) {
        indexPath = [NSIndexPath indexPathForRow:j inSection:0];
        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSLog(@"object rowPosition[%d] = %@", j ,[object valueForKey:@"rowPosition"]);
    }
    
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    //---reload table view
    [self.boardTableView reloadData];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"*** Now canEditRowAtIndexPath");
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"*** Now commitEditingStyle");
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
        NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
        NSLog(@"CoreData count = %ld", count);
        
        for (int j=0; j < count; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:0];
            NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            NSLog(@"object rowPosition[%d] = %@", j ,[object valueForKey:@"rowPosition"]);
        }
        
        //delete coredata
        self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
        [self.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stock"];
        count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
        NSLog(@"CoreData count = %ld", count);
        
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
            NSLog(@"indexPath.row = @%ld", indexPath.row);
            rowTemp = [object valueForKey:@"rowPosition"];
            valTemp = [rowTemp intValue];
            valTemp--;
            //[object setValue:[NSString stringWithFormat:@"%d", valTemp] forKey:@"rowPosition"];
            [object setValue:[NSNumber numberWithInteger:valTemp] forKey:@"rowPosition"];
            NSLog(@"indexPath.row = @%ld", indexPath.row);
            index++;
        }
        
        for (int j=0; j < count; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:0];
            NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            NSLog(@"object rowPosition[%d] = %@", j ,[object valueForKey:@"rowPosition"]);
        }
        
        if (![self.managedObjectContext save:&error]) {
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"*** Now controllerWillChangeContent");
    [self.boardTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSLog(@"*** Now didChangeSection");
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
    NSLog(@"*** Now didChangeObject");
    UITableView *tableView = self.boardTableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"*** Now controllerDidChangeContent");
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

@end
