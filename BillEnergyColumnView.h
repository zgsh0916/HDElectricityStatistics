//
//  BillEnergyColumnView.h
//  WonderHome
//
//  Created by m w on 2023/7/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BillEnergyColumnView : UIView

@property (nonatomic, strong) UIView    *bgView;
@property (nonatomic, strong) UILabel   *titleLabel;
@property (nonatomic, strong) UIView    *lineView;
@property (nonatomic, strong) UILabel   *unitLabel;
@property (nonatomic, strong) UIView    *yLineView;
@property (nonatomic, strong) UIView    *centerLineView;
@property (nonatomic, strong) UIView    *xLineView;
@property (nonatomic, strong) UILabel   *xUnitLabel;
@property (nonatomic, strong) UILabel   *firstSubTitLabel;
@property (nonatomic, strong) UILabel   *secondSubTitLabel;
@property (nonatomic, assign) double     kKedu;
@property (nonatomic, strong) NSMutableArray      *yScaleArray;
@property (nonatomic, strong) NSMutableArray      *xScaleArray;
@property (nonatomic, strong) NSMutableArray      *energyArray;
@property (nonatomic, strong) NSMutableArray      *xLabelArray;

@end

NS_ASSUME_NONNULL_END
