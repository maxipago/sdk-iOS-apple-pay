//
//  TKFormSelectorPushCell.m
//  ADYWallet
//
//  Created by Leandro Souza 9/12/14.
//  Copyright (c) 2017 Taras Kalapun. All rights reserved.
//

#import "TKFormSelectorPushCell.h"
#import "TKFormViewController.h"
#import "TKForm.h"
#import "TKFormRow.h"
#import "TKFormCells.h"

@interface TKFormSelectorPushCell () <TKFormDelegate>

@property (nonatomic, strong) TKFormViewController *subController;
@property (nonatomic, strong) TKFormRow *selectedRow;

@end

static NSString* const TKFormSelectorPushCellReuseIdentifier = @"SelectorPushCell";
@implementation TKFormSelectorPushCell

- (instancetype)initWithRow:(TKFormRow *)row {
    return [self initWithReuseIdentifier:TKFormSelectorPushCellReuseIdentifier row:row];
}


- (void)configure {
    [super configure];
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)update {
    [super update];
    
    if (self.row.selectorOptionsDictionary) {
        NSString *detailText = self.row.selectorOptionsDictionary[self.value];
//        if (detailText == nil) {
//            detailText = self.row.selectorOptionsDictionary.allValues[0];
//        }
        self.detailTextLabel.text = detailText;
    } else {
        self.detailTextLabel.text = [self.value description];
    }
}

- (void)setSelected:(BOOL)selected {
}

- (void)controlValueChanged:(id)sender {
    
    self.subController = [[TKFormViewController alloc] init];
    self.subController.title = self.row.title;
    
    TKForm *form = self.subController.form;
    [self configureSubForm:form];
    
    [self.formViewController pushViewController:self.subController animated:YES];
}

- (void)configureSubForm:(TKForm *)form {
    form.delegate = self;
    
    TKFormRow *row;
    
    if (self.row.selectorOptionsDictionary) {
        for (id key in self.row.selectorOptionsDictionary) {
            NSString *title = self.row.selectorOptionsDictionary[key];
            
            row = [TKFormRow switchWithTag:key type:TKFormRowSwitchTypeCheck title:title value:NO];
            [form addRow:row];
            if ([[self.value description] isEqualToString:[key description]]) {
                row.value = @YES;
                self.selectedRow = row;
            }
            
            if (self.row.hasImage) {
                row.hasImage = YES;
                row.image = key;
                row.imagePath = self.row.imagePath;
            }
            
        }
    } else {
        int i = 0;
        for (id value in self.row.selectorOptions) {
            NSString *tag = [NSString stringWithFormat:@"%i", i];
            
            row = [TKFormRow switchWithTag:tag type:TKFormRowSwitchTypeCheck title:[value description] value:NO];
            [form addRow:row];
            if ([[self.value description] isEqualToString:[value description]]) {
                row.value = @YES;
                self.selectedRow = row;
            }
            i++;
        }
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [self controlValueChanged:nil];
    }
}

- (void)formDidSelectRow:(TKFormRow *)row {
    self.subController.form.delegate = nil;
    if (self.selectedRow) {
        self.selectedRow.value = @NO;
    }
    
    if (self.row.selectorOptionsDictionary) {
        self.row.value = row.tag; //self.row.selectorOptionsDictionary[row.tag];
    } else {
        NSUInteger index = [row.tag integerValue];
        self.row.value = self.row.selectorOptions[index];        
    }
    
    [self.formViewController popViewController:self.subController animated:YES];
    
    self.selectedRow = nil;
    self.subController = nil;
    [self update];
}

@end
