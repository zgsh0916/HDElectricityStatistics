//
//  BillModel.m
//  WonderHome
//
//  Created by m w on 2023/7/2.
//

#import "BillModel.h"

@implementation BillModel

+ (NSDictionary *)mj_objectClassInArray {
    
    return @{
        @"itemTimeSeriesDataVos": [BillModel class],
        @"valueTuples": [BillModel class]
       };
}

@end
