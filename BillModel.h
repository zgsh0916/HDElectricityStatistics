//
//  BillModel.h
//  WonderHome
//
//  Created by m w on 2023/7/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BillModel : NSObject

@property (nonatomic, copy)   NSMutableArray *energyArray;
@property (nonatomic, copy)   NSString *date;
@property (nonatomic, copy)   NSString *number;
@property (nonatomic, copy)   NSString *money;
@property (nonatomic, copy)   NSString *heatPump;
@property (nonatomic, copy)   NSString *chargingPile;
@property (nonatomic, copy)   NSString *other;
@property (nonatomic, copy)   NSString *saveMoney;

@property (nonatomic, copy)   NSString *grid_day;
@property (nonatomic, copy)   NSString *stored_day;
@property (nonatomic, copy)   NSString *photovoltaic_day;

//饼状图占比
@property (nonatomic, assign) NSString *a;
@property (nonatomic, assign) NSString *b;
@property (nonatomic, assign) NSString *c;
@property (nonatomic, copy)   NSString *aValue;
@property (nonatomic, copy)   NSString *bValue;
@property (nonatomic, copy)   NSString *cValue;
@property (nonatomic, assign) BOOL      fold;//折叠

@property (nonatomic, strong) NSMutableArray<BillModel *> *itemTimeSeriesDataVos;
@property (nonatomic, strong) NSMutableArray<BillModel *> *valueTuples;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *modelItemCode;

@end

NS_ASSUME_NONNULL_END
