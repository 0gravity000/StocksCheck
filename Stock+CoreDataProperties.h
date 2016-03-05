//
//  Stock+CoreDataProperties.h
//  StocksCheck
//
//  Created by SASAKIAI on 2016/03/05.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Stock.h"

NS_ASSUME_NONNULL_BEGIN

@interface Stock (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *place;
@property (nullable, nonatomic, retain) NSString *price;
@property (nullable, nonatomic, retain) NSString *rowPosition;
@property (nullable, nonatomic, retain) NSDate *timeStamp;
@property (nullable, nonatomic, retain) NSString *yesterdayPrice;

@end

NS_ASSUME_NONNULL_END