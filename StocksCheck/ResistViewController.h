//
//  ResistViewController.h
//  StocksCheck
//
//  Created by SASAKIAI on 2016/03/05.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResistTableView.h"
#import "ResistTableViewCell.h"

@interface ResistViewController : UIViewController <UISearchBarDelegate>

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (weak, nonatomic) IBOutlet ResistTableView *resistTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *codeSearchBar;

@property NSMutableArray *stocksArray;
@property NSMutableArray *searchResultArray;


@end
