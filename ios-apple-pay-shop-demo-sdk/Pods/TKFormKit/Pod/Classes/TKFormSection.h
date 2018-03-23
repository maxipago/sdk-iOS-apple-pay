//
//  TKFormSection.h
//  ADYWallet
//
//  Created by Leandro Souza 9/10/14.
//  Copyright (c) 2017 Taras Kalapun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TKForm, TKFormRow;
@interface TKFormSection : NSObject

@property (nonatomic, weak) TKForm *form;

@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *footerTitle;

@property (nonatomic, assign) BOOL hidden;

@property (nonatomic, readonly) NSMutableArray *rows;


@property (nonatomic, assign) BOOL isMultivaluedSection;
@property (nonatomic, strong) NSString *multiValuedTag;


+ (instancetype)section;
+ (instancetype)sectionWithTitle:(NSString *)title;
+ (instancetype)sectionWithTitle:(NSString *)title tag:(NSString *)tag;

- (TKFormRow *)addRow:(TKFormRow *)row;
- (void)addRow:(TKFormRow *)row afterRow:(TKFormRow *)afterRow;
- (void)addRow:(TKFormRow *)row beforeRow:(TKFormRow *)beforeRow;
- (void)removeRowAtIndex:(NSUInteger)index;
- (void)removeRow:(TKFormRow *)row;

- (CGFloat)estimatedMaxRowTitleWidth;

- (NSUInteger)visibleRowsCount;
- (TKFormRow *)visibleRowAtIndex:(NSUInteger)index;

@end
