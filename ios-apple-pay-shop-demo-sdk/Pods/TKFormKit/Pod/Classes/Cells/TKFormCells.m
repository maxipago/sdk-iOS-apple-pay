//
//  TKFormCells.m
//  ADYWallet
//
//  Created by Leandro Souza 9/10/14.
//  Copyright (c) 2017 Taras Kalapun. All rights reserved.
//

#import "TKFormCells.h"
#import "TKFormStyle.h"
#import "TKFormRow.h"

static NSString* const TKFormReadOnlyCellReuseIdentifier = @"InfoCell";
@implementation TKFormInfoCell

- (instancetype)initWithRow:(TKFormRow *)row {
    return [self initWithReuseIdentifier:TKFormReadOnlyCellReuseIdentifier row:row];
}

- (void)configure {
    [super configure];
}

- (void)update {
    [super update];
    self.detailTextLabel.text = [self.value description];
}

@end

static NSString* const TKFormOnSwitchReuseIdentifier = @"SwitchCell";
@implementation TKFormSwitchCell

- (instancetype)initWithRow:(TKFormRow *)row {
    return [self initWithReuseIdentifier:TKFormOnSwitchReuseIdentifier row:row];
}

- (void)configure {
    [super configure];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.switchControl = [[UISwitch alloc] init];
    self.accessoryView = self.switchControl;
    [self.switchControl addTarget:self action:@selector(controlValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)update {
    [super update];
    self.switchControl.on = [self.value boolValue];
    self.switchControl.enabled = !self.disabled;
}

- (void)controlValueChanged:(UIControl *)control {
    self.row.value = @(self.switchControl.on);
}


@end

static NSString* const TKFormSwitchCheckCellReuseIdentifier = @"SwitchCheck";
@implementation TKFormSwitchCheckCell

- (instancetype)initWithRow:(TKFormRow *)row {
    return [self initWithReuseIdentifier:TKFormSwitchCheckCellReuseIdentifier row:row];
}

- (void)configure {
    [super configure];
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.accessoryType = UITableViewCellAccessoryNone; //Checkmark
}

- (void)update {
    [super update];
    self.selectionStyle = (!self.disabled) ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    self.accessoryType = ([self.value boolValue]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)controlValueChanged:(UIControl *)control {
    if (self.accessoryType == UITableViewCellAccessoryNone) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
        self.row.value = @YES;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.row.value = @NO;
    }

}

- (void)setSelected:(BOOL)selected {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];
    [self controlValueChanged:nil];
}

@end

static NSString* const TKFormButtonCellReuseIdentifier = @"ButtonCell";

@implementation TKFormButtonCell

- (instancetype)initWithRow:(TKFormRow *)row {
    TKFormButtonCell *cell = nil;
    UITableViewCellStyle style = (row.value) ? UITableViewCellStyleValue1 : (row.details) ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault;
    cell = [self initWithStyle:style reuseIdentifier:TKFormButtonCellReuseIdentifier];
    cell.row = row;
    return cell;
}

- (void)configure {
    [super configure];
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
}

- (void)update {
    [super update];
    if (self.row.viewControllerClass) {
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.textColor = (self.row.cellConfig[@"textLabel.textColor"]) ? self.row.cellConfig[@"textLabel.textColor"] : [TKFormStyle textColor];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.textLabel.textColor = (self.row.cellConfig[@"textLabel.textColor"]) ? self.row.cellConfig[@"textLabel.textColor"] : [TKFormStyle tintColor];
    }
}


@end

static NSString* const TKFormStepCounterCellReuseIdentifier = @"StepCounterCell";
@implementation TKFormStepCounterCell

- (instancetype)initWithRow:(TKFormRow *)row {
    return [self initWithReuseIdentifier:TKFormStepCounterCellReuseIdentifier row:row];
}

- (void)configure {
    [super configure];
    self.stepControl = [[UIStepper alloc] init];
    [self.stepControl addTarget:self action:@selector(controlValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.accessoryView = self.stepControl;
    //self.detailTextLabel.textAlignment = NSTextAlignmentRight;
    [self.stepControl sizeToFit];
}

- (void)update {
    [super update];
    self.stepControl.value = [self.value doubleValue];
    self.stepControl.enabled = !self.disabled;
    
    double stepValue = self.stepControl.value;
    if (stepValue == floorf(stepValue)) {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", stepValue];
    } else {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", stepValue];
    }
}

- (void)controlValueChanged:(UIControl *)control {
    self.row.value = @(self.stepControl.value);
    [self update];
}

@end

static NSString* const TKFormSegmentedCellReuseIdentifier = @"SegmentedCell";
@implementation TKFormSegmentedCell

- (instancetype)initWithRow:(TKFormRow *)row {
    return [self initWithReuseIdentifier:TKFormSegmentedCellReuseIdentifier row:row];
}

- (void)configure {
    [super configure];
    self.segmentedControl = [[UISegmentedControl alloc] init];
    self.accessoryView = self.segmentedControl;
    [self.segmentedControl addTarget:self action:@selector(controlValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)update {
    [super update];
    
    [self.segmentedControl removeAllSegments];
    NSString *valueString = [self.value description];
    NSUInteger i = 0;
    for (id obj in self.row.selectorOptions) {
        NSString *title = [obj description];
        [self.segmentedControl insertSegmentWithTitle:title atIndex:i animated:NO];
        if ([valueString isEqualToString:title]) {
            [self.segmentedControl setSelectedSegmentIndex:i];
        }
        i++;
    }
    [self.segmentedControl sizeToFit];
    
    self.segmentedControl.enabled = !self.disabled;
}

- (void)controlValueChanged:(UIControl *)control {
    NSInteger index = self.segmentedControl.selectedSegmentIndex;
    self.row.value = self.row.selectorOptions[index];
}

@end

