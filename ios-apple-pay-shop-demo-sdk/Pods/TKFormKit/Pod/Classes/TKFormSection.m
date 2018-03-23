//
//  TKFormSection.m
//  ADYWallet
//
//  Created by Leandro Souza 9/10/14.
//  Copyright (c) 2017 Taras Kalapun. All rights reserved.
//

#import "TKFormSection.h"
#import "TKForm.h"
#import "TKFormRow.h"

@interface TKFormSection ()
@property (nonatomic, strong, readwrite) NSMutableArray *rows;
@end

@implementation TKFormSection

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initDefaults];
    }
    return self;
}

+ (instancetype)section {
    return [self sectionWithTitle:nil tag:nil];
}

+ (instancetype)sectionWithTitle:(NSString *)title {
    return [self sectionWithTitle:title tag:nil];
}

+ (instancetype)sectionWithTitle:(NSString *)title tag:(NSString *)tag {
    TKFormSection *section = [[self alloc] init];
    section.tag = tag;
    section.title = title;
    return section;
}

- (void)initDefaults {
    self.rows = NSMutableArray.new;

}

//- (NSArray *)visibleRows {
//    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.rows.count];
//    for (TKFormRow *row in self.rows) {
//        if (!row.hidden) [array addObject:row];
//    }
//    return array;
//}

#pragma mark - Row manipulation

- (TKFormRow *)addRow:(TKFormRow *)row {
    [self insertObject:row inRowsAtIndex:self.rows.count];
    return row;
}

- (void)addRow:(TKFormRow *)row afterRow:(TKFormRow *)afterRow {
    NSUInteger index = NSNotFound;
    if ((index =  [self.rows indexOfObject:afterRow]) != NSNotFound) {
        [self insertObject:row inRowsAtIndex:index + 1];
    } else {
        [self addRow:row];
    }
}

- (void)addRow:(TKFormRow *)row beforeRow:(TKFormRow *)beforeRow {
    NSUInteger index = NSNotFound;
    if ((index =  [self.rows indexOfObject:beforeRow]) != NSNotFound) {
        [self insertObject:row inRowsAtIndex:index];
    } else {
        [self addRow:row];
    }
}

- (void)removeRowAtIndex:(NSUInteger)index {
    if (self.rows.count > index){
        [self removeObjectFromRowsAtIndex:index];
    }
}

- (void)removeRow:(TKFormRow *)row {
    NSUInteger index = NSNotFound;
    if ((index = [self.rows indexOfObject:row]) != NSNotFound) {
        [self removeRowAtIndex:index];
    }
}

- (void)dealloc {
    for (TKFormRow *row in self.rows) {
        @try {
            [row removeObserver:self forKeyPath:@"value"];
        }
        @catch (NSException * __unused exception) {}
    }
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[TKFormRow class]] && [keyPath isEqualToString:@"value"]){
        if ([change[NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeSetting)]){
            id newValue = change[NSKeyValueChangeNewKey];
            id oldValue = change[NSKeyValueChangeOldKey];
            [self.form rowValueHasChanged:object oldValue:oldValue newValue:newValue];
        }
    }
}


#pragma mark - KVC

- (NSUInteger)countOfRows {
    return self.rows.count;
}

- (void)insertObject:(TKFormRow *)row inRowsAtIndex:(NSUInteger)index {
    row.section = self;
    [row addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:0];
    [self.rows insertObject:row atIndex:index];
}

- (void)removeObjectFromRowsAtIndex:(NSUInteger)index {
    TKFormRow *row = (self.rows)[index];
    @try {
        [row removeObserver:self forKeyPath:@"value"];
    }
    @catch (NSException * __unused exception) {}
    [self.rows removeObjectAtIndex:index];
}

- (CGFloat)estimatedMaxRowTitleWidth {
    CGFloat width = 0;
    for (TKFormRow *row in self.rows) {
        if (row.type != TKFormRowTypeInput) {
            continue;
        }
        CGFloat w = [row estimatedTitleWidth];
        if (w > width) width = w;
    }
    return width;
}

- (NSUInteger)visibleRowsCount {
    NSUInteger i = 0;
    for (TKFormRow *row in self.rows) {
        if (!row.hidden) i++;
    }
    return i;
}

- (TKFormRow *)visibleRowAtIndex:(NSUInteger)index {
    NSUInteger i = 0;
    index++;
    for (TKFormRow *row in self.rows) {
        if (!row.hidden) i++;
        if (i == index) {
            return row;
        }
    }
    return nil;
}

@end
