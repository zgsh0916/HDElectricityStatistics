//
//  BillEnergyColumnView.m
//  WonderHome
//
//  Created by m w on 2023/7/2.
//

#import "BillEnergyColumnView.h"
#import "BillModel.h"

#define kEnergyColumnWidth 5.2
#define kEnergyColumnMargin 6.4
#define kUnitWidth (SCREEN_WIDTH - 66 - 32 - 6)/24.0
@implementation BillEnergyColumnView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)makeConstraints {
    for (UIView *v in self.subviews) {
        for (UIView *subV in v.subviews) {
            [subV removeFromSuperview];
        }
        [v removeFromSuperview];
    }
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.lineView];
    [self.bgView addSubview:self.unitLabel];
    [self.bgView addSubview:self.xLineView];
    [self.bgView addSubview:self.yLineView];
    [self.bgView addSubview:self.xUnitLabel];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self).offset(16);
        make.right.mas_equalTo(self).offset(-16);
        make.height.mas_equalTo(245);
        make.top.bottom.mas_equalTo(self).offset(0);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.mas_equalTo(self.bgView).offset(12);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.mas_equalTo(self.bgView).offset(0);
        make.top.mas_equalTo(self.bgView).offset(44);
        make.height.mas_equalTo(1);
    }];
    
    [self.unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.bgView).offset(22);
        make.top.mas_equalTo(self.lineView.mas_bottom).offset(40);
    }];
    
    [self.yLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.bgView).offset(32);
        make.top.mas_equalTo(self.lineView.mas_bottom).offset(56);
        make.height.mas_equalTo(82);
        make.width.mas_equalTo(1);
    }];
    
    [self.xLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.bgView).offset(32);
        make.right.mas_equalTo(self.bgView).offset(-12);
        make.top.mas_equalTo(self.yLineView.mas_bottom).offset(0);
        make.height.mas_equalTo(1);
    }];
    
    [self.xUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(self.bgView).offset(-12);
        make.top.mas_equalTo(self.xLineView.mas_bottom).offset(4);
    }];
    
    [self addXScaleView];
    [self addYScaleView];
    
}

- (void)setEnergyArray:(NSMutableArray *)energyArray {
    _energyArray = energyArray;
    //计算y轴坐标
    [self getYCoordinate];
    [self makeConstraints];
    [self addPowerCategory];
    [self addEnergyColumnView];
    [self addStatisticsView];
}

/* 计算y轴坐标 */
- (void)getYCoordinate {
    
    double photovoltaicValue = 0;
    double energyStorageValue = 0;
    double powerGridValue = 0;
    NSMutableArray *sumsArray = [NSMutableArray array];
    for (BillModel *model in _energyArray) {
        double sum = 0;
        for (BillModel *tempModel in model.valueTuples) {

            //电网
            if ([tempModel.modelItemCode isEqualToString:@"HourSupply"])
            {
                powerGridValue = [tempModel.value doubleValue];
                sum += powerGridValue;
            }
            
            //光伏
            if ([tempModel.modelItemCode isEqualToString:@"HourGenerate"])
            {
                photovoltaicValue = [tempModel.value doubleValue];
                sum += photovoltaicValue;
            }
            
            //储能
            if ([tempModel.modelItemCode isEqualToString:@"HourDischarge"])
            {
                energyStorageValue = [tempModel.value doubleValue];
                sum += energyStorageValue;
            }
            
        }
        [sumsArray addObject:@(sum)];
    }
    
    double max = [sumsArray.firstObject doubleValue];
    for (int i = 1; i < sumsArray.count; i++) {
        
        max = max < [sumsArray[i] doubleValue] ? [sumsArray[i] doubleValue] : max;
    }
    int maxYCoordinate = ceil(max);
    NSString *maxStr = [NSString stringWithFormat:@"%d",maxYCoordinate];
    NSInteger maxCount = maxStr.length;
    int firstNumber = [[maxStr substringToIndex:1] intValue];
    NSString *maxY = [NSString stringWithFormat:@"%d",firstNumber + 1];
    for (int i = 1; i < maxCount; i++) {
        
        maxY = [NSString stringWithFormat:@"%@0",maxY];
    }
    int maxYINT = [maxY intValue];
    int part = maxYINT / 5;
    [self.yScaleArray addObject:[NSString stringWithFormat:@"%d.0",maxYINT]];
    [self.yScaleArray addObject:[NSString stringWithFormat:@"%d.0",part*4]];
    [self.yScaleArray addObject:[NSString stringWithFormat:@"%d.0",part*3]];
    [self.yScaleArray addObject:[NSString stringWithFormat:@"%d.0",part*2]];
    [self.yScaleArray addObject:[NSString stringWithFormat:@"%d.0",part*1]];
    [self.yScaleArray addObject:@"0"];
    self.kKedu = 80.0 / maxYINT;
}

/* 统计能量柱 */
- (void)addEnergyColumnView {
    
    for (BillModel *model in _energyArray) {
        
        UILabel *xLabel = [self.xLabelArray objectAtIndex:[_energyArray indexOfObject:model]+1];
        double photovoltaicValue = 0;
        double energyStorageValue = 0;
        double powerGridValue = 0;
        
        for (BillModel *tempModel in model.valueTuples) {
            //电网
            if ([tempModel.modelItemCode isEqualToString:@"HourSupply"])
            {
                powerGridValue = [tempModel.value doubleValue];
            }
            
            //光伏
            if ([tempModel.modelItemCode isEqualToString:@"HourGenerate"])
            {
                photovoltaicValue = [tempModel.value doubleValue];
            }
            
            //储能
            if ([tempModel.modelItemCode isEqualToString:@"HourDischarge"])
            {
                energyStorageValue = [tempModel.value doubleValue];
            }
        }
        
        
        UIView *totalView = [self getEnergyColumnView:@"#F5819D" endColor:@"#D84467"];
        totalView.hidden = YES;
        UIView *photovoltaicView = [self getEnergyColumnView:@"#32ADFF" endColor:@"#477FFF"];
        UIView *energyStorageView = [self getEnergyColumnView:@"#23BD7E" endColor:@"#59D5A2"];
        UIView *powerGridView = [self getEnergyColumnView:@"#DAEDFF" endColor:@"#B3DBFF"];
        
        [self.bgView addSubview:totalView];
        [self.bgView addSubview:powerGridView];
        [self.bgView addSubview:energyStorageView];
        [self.bgView addSubview:photovoltaicView];
        
        [totalView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.mas_equalTo(xLabel.mas_centerX);
            make.width.mas_equalTo(kEnergyColumnWidth);
            make.top.mas_equalTo(self.xLineView.mas_bottom).offset(0);
            make.height.mas_equalTo(1);
        }];
        
        [photovoltaicView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.mas_equalTo(xLabel.mas_centerX);
            make.width.mas_equalTo(kEnergyColumnWidth);
            make.bottom.mas_equalTo(self.xLineView.mas_top).offset(0);
            make.height.mas_equalTo(photovoltaicValue * self.kKedu);
        }];
        
        [energyStorageView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.mas_equalTo(xLabel.mas_centerX);
            make.width.mas_equalTo(kEnergyColumnWidth);
            make.bottom.mas_equalTo(photovoltaicView.mas_top).offset(2);
            make.height.mas_equalTo(energyStorageValue * self.kKedu + 2);
        }];

        [powerGridView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.mas_equalTo(xLabel.mas_centerX);
            make.width.mas_equalTo(kEnergyColumnWidth);
            make.bottom.mas_equalTo(energyStorageView.mas_top).offset(2);
            make.height.mas_equalTo(powerGridValue * self.kKedu + 2);
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [totalView radiusWithRadius:kEnergyColumnWidth / 2 type:UIRectCornerBottomRight | UIRectCornerBottomLeft];
            [powerGridView radiusWithRadius:kEnergyColumnWidth / 2 type:UIRectCornerTopRight | UIRectCornerTopLeft];
            [energyStorageView radiusWithRadius:kEnergyColumnWidth / 2 type:UIRectCornerTopRight | UIRectCornerTopLeft];
            [photovoltaicView radiusWithRadius:kEnergyColumnWidth / 2 type:UIRectCornerTopRight | UIRectCornerTopLeft];
        });
        
        [self setViewShadow:totalView];
        [self setViewShadow:energyStorageView];
        [self setViewShadow:powerGridView];
        [self setViewShadow:photovoltaicView];
    }
}

- (void)setViewShadow:(UIView *)energyView {
    
    energyView.layer.shadowColor = COLOR_WHITE(0.25).CGColor;
    energyView.layer.shadowOffset = CGSizeMake(0, -1);
    energyView.layer.shadowOpacity = 1;
    energyView.layer.shadowRadius = 20;
    energyView.clipsToBounds = NO;
}

/* y轴坐标 */
- (void)addYScaleView {
    
    UILabel *lastLabel;
    for (NSString *scale in self.yScaleArray) {
        UILabel *scaleLabel = [self getScaleLabel:scale x:NO];
        UIView *dotView = [[UIView alloc] init];
        [self.bgView addSubview:scaleLabel];
        [self.bgView addSubview:dotView];
        if (lastLabel == nil)
        {
            [scaleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.right.mas_equalTo(self.yLineView.mas_left).offset(-4);
                make.top.mas_equalTo(self.yLineView.mas_top).offset(0);
                make.height.mas_equalTo(10);
            }];
            
            [dotView mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.mas_equalTo(self.yLineView.mas_right).offset(0);
                make.height.mas_equalTo(1);
                make.centerY.mas_equalTo(scaleLabel.mas_centerY);
            }];
            dotView.hidden = YES;
            
        }else
        {
            if ([scale isEqualToString:@"0"])
            {
                [scaleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                    make.right.mas_equalTo(self.yLineView.mas_left).offset(-4);
                    make.top.mas_equalTo(lastLabel.mas_bottom).offset(0);
                    make.height.mas_equalTo(9);
                }];
                
                [dotView mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                    make.left.mas_equalTo(self.yLineView.mas_right).offset(0);
                    make.height.mas_equalTo(1);
                    make.centerY.mas_equalTo(scaleLabel.mas_centerY);
                }];
                dotView.hidden = YES;
                scaleLabel.hidden = YES;
            }else
            {
                [scaleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                    make.right.mas_equalTo(self.yLineView.mas_left).offset(-4);
                    make.top.mas_equalTo(lastLabel.mas_bottom).offset(4);
                    make.height.mas_equalTo(12);
                }];
                
                [dotView mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                    make.left.mas_equalTo(self.yLineView.mas_right).offset(0);
                    make.height.mas_equalTo(1);
                    make.centerY.mas_equalTo(scaleLabel.mas_centerY);
                }];
            }
        }
        lastLabel = scaleLabel;
        [dotView dottedVerticalLineWithLineColor:COLOR_WHITE(0.06) rect:CGRectMake(49, 0, SCREEN_WIDTH - 49 - 28, 1)];
    }
}

/* 统计各时段占比 */
- (void)addStatisticsView {
    
    CGFloat zeroToEight = 0,eightToEleven = 0,elevenToSeventeen = 0,sevenTeenToTwentytwo = 0,twentytwoToTwentyFour = 0,totalValue = 0;
    for (int i = 0; i < _energyArray.count; i++) {
        BillModel *model = _energyArray[i];
        int hour = i + 1;
        double photovoltaicValue = 0;
        double energyStorageValue = 0;
        double powerGridValue = 0;
        for (BillModel *tempModel in model.valueTuples) {
            //电网
            if ([tempModel.modelItemCode isEqualToString:@"HourSupply"])
            {
                powerGridValue = [tempModel.value doubleValue];
            }
            
            //光伏
            if ([tempModel.modelItemCode isEqualToString:@"HourGenerate"])
            {
                photovoltaicValue = [tempModel.value doubleValue];
            }
            
            //储能
            if ([tempModel.modelItemCode isEqualToString:@"HourDischarge"])
            {
                energyStorageValue = [tempModel.value doubleValue];
            }
        }
        
        if (hour >= 1 && hour <= 8)
        {
            zeroToEight += photovoltaicValue + energyStorageValue + powerGridValue;
            
        }else if (hour > 8 && hour <= 11)
        {
            eightToEleven += photovoltaicValue + energyStorageValue + powerGridValue;
            
        }else if (hour > 11 && hour <= 17)
        {
            elevenToSeventeen += photovoltaicValue + energyStorageValue + powerGridValue;
            
        }else if (hour > 17 && hour <= 22)
        {
            sevenTeenToTwentytwo += photovoltaicValue + energyStorageValue + powerGridValue;
            
        }else if (hour > 22 && hour <= 24)
        {
            twentytwoToTwentyFour += photovoltaicValue + energyStorageValue + powerGridValue;
        }
        totalValue += photovoltaicValue + energyStorageValue + powerGridValue;
    }
    
    UILabel *zeroToEightLable = [self getStatisticsLabel:@"#DAEDFF" endColor:@"#B3DBFF" valueStr:[NSString stringWithFormat:@"%.0f%%",zeroToEight / totalValue * 100] first:YES];
    
    UILabel *eightToElevenLable = [self getStatisticsLabel:@"#F5819D" endColor:@"#D84467" valueStr:[NSString stringWithFormat:@"%.0f%%",eightToEleven / totalValue * 100] first:NO];
    
    UILabel *elevenToSeventeenLable = [self getStatisticsLabel:@"#23BD7E" endColor:@"#59D5A2" valueStr:[NSString stringWithFormat:@"%.0f%%",elevenToSeventeen / totalValue * 100] first:NO];
    
    UILabel *sevenTeenToTwentytwoLable = [self getStatisticsLabel:@"#F5819D" endColor:@"#D84467" valueStr:[NSString stringWithFormat:@"%.0f%%",sevenTeenToTwentytwo / totalValue * 100] first:NO];
    
    UILabel *twentytwoToTwentyFourLable = [self getStatisticsLabel:@"#23BD7E" endColor:@"#59D5A2" valueStr:[NSString stringWithFormat:@"%.0f%%",twentytwoToTwentyFour / totalValue * 100] first:NO];
    
    //如果由于精度问题 总数大于101或者99 则在第一个数据上减1或者加1
    int first = [[zeroToEightLable.text componentsSeparatedByString:@"%"].firstObject intValue];
    int second = [[eightToElevenLable.text componentsSeparatedByString:@"%"].firstObject intValue];
    int thirh = [[elevenToSeventeenLable.text componentsSeparatedByString:@"%"].firstObject intValue];
    int fourth = [[sevenTeenToTwentytwoLable.text componentsSeparatedByString:@"%"].firstObject intValue];
    int fifth = [[twentytwoToTwentyFourLable.text componentsSeparatedByString:@"%"].firstObject intValue];
    
    if (first + second + thirh + fourth + fifth == 101)
    {
        zeroToEightLable.text = [NSString stringWithFormat:@"%d%%",first - 1];
        
    }else if (first + second + thirh + fourth + fifth == 99)
    {
        zeroToEightLable.text = [NSString stringWithFormat:@"%d%%",first + 1];
    }

    UILabel *partOneLabel = [self getNameLabel:@"谷"];
    UILabel *partTwoLabel = [self getNameLabel:@"峰"];
    UILabel *partThreeLabel = [self getNameLabel:@"平"];
    UILabel *partFourLabel = [self getNameLabel:@"峰"];
    UILabel *partFiveLabel = [self getNameLabel:@"平"];
    
    [self.bgView addSubview:self.secondSubTitLabel];
    [self.bgView addSubview:self.firstSubTitLabel];
    [self.bgView addSubview:twentytwoToTwentyFourLable];
    [self.bgView addSubview:sevenTeenToTwentytwoLable];
    [self.bgView addSubview:elevenToSeventeenLable];
    [self.bgView addSubview:eightToElevenLable];
    [self.bgView addSubview:zeroToEightLable];
    [self.bgView addSubview:partOneLabel];
    [self.bgView addSubview:partTwoLabel];
    [self.bgView addSubview:partThreeLabel];
    [self.bgView addSubview:partFourLabel];
    [self.bgView addSubview:partFiveLabel];
    
    [self.firstSubTitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.xLineView.mas_bottom).offset(18);
        make.right.mas_equalTo(self.yLineView.mas_left).offset(-5);
    }];
    
    [self.secondSubTitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.firstSubTitLabel.mas_bottom).offset(2);
        make.right.mas_equalTo(self.yLineView.mas_left).offset(-5);
    }];
    
    [zeroToEightLable mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.xLineView.mas_bottom).offset(23);
        make.left.mas_equalTo(self.yLineView.mas_right).offset(0);
        make.height.mas_equalTo(12);
        make.width.mas_equalTo(kUnitWidth*8);
    }];
    
    [partOneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(zeroToEightLable.mas_bottom).offset(4);
        make.centerX.mas_equalTo(zeroToEightLable);
    }];
    
    [eightToElevenLable mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.xLineView.mas_bottom).offset(23);
        make.left.mas_equalTo(zeroToEightLable.mas_right).offset(-6);
        make.height.mas_equalTo(12);
        make.width.mas_equalTo(kUnitWidth*3+6);
    }];
    
    [partTwoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(eightToElevenLable.mas_bottom).offset(4);
        make.centerX.mas_equalTo(eightToElevenLable);
    }];
    
    [elevenToSeventeenLable mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.xLineView.mas_bottom).offset(23);
        make.left.mas_equalTo(eightToElevenLable.mas_right).offset(-6);
        make.height.mas_equalTo(12);
        make.width.mas_equalTo(kUnitWidth*6+6);
    }];
    
    [partThreeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(elevenToSeventeenLable.mas_bottom).offset(4);
        make.centerX.mas_equalTo(elevenToSeventeenLable);
    }];
    
    [sevenTeenToTwentytwoLable mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.xLineView.mas_bottom).offset(23);
        make.left.mas_equalTo(elevenToSeventeenLable.mas_right).offset(-6);
        make.height.mas_equalTo(12);
        make.width.mas_equalTo(kUnitWidth*5+6);
    }];
    
    [partFourLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(sevenTeenToTwentytwoLable.mas_bottom).offset(4);
        make.centerX.mas_equalTo(sevenTeenToTwentytwoLable);
    }];
    
    
    [twentytwoToTwentyFourLable mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.xLineView.mas_bottom).offset(23);
        make.left.mas_equalTo(sevenTeenToTwentytwoLable.mas_right).offset(-6);
        make.height.mas_equalTo(12);
        make.width.mas_equalTo(kUnitWidth*2+6);
    }];
    
    [partFiveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(twentytwoToTwentyFourLable.mas_bottom).offset(4);
        make.centerX.mas_equalTo(twentytwoToTwentyFourLable);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [zeroToEightLable radiusWithRadius:6 type:UIRectCornerBottomRight | UIRectCornerBottomLeft | UIRectCornerTopLeft | UIRectCornerTopRight];
        [eightToElevenLable radiusWithRadius:6 type:UIRectCornerTopRight | UIRectCornerBottomRight];
        [elevenToSeventeenLable radiusWithRadius:6 type:UIRectCornerTopRight | UIRectCornerBottomRight];
        [sevenTeenToTwentytwoLable radiusWithRadius:6 type:UIRectCornerTopRight | UIRectCornerBottomRight];
        [twentytwoToTwentyFourLable radiusWithRadius:6 type:UIRectCornerTopRight | UIRectCornerBottomRight];
    });
    
}

- (UILabel *)getStatisticsLabel:(NSString *)startColor endColor:(NSString *)endColor valueStr:(NSString *)value first:(BOOL)first {
    
    UILabel *statisticsLabel = [[UILabel alloc] init];
    statisticsLabel.alpha = 1;
    statisticsLabel.textAlignment = NSTextAlignmentCenter;
    statisticsLabel.font = FONT_SYSTEM(8);
    statisticsLabel.text = value;
    statisticsLabel.textColor = first ? COLOR_BLACK(1) : COLOR_WHITE(1);
    statisticsLabel.layer.masksToBounds = YES;
    [statisticsLabel az_setGradientBackgroundWithColors:@[COLOR_HEX(startColor),COLOR_HEX(endColor)] locations:@[@(0),@(1)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    return statisticsLabel;
}

- (UILabel *)getNameLabel:(NSString *)name {
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = name;
    nameLabel.font = FONT_SYSTEM(8);
    nameLabel.textColor = COLOR_WHITE(0.65);
    return nameLabel;
}

/* x轴坐标 */
- (void)addXScaleView {
    
    self.xLabelArray = [NSMutableArray array];
    UILabel *lastLabel;
    for (NSString *scale in self.xScaleArray) {
        UILabel *scaleLabel = [self getScaleLabel:scale x:YES];
        [self.xLabelArray addObject:scaleLabel];
        [self.bgView addSubview:scaleLabel];
        if (lastLabel == nil)
        {
            [scaleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.mas_equalTo(self.bgView).offset(31);
                make.top.mas_equalTo(self.yLineView.mas_bottom).offset(4);
                make.width.mas_equalTo(6);
            }];
        }else
        {
            [scaleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.mas_equalTo(lastLabel.mas_right).offset(0);
                make.top.mas_equalTo(self.yLineView.mas_bottom).offset(4);
                make.width.mas_equalTo(kUnitWidth);
            }];
        }
        lastLabel = scaleLabel;
    }
}

/* 分类 */
- (void)addPowerCategory {
    
    UIView *powerGridView = [self getPointView:@"#DAEDFF" endColor:@"#B3DBFF" title:@"电网供电"];
    UIView *energyStorageView = [self getPointView:@"#23BD7E" endColor:@"#59D5A2" title:@"储能放电"];
    UIView *photovoltaicView = [self getPointView:@"#32ADFF" endColor:@"#477FFF" title:@"光伏发电"];
    [self.bgView addSubview:photovoltaicView];
    [self.bgView addSubview:energyStorageView];
    [self.bgView addSubview:powerGridView];

    [photovoltaicView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(self.bgView).offset(-12);
        make.top.mas_equalTo(self.lineView.mas_bottom).offset(12);
    }];
    
    [energyStorageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(photovoltaicView.mas_left).offset(-16);
        make.top.mas_equalTo(self.lineView.mas_bottom).offset(12);
    }];
    
    [powerGridView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(energyStorageView.mas_left).offset(-16);
        make.top.mas_equalTo(self.lineView.mas_bottom).offset(12);
    }];
}

/* 能量柱 */
- (UIView *)getEnergyColumnView:(NSString *)startColor endColor:(NSString *)endColor {
    
    UIView *energyView = [[UIView alloc] init];
    [energyView az_setGradientBackgroundWithColors:@[COLOR_HEX(startColor),COLOR_HEX(endColor)] locations:@[@(0),@(1)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    return energyView;
}

/* 坐标单位label */
- (UILabel *)getScaleLabel:(NSString *)value x:(BOOL)x {
    
    UILabel *scaleLabel = [[UILabel alloc] init];
    scaleLabel.text = value;
    scaleLabel.font = FONT_SYSTEM(8);
    scaleLabel.textColor = COLOR_WHITE(0.65);
    scaleLabel.textAlignment = NSTextAlignmentCenter;
    if ([value intValue]%2 == 1 && x == YES)
    {
        scaleLabel.hidden = YES;
    }
    return scaleLabel;
}

/* 分类view */
- (UIView *)getPointView:(NSString *)startColor endColor:endColor title:(NSString *)title {
    
    UIView *bgView = [[UIView alloc] init];
    UIView *pointView = [[UIView alloc] init];
    pointView.layer.cornerRadius = 3;
    [pointView az_setGradientBackgroundWithColors:@[COLOR_HEX(startColor),COLOR_HEX(endColor)] locations:@[@(0),@(1)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = FONT_SYSTEM(10);
    titleLabel.textColor = COLOR_WHITE(0.85);
    
    [bgView addSubview:pointView];
    [bgView addSubview:titleLabel];
    
    [pointView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(bgView).offset(0);
        make.height.width.mas_equalTo(6);
        make.centerY.mas_equalTo(bgView.mas_centerY);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(pointView.mas_right).offset(4);
        make.right.top.bottom.mas_equalTo(bgView).offset(0);
    }];
    
    return bgView;
}

- (UIView *)bgView {
    
    if (_bgView == nil)
    {
        _bgView = [[UIView alloc]init];
        _bgView.layer.cornerRadius = 8;
        _bgView.layer.masksToBounds = YES;
        _bgView.layer.borderWidth = 1;
        _bgView.layer.borderColor = COLOR_WHITE(0.08).CGColor;
        [_bgView az_setGradientBackgroundWithColors:@[COLOR_HEX(@"#484E5A"),COLOR_HEX(@"#363A43")] locations:@[@(0),@(1)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    }
    return _bgView;
}

- (UILabel *)titleLabel {
    
    if (_titleLabel == nil)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"用电构成";
        _titleLabel.font = FONT_MEDIUM_SYETEM(14);
        _titleLabel.textColor = COLOR_WHITE(0.85);
    }
    return _titleLabel;
}


- (UIView *)lineView {
    
    if (_lineView == nil)
    {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = COLOR_WHITE(0.06);
    }
    return _lineView;
}

- (UILabel *)unitLabel {
    
    if (_unitLabel == nil)
    {
        _unitLabel = [[UILabel alloc] init];
        _unitLabel.text = @"kWh";
        _unitLabel.font = FONT_SYSTEM(8);
        _unitLabel.textColor = COLOR_WHITE(0.45);
    }
    return _unitLabel;
}

- (UILabel *)xUnitLabel {
    
    if (_xUnitLabel == nil)
    {
        _xUnitLabel = [[UILabel alloc] init];
        _xUnitLabel.text = @"小时";
        _xUnitLabel.font = FONT_SYSTEM(8);
        _xUnitLabel.textColor = COLOR_WHITE(0.45);
    }
    return _xUnitLabel;
}

- (UIView *)yLineView {
    
    if (_yLineView == nil)
    {
        _yLineView = [[UIView alloc]init];
        _yLineView.backgroundColor = COLOR_WHITE(0.06);
    }
    return _yLineView;
}

- (UIView *)xLineView {
    
    if (_xLineView == nil)
    {
        _xLineView = [[UIView alloc]init];
        _xLineView.backgroundColor = COLOR_WHITE(0.06);
    }
    return _xLineView;
}

- (UIView *)centerLineView {
    
    if (_centerLineView == nil)
    {
        _centerLineView = [[UIView alloc]init];
        _centerLineView.backgroundColor = COLOR_WHITE(0.06);
    }
    return _centerLineView;
}

- (NSMutableArray *)xScaleArray {
    
    if (_xScaleArray == nil)
    {
        _xScaleArray = [NSMutableArray array];
        for (int i = 0; i < 25; i++) {
            [_xScaleArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return _xScaleArray;
}

- (NSMutableArray *)yScaleArray {
    
    if (_yScaleArray == nil)
    {
        _yScaleArray = [NSMutableArray array];
    }
    return _yScaleArray;
}

- (UILabel *)firstSubTitLabel {
    
    if (_firstSubTitLabel == nil)
    {
        _firstSubTitLabel = [[UILabel alloc] init];
        _firstSubTitLabel.text = @"用电";
        _firstSubTitLabel.font = FONT_SYSTEM(8);
        _firstSubTitLabel.textColor = COLOR_WHITE(0.65);
    }
    return _firstSubTitLabel;
}

- (UILabel *)secondSubTitLabel {
    
    if (_secondSubTitLabel == nil)
    {
        _secondSubTitLabel = [[UILabel alloc] init];
        _secondSubTitLabel.text = @"占比";
        _secondSubTitLabel.font = FONT_SYSTEM(8);
        _secondSubTitLabel.textColor = COLOR_WHITE(0.65);
    }
    return _secondSubTitLabel;
}

@end

