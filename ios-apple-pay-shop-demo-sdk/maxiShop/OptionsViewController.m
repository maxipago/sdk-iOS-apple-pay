//
//  OptionsViewController.m
//  Shop
//
//  Created by Taras Kalapun on 11/10/14.
//  Copyright (c) 2014 maxiPago!. All rights reserved.
//

#import "OptionsViewController.h"
#import "DB.h"

@interface OptionsViewController ()

@end

@implementation OptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    TKForm *form = self.form;
    TKFormRow *row;
    
    NSString *version = [NSString stringWithFormat:@"%@ (%@)",
                         [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"],
                         [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"]];
    
    [form addRow:[TKFormRow inputWithTag:@"Version" title:@"Version" value:version]];

    row = [TKFormRow selectorWithTag:@"currency" type:TKFormRowSelectorTypeSegmented title:@"Currency" value:@"GBP"];
    row.selectorOptions = @[@"USD", @"EUR", @"GBP"];
    [form addRow:row];
    
}

- (void)rowValueHasChanged:(TKFormRow *)row oldValue:(id)oldValue newValue:(id)newValue {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([row.tag isEqualToString:@"currency"]) {
        [DB shared].currency = newValue;
    } else if ([row.tag isEqualToString:@"token"]) {
        [ud setObject:newValue forKey:@"token"];
        [ud synchronize];
    }
}

@end
