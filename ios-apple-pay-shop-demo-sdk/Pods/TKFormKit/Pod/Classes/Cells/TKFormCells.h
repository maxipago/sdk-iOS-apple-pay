//
//  TKFormCells.h
//  ADYWallet
//
//  Created by Leandro Souza 9/10/14.
//  Copyright (c) 2017 Taras Kalapun. All rights reserved.
//

#import "TKFormCell.h"
#import "TKFormDateCell.h"
#import "TKFormSelectorPushCell.h"
#import "TKFormInputCell.h"

@class MoneyInputLabel;

@interface TKFormInfoCell : TKFormCell
@end

@interface TKFormSwitchCell : TKFormCell
@property (nonatomic, strong) UISwitch *switchControl;
@end

@interface TKFormSwitchCheckCell : TKFormCell
@end

@interface TKFormButtonCell : TKFormCell
@end

@interface TKFormSegmentedCell : TKFormCell
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@end

@interface TKFormStepCounterCell : TKFormCell
@property (nonatomic, strong) UIStepper *stepControl;
@end
