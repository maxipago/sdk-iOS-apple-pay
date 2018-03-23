//
//  TKFormInputCell.m
//  maxiPago!POSTerminal
//
//  Created by Leandro Souza 9/15/14.
//
//

#import "TKFormInputCell.h"
#import "TKForm.h"
#import "TKFormStyle.h"
#import "TKFormRow.h"

static NSString* const TKFormEditableCellReuseIdentifier = @"EditableCell";

@interface TKFormInputCell () <UITextFieldDelegate>
@end

@implementation TKFormInputCell

- (instancetype)initWithRow:(TKFormRow *)row {
    return [self initWithReuseIdentifier:TKFormEditableCellReuseIdentifier row:row];
}

- (void)configure {
    [super configure];
    
    CGFloat width = 150;
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    self.textField.textColor = [TKFormStyle darkGreyColor];
    self.textField.font = [TKFormStyle textFont];
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.delegate = self;
    self.accessoryView = self.textField;
}

- (void)update {
    [super update];
    self.textField.text = [self.value description];
    self.textField.enabled = !self.disabled;
    
    self.textField.secureTextEntry = NO;
    self.textField.keyboardType = UIKeyboardTypeDefault;
    
    if (self.row.inputType == TKFormRowInputTypePin) {
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        self.textField.secureTextEntry = YES;
    }
    else if (self.row.inputType == TKFormRowInputTypePassword) {
        self.textField.keyboardType = UIKeyboardTypeASCIICapable;
        self.textField.secureTextEntry = YES;
    }
    else if (self.row.inputType == TKFormRowInputTypeEmail) {
        self.textField.keyboardType = UIKeyboardTypeEmailAddress;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    
    CGFloat maxTitleWidth = (self.row.title.length > 0) ? [self.row estimatedMaxRowTitleWidthInSection] : 0;
    CGFloat w = self.bounds.size.width - maxTitleWidth - 50;
    if (maxTitleWidth == 0) {
        w += 20;
    }
    
    CGRect rect = self.textField.frame;
    rect.size.width = w;
    self.textField.frame = rect;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.row.value = textField.text;
}

- (UIView *)inputAccessoryView {
    return [self doneInputAccessoryView];
}

- (void)doneAcessoryButtonPressed:(id)sender {
    self.row.value = self.textField.text;
    [self.textField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.row.inputType != TKFormRowInputTypePin) {
        return YES;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 4) ? NO : YES;
}

@end
