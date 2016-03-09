//
//  ObservTableViewController.m
//  StocksCheck
//
//  Created by SASAKIAI on 2016/03/07.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

#import "ObservTableViewController.h"
#import "ValSetViewController.h"

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
        //self.priceCell.textLabel.text = [[self.detailItem valueForKey:@"price"] description];
        NSString *strPrice = [[self.detailItem valueForKey:@"price"] description];
        if ([strPrice isEqualToString:@"---"]) {
            self.priceCell.textLabel.text = [[self.detailItem valueForKey:@"yesterdayPrice"] description];
        } else {
            self.priceCell.textLabel.text = [[self.detailItem  valueForKey:@"price"] description];
        }
        
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
            valTemp = @"0";
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
        
        BOOL checkstr;
        //現在値 監視値
        self.priceUpperCell.textLabel.text = @"上限値";
        self.priceLowerCell.textLabel.text = @"下限値";
        self.priceUpperCell.detailTextLabel.text = [[self.detailItem valueForKey:@"observePrice1"] description];
        self.priceLowerCell.detailTextLabel.text = [[self.detailItem valueForKey:@"observePrice2"] description];
        
        //前日比 監視値
        self.changeValUpperCell.textLabel.text = @"上限値";
        self.changeValLowerCell.textLabel.text = @"下限値";
        self.changeValUpperCell.detailTextLabel.text = [[self.detailItem valueForKey:@"observeChangeVal1"] description];
        self.changeValLowerCell.detailTextLabel.text = [[self.detailItem valueForKey:@"observeChangeVal2"] description];

        //騰落率 監視値
        self.changeRateUpperCell.textLabel.text = @"上限値";
        self.changeRateLowerCell.textLabel.text = @"下限値";
        self.changeRateUpperCell.detailTextLabel.text = [[self.detailItem valueForKey:@"observeChangeRate1"] description];
        self.changeRateLowerCell.detailTextLabel.text = [[self.detailItem valueForKey:@"observeChangeRate2"] description];

        //---reload table view
        [self.tableView reloadData];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"監視値";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    //現在値 監視値
    [self.detailItem setValue:self.priceUpperCell.detailTextLabel.text forKey:@"observePrice1"];
    [self.detailItem setValue:self.priceLowerCell.detailTextLabel.text forKey:@"observePrice2"];
    
    //前日比 監視値
    [self.detailItem setValue:self.changeValUpperCell.detailTextLabel.text forKey:@"observeChangeVal1"];
    [self.detailItem setValue:self.changeValLowerCell.detailTextLabel.text forKey:@"observeChangeVal2"];
    
    //騰落率 監視値
    [self.detailItem setValue:self.changeRateUpperCell.detailTextLabel.text forKey:@"observeChangeRate1"];
    [self.detailItem setValue:self.changeRateLowerCell.detailTextLabel.text forKey:@"observeChangeRate2"];
    
    //イメージ 監視値
    [self.detailItem setValue:@"2" forKey:@"observeImage"];
    if ([self.priceUpperCell.detailTextLabel.text isEqualToString:@""]) {
        if ([self.priceLowerCell.detailTextLabel.text isEqualToString:@""]) {
            if ([self.changeValUpperCell.detailTextLabel.text isEqualToString:@""]) {
                if ([self.changeValLowerCell.detailTextLabel.text isEqualToString:@""]) {
                    if ([self.changeRateUpperCell.detailTextLabel.text isEqualToString:@""]) {
                        if ([self.changeRateLowerCell.detailTextLabel.text isEqualToString:@""]) {
                            [self.detailItem setValue:@"1" forKey:@"observeImage"];
                        }
                    }
                }
            }
        }
    }
    
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    ValSetViewController *controller = (ValSetViewController *)[segue destinationViewController];
    
    if ([[segue identifier] isEqualToString:@"setPriceUpper"]) {
        [controller setTypeValue:self.priceCell.textLabel.text];
        [controller setTypeFlag:1];
    } else if ([[segue identifier] isEqualToString:@"setPriceLower"]) {
        [controller setTypeValue:self.priceCell.textLabel.text];
        [controller setTypeFlag:2];
        
    } else if ([[segue identifier] isEqualToString:@"setPriceValUpper"]) {
        [controller setTypeValue:self.changeValCell.textLabel.text];
        [controller setTypeFlag:3];
    } else if ([[segue identifier] isEqualToString:@"setPriceValLower"]) {
        [controller setTypeValue:self.changeValCell.textLabel.text];
        [controller setTypeFlag:4];
        
    } else if ([[segue identifier] isEqualToString:@"setPriceRateUpper"]) {
        [controller setTypeValue:self.changeRateCell.textLabel.text];
        [controller setTypeFlag:5];
    } else if ([[segue identifier] isEqualToString:@"setPriceRateLower"]) {
        [controller setTypeValue:self.changeRateCell.textLabel.text];
        [controller setTypeFlag:6];
        
    } else {
    }
    
    [controller setDetailItem:self.detailItem];
    
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
