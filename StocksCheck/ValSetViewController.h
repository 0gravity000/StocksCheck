//
//  ValSetViewController.h
//  StocksCheck
//
//  Created by SASAKIAI on 2016/03/08.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ValSetViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (nonatomic) int typeFlag;
@property (nonatomic) NSString *typeValue;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *upperOrLowerLabel;

@property (weak, nonatomic) IBOutlet UITextField *valueTextField;


@end
