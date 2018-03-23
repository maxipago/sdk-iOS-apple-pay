//
//  TKFormDateCell.m
//  ADYWallet
//
//  Created by Leandro Souza 9/12/14.
//  Copyright (c) 2017 Taras Kalapun. All rights reserved.
//

#import "TKFormDateCell.h"
#import "TKFormRow.h"

static NSString* const TKFormDateCellReuseIdentifier = @"DateCell";

@implementation TKFormDateCell

- (instancetype)initWithRow:(TKFormRow *)row {
    return [self initWithReuseIdentifier:TKFormDateCellReuseIdentifier row:row];
}

- (void)configure {
    [super configure];
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.datePicker = [[UIDatePicker alloc] init];
    [self.datePicker addTarget:self action:@selector(controlValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)update {
    [super update];
    
    self.detailTextLabel.text = [self.value description];
}

- (void)controlValueChanged:(UIControl *)control {
    self.row.value = self.datePicker.date;
    [self update];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (selected) {
        [self becomeFirstResponder];
    }
    //[super setSelected:NO animated:animated];
    
}

- (void)formDescriptorCellDidSelectedWithFormController:(TKFormViewController *)controller
{
    [self becomeFirstResponder];
}

- (UIView *)inputAccessoryView {
    return [self doneInputAccessoryView];
}

- (UIView *)inputView {
    if (self.value){
        [self.datePicker setDate:self.value];
    }
    return self.datePicker;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}


@end
