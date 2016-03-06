//
//  DetailViewController.m
//  StocksCheck
//
//  Created by SASAKIAI on 2016/03/05.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

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
        self.codeNameLabel.text = str;

        //現在値
        self.priceLabel.text = [[self.detailItem valueForKey:@"price"] description];

        //前日比、騰落率
        float priceValTemp = 0;
        float changeVal = 0;
        float changeValTemp = 0;
        float changeRate = 0;
        NSString *valTemp;
        NSString *rateTemp;
        
        NSString *setString = [NSString stringWithFormat:@"%@",self.priceLabel.text];
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
            self.priceLabel.textColor = [UIColor blackColor];
            self.changeValLabel.textColor = [UIColor blackColor];
            self.changeRateLabel.textColor = [UIColor blackColor];
        } else if (changeVal > 0){
            valTemp = [@"+" stringByAppendingString:valTemp];
            rateTemp = [@"+" stringByAppendingString:rateTemp];
            self.priceLabel.textColor = [UIColor blueColor];
            self.changeValLabel.textColor = [UIColor blueColor];
            self.changeRateLabel.textColor = [UIColor blueColor];
        } else if (changeVal < 0) {
            self.priceLabel.textColor = [UIColor redColor];
            self.changeValLabel.textColor = [UIColor redColor];
            self.changeRateLabel.textColor = [UIColor redColor];
        }
        rateTemp = [rateTemp stringByAppendingString:@"%"];
        self.changeValLabel.text = valTemp;
        self.changeRateLabel.text = rateTemp;

        //time Stamp
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
