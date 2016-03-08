//
//  ValSetViewController.m
//  StocksCheck
//
//  Created by SASAKIAI on 2016/03/08.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

#import "ValSetViewController.h"

@interface ValSetViewController ()

@end

@implementation ValSetViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}
- (void)setTypeFlag:(int)newTypeFlag {
    if (_typeFlag != newTypeFlag) {
        _typeFlag = newTypeFlag;
        
        // Update the view.
        [self configureView];
    }
}
- (void)setTypeValue:(NSString *)newtypeValue {
    if (_typeValue != newtypeValue) {
        _typeValue = newtypeValue;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.typeFlag) {
        if (self.detailItem) {
            self.errorLabel.text = @"";
            self.valueTextField.backgroundColor = [UIColor whiteColor];
            [self.navigationController.navigationItem setHidesBackButton:NO];
            
            NSString *str;
            NSString *code = [[self.detailItem valueForKey:@"code"] description];
            NSString *place = [[self.detailItem valueForKey:@"place"] description];
            NSString *name = [[self.detailItem valueForKey:@"name"] description];
            
            //銘柄名
            str = [code stringByAppendingString:place];
            str = [str stringByAppendingString:@" "];
            str = [str stringByAppendingString:name];
            self.nameLabel.text = str;
            
            //項目名　上限下限  監視値
            self.itemNameLabel.text = self.typeValue;
            
            if (self.typeFlag == 1) {
                self.valueTextField.text = [[self.detailItem valueForKey:@"observePrice1"] description];
                self.upperOrLowerLabel.text = @"上限値";
            } else if (self.typeFlag == 2) {
                self.valueTextField.text = [[self.detailItem valueForKey:@"observePrice2"] description];
                self.upperOrLowerLabel.text = @"下限値";
                
            } else if (self.typeFlag == 3) {
                self.valueTextField.text = [[self.detailItem valueForKey:@"observeChangeVal1"] description];
                self.upperOrLowerLabel.text = @"上限値";
                
            } else if (self.typeFlag == 4) {
                self.valueTextField.text = [[self.detailItem valueForKey:@"observeChangeVal2"] description];
                self.upperOrLowerLabel.text = @"下限値";
                
            } else if (self.typeFlag == 5) {
                self.valueTextField.text = [[self.detailItem valueForKey:@"observeChangeRate1"] description];
                self.upperOrLowerLabel.text = @"上限値";
            } else if (self.typeFlag == 6) {
                self.valueTextField.text = [[self.detailItem valueForKey:@"observeChangeRate2"] description];
                self.upperOrLowerLabel.text = @"下限値";
                
            } else {
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"値設定";
    
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    
    if (self.typeFlag == 1) {
        //現在値 監視値
        [self.detailItem setValue:self.valueTextField.text forKey:@"observePrice1"];
    } else if (self.typeFlag == 2) {
        //現在値 監視値
        [self.detailItem setValue:self.valueTextField.text forKey:@"observePrice2"];
    } else if (self.typeFlag == 3) {
        //前日比 監視値
        [self.detailItem setValue:self.valueTextField.text forKey:@"observeChangeVal1"];
    } else if (self.typeFlag == 4) {
        //前日比 監視値
        [self.detailItem setValue:self.valueTextField.text forKey:@"observeChangeVal2"];
    } else if (self.typeFlag == 5) {
        //騰落率 監視値
        [self.detailItem setValue:self.valueTextField.text forKey:@"observeChangeRate1"];
    } else if (self.typeFlag == 6) {
        //騰落率 監視値
        [self.detailItem setValue:self.valueTextField.text forKey:@"observeChangeRate2"];
    }else{
    }
    
}

#pragma mark -
-(BOOL)checkInvaliedString:(NSString *)checkedStr {
    if (([checkedStr isEqualToString:@""]) || (checkedStr == nil)) {
        return TRUE;
    } else {
        NSCharacterSet *checkedCharset = [NSCharacterSet characterSetWithCharactersInString:checkedStr];
        NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"0123456789+-."];
        BOOL result = [charset isSupersetOfSet:checkedCharset];
        if (result) {
            return TRUE;
        } else {
            return FALSE;
        }
    }
}

#pragma mark - textField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.navigationItem setHidesBackButton:YES];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    BOOL checkstr = [self checkInvaliedString:textField.text];
    if (!checkstr) {
        self.errorLabel.text = @"無効な値です。\n空欄、半角数値、半角+、半角-、\n小数点のみ有効です。";
        self.valueTextField.backgroundColor = [UIColor redColor];
        [self.navigationItem setHidesBackButton:YES];
    } else {
        self.errorLabel.text = @"";
        self.valueTextField.backgroundColor = [UIColor whiteColor];
        [self.navigationItem setHidesBackButton:NO];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    // キーボードを閉じる
    [sender resignFirstResponder];

    BOOL checkstr = [self checkInvaliedString:self.valueTextField.text];
    if (!checkstr) {
        self.errorLabel.text = @"無効な値です。\n空欄、半角数値、半角+、半角-、\n小数点のみ有効です。";
        self.valueTextField.backgroundColor = [UIColor redColor];
        [self.navigationItem setHidesBackButton:YES];
    } else {
        self.errorLabel.text = @"";
        self.valueTextField.backgroundColor = [UIColor whiteColor];
        [self.navigationItem setHidesBackButton:NO];
    }
    
    return TRUE;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
