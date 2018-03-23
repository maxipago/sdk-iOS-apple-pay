//
//  TKFormCell.h
//  ADYWallet
//
//  Created by Leandro Souza 9/10/14.
//  Copyright (c) 2017 Taras Kalapun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TKFormViewController, TKFormRow;
@interface TKFormCell : UITableViewCell

@property (nonatomic, weak) TKFormRow *row;
@property (nonatomic, weak) TKFormViewController *controller;

// Fast acessors
@property (nonatomic, weak) id value;
@property (nonatomic, assign) BOOL disabled;

- (instancetype)initWithRow:(TKFormRow *)row;
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier row:(TKFormRow *)row;

- (void)configure;
- (void)update;

- (UIView *)doneInputAccessoryView;

- (TKFormViewController *)formViewController;

//- (BOOL)formCellBecomeFirstResponder;
//- (BOOL)formCellResignFirstResponder;
- (void)formCellDidSelectedWithFormController:(TKFormViewController *)controller;

- (void)controlValueChanged:(id)sender;

@end
