//
//  TKFormRow.m
//  ADYWallet
//
//  Created by Leandro Souza 9/10/14.
//  Copyright (c) 2017 Taras Kalapun. All rights reserved.
//

#import "TKFormRow.h"
#import "TKFormDefines.h"
#import "TKFormSection.h"

#import "TKFormCell.h"
#import "TKFormCells.h"
#import "TKFormStyle.h"

@interface TKFormRow ()
@property TKFormCell *cell;
@end

@implementation TKFormRow

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initDefaults];
    }
    return self;
}

+ (instancetype)rowWithTag:(NSString *)tag type:(TKFormRowType)type {
    return [self rowWithTag:tag type:type title:nil];
}

+ (instancetype)rowWithTag:(NSString *)tag type:(TKFormRowType)type title:(NSString *)title {
    TKFormRow *row = [[TKFormRow alloc] init];
    row.tag = tag;
    row.type = type;
    row.title = title;
    return row;
}

+ (instancetype)infoWithTag:(NSString *)tag title:(NSString *)title value:(id)value {
    TKFormRow *row = [[TKFormRow alloc] init];
    row.tag = tag;
    row.type = TKFormRowTypeInfo;
    row.title = title;
    row.value = value;
    return row;
}

+ (instancetype)switchWithTag:(NSString *)tag title:(NSString *)title value:(BOOL)value {
    return [self switchWithTag:tag type:TKFormRowSwitchTypeSwitch title:title value:value];
}

+ (instancetype)switchWithTag:(NSString *)tag type:(TKFormRowSwitchType)type title:(NSString *)title value:(BOOL)value {
    TKFormRow *row = [[TKFormRow alloc] init];
    row.tag = tag;
    row.type = TKFormRowTypeSwitch;
    row.switchType = type;
    row.title = title;
    row.value = @(value);
    return row;
}

+ (instancetype)inputWithTag:(NSString *)tag title:(NSString *)title value:(id)value {
    return [self inputWithTag:tag type:TKFormRowInputTypeText title:title value:value];
}

+ (instancetype)inputWithTag:(NSString *)tag type:(TKFormRowInputType)type title:(NSString *)title value:(id)value {
    return [self inputWithTag:tag type:type title:title placeholder:nil value:value];
}

+ (instancetype)inputWithTag:(NSString *)tag type:(TKFormRowInputType)type title:(NSString *)title placeholder:(NSString *)placeholder value:(id)value {
    TKFormRow *row = [TKFormRow rowWithTag:tag type:TKFormRowTypeInput title:title];
    row.inputType = type;
    if (placeholder.length > 0) (row.cellConfig)[@"textField.placeholder"] = placeholder;
    row.required = NO;
    row.value = value;
    return row;
}

+ (instancetype)buttonWithTitle:(NSString *)title vcClass:(Class)vcClass {
    TKFormRow *row = [TKFormRow rowWithTag:nil type:TKFormRowTypeButton title:title];
    if (vcClass) {
        row.viewControllerClass = vcClass;
    }

    return row;
}

+ (instancetype)selectorWithTag:(NSString *)tag title:(NSString *)title value:(id)value {
    return [self selectorWithTag:tag type:TKFormRowSelectorTypePush title:title value:value];
}

+ (instancetype)selectorWithTag:(NSString *)tag type:(TKFormRowSelectorType)type title:(NSString *)title value:(id)value {
    TKFormRow *row = [TKFormRow rowWithTag:tag type:TKFormRowTypeSelector title:title];
    row.selectorType = type;
    //[row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.required = NO;
    row.value = value;
    return row;
}

- (void)initDefaults {
    self.toggleSectionTags = nil; //NSMutableArray.new;
    self.toggleRowTags = nil;     //NSMutableArray.new;
    self.cellConfig = NSMutableDictionary.new;
}

+ (void)registerCellClass:(Class)cellClass forRowType:(NSString *)type {
}

- (void)configureCell:(TKFormCell *)cell {
}

- (Class)formCellClass {

    if (self.customCellClass) {
        return self.customCellClass;
    }
    switch (self.type) {
    case TKFormRowTypeInput: {
//        if (self.inputType == TKFormRowInputTypeMoney) {
//            return TKFormInputMoneyCell.class;
//        }
        return TKFormInputCell.class;
    } break;
    case TKFormRowTypeButton:
        return TKFormButtonCell.class;
        break;
    case TKFormRowTypeInfo:
        return TKFormInfoCell.class;
        break;
    case TKFormRowTypeSelector: {
        if (self.selectorType == TKFormRowSelectorTypeSegmented) {
            return TKFormSegmentedCell.class;
        } else { //if (self.selectorType == TKFormRowSelectorTypePush) {
            return TKFormSelectorPushCell.class;
        }
    } break;
    case TKFormRowTypeSwitch: {
        if (self.switchType == TKFormRowSwitchTypeCheck) {
            return TKFormSwitchCheckCell.class;
        } else { //if (self.switchType == TKFormRowSwitchTypeSwitch) {
            return TKFormSwitchCell.class;
        }
    } break;
    case TKFormRowTypeStepCounter:
        return TKFormStepCounterCell.class;
        break;
    case TKFormRowTypeDate:
        return TKFormDateCell.class;
        break;
    default:
        break;
    }

    return TKFormCell.class;
}

- (TKFormCell *)cellForFormController:(TKFormViewController *)formController {
    if (_cell) return _cell;
    _cell = [[self.formCellClass alloc] initWithRow:self];
    [self configureCell:_cell];
    [self.cellConfig enumerateKeysAndObjectsUsingBlock:^(NSString *keyPath, id value, __unused BOOL *stop) {
        [_cell setValue:value forKeyPath:keyPath];
    }];
    if (self.actionSelector) {
        _cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    return _cell;
}

- (CGFloat)estimatedTitleWidth {
    CGSize size = CGSizeZero;
    size = [self.title sizeWithAttributes:@{NSFontAttributeName : [TKFormStyle textFont]}];
    return size.width;
}

- (CGFloat)estimatedMaxRowTitleWidthInSection {
    return [self.section estimatedMaxRowTitleWidth];
}

- (void)setType:(TKFormRowType)type {
    if (self.cell && _type != type) {
        self.cell = nil;
    }
    _type = type;
}

- (void)updateCell {
    if (self.cell) {
        [self.cell update];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%li: %@", (long) self.type, self.title];
}

@end
