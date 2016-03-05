//
//  Stock+CoreDataProperties.m
//  StocksCheck
//
//  Created by SASAKIAI on 2016/03/05.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Stock+CoreDataProperties.h"

@implementation Stock (CoreDataProperties)

@dynamic code;
@dynamic name;
@dynamic place;
@dynamic price;
@dynamic rowPosition;
@dynamic timeStamp;
@dynamic yesterdayPrice;

@end
