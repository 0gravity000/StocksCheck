//
//  ObservTableViewController.h
//  StocksCheck
//
//  Created by SASAKIAI on 2016/03/07.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ObservTableViewController : UITableViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *priceUpperCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *priceLowerCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *priceCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *changeValCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *changeValUpperCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *changeValLowerCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *changeRateCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *changeRateUpperCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *changeRateLowerCell;



@end
