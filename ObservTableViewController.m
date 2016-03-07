//
//  ObservTableViewController.m
//  StocksCheck
//
//  Created by SASAKIAI on 2016/03/07.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

#import "ObservTableViewController.h"

@interface ObservTableViewController ()

@end

@implementation ObservTableViewController

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
        NSString *str;
        NSString *code = [[self.detailItem valueForKey:@"code"] description];
        NSString *place = [[self.detailItem valueForKey:@"place"] description];
        NSString *name = [[self.detailItem valueForKey:@"name"] description];
        
        //銘柄名
        str = [code stringByAppendingString:place];
        str = [str stringByAppendingString:@" "];
        str = [str stringByAppendingString:name];
        self.nameCell.textLabel.text = str;
        //現在値
        self.priceCell.textLabel.text = [[self.detailItem valueForKey:@"price"] description];
        //前日比、騰落率
        float priceValTemp = 0;
        float changeVal = 0;
        float changeValTemp = 0;
        float changeRate = 0;
        NSString *valTemp;
        NSString *rateTemp;
        
        NSString *setString = [NSString stringWithFormat:@"%@",self.priceCell.textLabel.text];
        NSString *setString2 = [setString stringByReplacingOccurrencesOfString:@"," withString:@""];
        priceValTemp = [setString2 floatValue];
        
        valTemp = [[self.detailItem valueForKey:@"yesterdayPrice"] description];
        setString = [NSString stringWithFormat:@"%@",valTemp];
        setString2 = [setString stringByReplacingOccurrencesOfString:@"," withString:@""];
        changeValTemp = [setString2 floatValue];
        
        changeVal = priceValTemp - changeValTemp;
        changeRate = (changeVal / changeValTemp) *100;
        
        valTemp = [NSString stringWithFormat : @"%.0f", changeVal];
        rateTemp = [NSString stringWithFormat : @"%.2f", changeRate];
        if (changeVal == 0) {
            valTemp = @"---";
            self.priceCell.textLabel.textColor = [UIColor blackColor];
            self.changeValCell.textLabel.textColor = [UIColor blackColor];
            self.changeRateCell.textLabel.textColor = [UIColor blackColor];
        } else if (changeVal > 0){
            valTemp = [@"+" stringByAppendingString:valTemp];
            rateTemp = [@"+" stringByAppendingString:rateTemp];
            self.priceCell.textLabel.textColor = [UIColor blueColor];
            self.changeValCell.textLabel.textColor = [UIColor blueColor];
            self.changeRateCell.textLabel.textColor = [UIColor blueColor];
        } else if (changeVal < 0) {
            self.priceCell.textLabel.textColor = [UIColor redColor];
            self.changeValCell.textLabel.textColor = [UIColor redColor];
            self.changeRateCell.textLabel.textColor = [UIColor redColor];
        }
        rateTemp = [rateTemp stringByAppendingString:@"%"];
        self.changeValCell.textLabel.text = valTemp;
        self.changeRateCell.textLabel.text = rateTemp;
        
        //現在値 監視値
        self.priceUpperCell.textLabel.text = @"上限";
        self.priceLowerCell.textLabel.text = @"下限";
        self.priceUpperCell.detailTextLabel.text = [[self.detailItem valueForKey:@"observePrice1"] description];
        self.priceLowerCell.detailTextLabel.text = [[self.detailItem valueForKey:@"observePrice2"] description];
        //前日比 監視値
        self.changeValUpperCell.textLabel.text = @"上限";
        self.changeValLowerCell.textLabel.text = @"下限";
        self.changeValUpperCell.detailTextLabel.text = [[self.detailItem valueForKey:@"observeChangeVal1"] description];
        self.changeValLowerCell.detailTextLabel.text = [[self.detailItem valueForKey:@"observeChangeVal2"] description];
        //騰落率 監視値
        self.changeRateUpperCell.textLabel.text = @"上限";
        self.changeRateLowerCell.textLabel.text = @"下限";
        self.changeRateUpperCell.detailTextLabel.text = [[self.detailItem valueForKey:@"observeChangeRate1"] description];
        self.changeRateLowerCell.detailTextLabel.text = [[self.detailItem valueForKey:@"observeChangeRate2"] description];
        
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"監視値設定";
    
    [self configureView];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    //return 0;
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    switch (section) {
        case 0:     //銘柄名
            return 1;
            break;
        case 1:     //現在値
            return 3;
            break;
        case 2:     //前日比
            return 3;
            break;
        case 3:     //騰落率
            return 3;
            break;
        default:
            return 0;
            break;
    }
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    return <#expression#>
//}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
