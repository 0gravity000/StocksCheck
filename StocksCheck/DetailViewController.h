//
//  DetailViewController.h
//  StocksCheck
//
//  Created by SASAKIAI on 2016/03/05.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
//@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *codeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *changeValLabel;
@property (weak, nonatomic) IBOutlet UILabel *changeRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;

@property (weak, nonatomic) IBOutlet UITextField *observePrice1TextField;
@property (weak, nonatomic) IBOutlet UITextField *observePrice2TextField;
@property (weak, nonatomic) IBOutlet UITextField *observeChangeVal1TextField;
@property (weak, nonatomic) IBOutlet UITextField *observeChangeVal2TextField;
@property (weak, nonatomic) IBOutlet UITextField *observeChangeRate1TextField;
@property (weak, nonatomic) IBOutlet UITextField *observeChangeRate2TextField;

@end

