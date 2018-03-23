//
//  TKForm.m
//  ADYWallet
//
//  Created by Leandro Souza 9/10/14.
//  Copyright (c) 2017 Taras Kalapun. All rights reserved.
//

#import "TKForm.h"
#import "TKFormSection.h"
#import "TKFormRow.h"
#import "TKFormViewController.h"

@interface TKForm ()
@property (nonatomic, strong) NSMutableArray *sections;
@end

@implementation TKForm

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initDefaults];
    }
    return self;
}

- (void)initDefaults {
    self.sections = NSMutableArray.new;
    [self addObserver:self forKeyPath:@"sections" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:0];
}

+ (instancetype)form {
    return [[self alloc] init];
}



#pragma mark - Section manipulation

- (TKFormSection *)addSectionWithTitle:(NSString *)title {
    return [self addSection:[TKFormSection sectionWithTitle:title]];
}

- (TKFormSection *)addSection:(TKFormSection *)section {
    [self insertObject:section inSectionsAtIndex:self.sections.count];
    return section;
}

- (void)addSection:(TKFormSection *)section afterSection:(TKFormSection *)afterSection {
    NSUInteger index = NSNotFound;
    if ((index =  [self.sections indexOfObject:afterSection]) != NSNotFound) {
        [self insertObject:section inSectionsAtIndex:index + 1];
    } else {
        [self addSection:section];
    }
}

//- (void)addSection:(TKFormSection *)section beforeSection:(TKFormSection *)beforeSection {
//    [self add]
////    NSUInteger index = NSNotFound;
////    if ((index =  [self.sections indexOfObject:beforeSection]) != NSNotFound) {
////        [self insertObject:section inSectionsAtIndex:index];
////    } else {
////        [self addSection:section];
////    }
//}

- (void)removeSectionAtIndex:(NSUInteger)index {
    if (self.sections.count > index){
        [self removeObjectFromSectionsAtIndex:index];
    }
}

- (void)removeSection:(TKFormSection *)section {
    NSUInteger index = NSNotFound;
    if ((index = [self.sections indexOfObject:section]) != NSNotFound) {
        [self removeSectionAtIndex:index];
    }
}

- (void)addRow:(TKFormRow *)row {
    if (self.sections.count == 0) {
        [self addSection:[TKFormSection section]];
    }
    TKFormSection *section = self.sections.lastObject;
    [section addRow:row];
}

- (void)dealloc {
    for (TKFormSection *section in self.sections) {
        @try {
            [section removeObserver:self forKeyPath:@"rows"];
        }
        @catch (NSException * __unused exception) {}
    }
    @try {
        [self removeObserver:self forKeyPath:@"sections"];
    }
    @catch (NSException * __unused exception) {}
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //if (!self.delegate) return;
    if ([keyPath isEqualToString:@"sections"]){
        if ([change[NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeInsertion)]){
            NSIndexSet *indexSet = change[NSKeyValueChangeIndexesKey];
            TKFormSection *section = (self.sections)[indexSet.firstIndex];
            [self sectionHasBeenAdded:section atIndex:indexSet.firstIndex];
        }
        else if ([change[NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeRemoval)]){
            NSIndexSet *indexSet = change[NSKeyValueChangeIndexesKey];
            TKFormSection *removedSection = change[NSKeyValueChangeOldKey][0];
            [self sectionHasBeenRemoved:removedSection atIndex:indexSet.firstIndex];
        }
    }
    else if ([keyPath isEqualToString:@"rows"]){
        if ([change[NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeInsertion)]){
            NSIndexSet *indexSet = change[NSKeyValueChangeIndexesKey];
            TKFormRow *row = (((TKFormSection *)object).rows)[indexSet.firstIndex];
            NSUInteger sectionIndex = [self.sections indexOfObject:object];
            [self rowHasBeenAdded:row atIndexPath:[NSIndexPath indexPathForRow:indexSet.firstIndex inSection:sectionIndex]];
        }
        else if ([change[NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeRemoval)]){
            NSIndexSet *indexSet = change[NSKeyValueChangeIndexesKey];
            TKFormRow *removedRow = change[NSKeyValueChangeOldKey][0];
            NSUInteger sectionIndex = [self.sections indexOfObject:object];
            [self rowHasBeenRemoved:removedRow atIndexPath:[NSIndexPath indexPathForRow:indexSet.firstIndex inSection:sectionIndex]];
        }
        
    }
}


#pragma mark - KVC


- (NSUInteger)countOfSections {
    return self.sections.count;
}

- (void)insertObject:(TKFormSection *)section inSectionsAtIndex:(NSUInteger)index {
    section.form = self;
    [section addObserver:self forKeyPath:@"rows" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:0];
    [self.sections insertObject:section atIndex:index];
}

- (void)removeObjectFromSectionsAtIndex:(NSUInteger)index {
    TKFormSection *section = (self.sections)[index];
    @try {
        [section removeObserver:self forKeyPath:@"rows"];
    }
    @catch (NSException * __unused exception) {}
    [self.sections removeObjectAtIndex:index];
}

#pragma mark - Values

- (NSDictionary *)formValues {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (TKFormSection *section in self.sections) {
        if (!section.isMultivaluedSection)
        {
            for (TKFormRow *row in section.rows) {
                if (row.tag && ![row.tag isEqualToString:@""]){
                    //result[row.tag] = (row.value ?: [NSNull null]);
                    if (row.value) {
                        result[row.tag] = row.value;
                    }
                }
            }
        }
        else{
            NSMutableArray *multiValuedValuesArray = [NSMutableArray new];
            for (TKFormRow *row in section.rows) {
                if (row.value){
                    [multiValuedValuesArray addObject:row.value];
                }
            }
            result[section.multiValuedTag] = multiValuedValuesArray;
        }
    }
    return result;
}

- (TKFormSection *)sectionWithTag:(NSString *)tag {
    for (TKFormSection *section in self.sections){
        if ([section.tag isEqualToString:tag]){
            return section;
        }
    }
    return nil;
}

- (TKFormRow *)rowWithTag:(NSString *)tag {
    for (TKFormSection *section in self.sections){
        for (TKFormRow *row in section.rows) {
            if ([row.tag isEqualToString:tag]){
                return row;
            }
        }
    }
    return nil;
}

- (TKFormRow *)rowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sections.count > indexPath.section) {
        TKFormSection *section = self.sections[indexPath.section];
        if (section.rows.count > indexPath.row) {
            return section.rows[indexPath.row];
        }
    }
    return nil;
}

- (NSUInteger)visibleSectionsCount {
    NSUInteger i = 0;
    for (TKFormSection *section in self.sections) {
        if (!section.hidden) i++;
    }
    return i;
}

- (TKFormSection *)visibleSectionAtIndex:(NSUInteger)index {
    NSUInteger i = 0;
    index++;
    for (TKFormSection *section in self.sections) {
        if (!section.hidden) i++;
        if (i == index) {
            return section;
        }
    }
    return nil;
}

- (TKFormRow *)visibleRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.visibleSectionsCount > indexPath.section) {
        TKFormSection *section = self.sections[indexPath.section];
        if (section.visibleRowsCount > indexPath.row) {
            return [section visibleRowAtIndex:indexPath.row];
        }
    }
    return nil;
}

- (NSIndexPath *)indexPathForRow:(TKFormRow *)row {
    for (TKFormSection *section in self.sections){
        for (TKFormRow *sectionRow in section.rows) {
            if (row == sectionRow){
                return [NSIndexPath indexPathForRow:[section.rows indexOfObject:row]
                                          inSection:[self.sections indexOfObject:section]];
            }
        }
    }
    return nil;
}

- (NSIndexPath *)indexPathForVisibleRow:(TKFormRow *)row {
    NSUInteger iSection = 0;
    for (TKFormSection *section in self.sections) {
        NSUInteger iRow = 0;
        if (section.hidden) continue;
        for (TKFormRow *sectionRow in section.rows) {
            if (sectionRow.hidden) continue;
            if (row == sectionRow){
                return [NSIndexPath indexPathForRow:iRow inSection:iSection];
            }
            iRow++;
        }
        iSection++;
    }
    return nil;
}

#pragma mark - Delegation

- (void)hideSectionTags:(NSArray *)sectionTags rowTags:(NSArray *)rowTags
{
    if (!sectionTags) sectionTags = @[];
    if (!rowTags) rowTags = @[];
    
    NSMutableIndexSet *del_sectionIS = NSMutableIndexSet.new;
    NSMutableArray *del_rowIPs = NSMutableArray.new;
    
    
    NSUInteger iSection = 0;

    iSection = 0;
    for (TKFormSection *section in self.sections) {
        NSUInteger iRow = 0;
        if ([sectionTags containsObject:section.tag]) {
            if (!section.hidden) {
                [del_sectionIS addIndex:iSection];
            }
        }
        if (section.hidden) continue;
        for (TKFormRow *sectionRow in section.rows) {
            if ([rowTags containsObject:sectionRow.tag]) {
                if (!sectionRow.hidden) {
                    [del_rowIPs addObject:[NSIndexPath indexPathForRow:iRow inSection:iSection]];
                }
                //sectionRow.hidden = !sectionRow.hidden;
                iRow++;
            } else {
                if (sectionRow.hidden) continue;
                iRow++;
            }
            
        }
        iSection++;
    }
    
    for (TKFormSection *section in self.sections) {
        if ([sectionTags containsObject:section.tag]) {
            section.hidden = !section.hidden;
        }
        for (TKFormRow *sectionRow in section.rows) {
            if ([rowTags containsObject:sectionRow.tag]) {
                sectionRow.hidden = !sectionRow.hidden;
            }
        }
    }
    
    iSection = 0;
    for (TKFormSection *section in self.sections) {
        NSUInteger iRow = 0;
        
        
        if (section.hidden) continue;
        for (TKFormRow *sectionRow in section.rows) {
            if (sectionRow.hidden) continue;
            iRow++;
        }
        if (iRow == 0) {
            // hide section
            [del_sectionIS addIndex:iSection];
            section.hidden = YES;
        }
        
        iSection++;
    }

    
    if (self.viewController) {
        UITableView *tv = self.viewController.tableView;
        [tv beginUpdates];
        
        if (del_sectionIS.count > 0) {
            [tv deleteSections:del_sectionIS withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        if (del_rowIPs.count > 0) {
            [tv deleteRowsAtIndexPaths:del_rowIPs withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        
        [tv endUpdates];
        
        
    }

}

- (void)toggleOffRowTags:(NSArray *)rowTags {
    if (!rowTags) {
        return;
    }
    for (TKFormSection *section in self.sections){
        for (TKFormRow *row in section.rows) {
            if ([rowTags containsObject:row.tag]){
                row.value = @NO;
                [row updateCell];
            }
        }
    }
}

- (void)toggleSectionTags:(NSArray *)sectionTags rowTags:(NSArray *)rowTags
{
    
    if (!sectionTags) sectionTags = @[];
    if (!rowTags) rowTags = @[];
    
    NSMutableIndexSet *add_sectionIS = NSMutableIndexSet.new;
    NSMutableArray *add_rowIPs = NSMutableArray.new;
    NSMutableIndexSet *del_sectionIS = NSMutableIndexSet.new;
    NSMutableArray *del_rowIPs = NSMutableArray.new;
    
    
    NSUInteger iSection = 0;
    
    
    for (TKFormSection *section in self.sections) {
        if (section.hidden) {
            if (![sectionTags containsObject:section.tag]) {
                section.hidden = NO;
                // show section
                [add_sectionIS addIndex:iSection];
            }
            continue;
        }
        iSection++;
    }
    
    iSection = 0;
    for (TKFormSection *section in self.sections) {
        NSUInteger iRow = 0;
        if ([sectionTags containsObject:section.tag]) {
            if (section.hidden) {
                [add_sectionIS addIndex:iSection];
            } else {
                [del_sectionIS addIndex:iSection];
            }
        }
        if (section.hidden) continue;
        for (TKFormRow *sectionRow in section.rows) {
            if ([rowTags containsObject:sectionRow.tag]) {
                if (sectionRow.hidden) {
                    [add_rowIPs addObject:[NSIndexPath indexPathForRow:iRow inSection:iSection]];
                } else {
                    [del_rowIPs addObject:[NSIndexPath indexPathForRow:iRow inSection:iSection]];
                }
                //sectionRow.hidden = !sectionRow.hidden;
                iRow++;
            } else {
                if (sectionRow.hidden) continue;
                iRow++;
            }
            
        }
        iSection++;
    }
    
    for (TKFormSection *section in self.sections) {
        if ([sectionTags containsObject:section.tag]) {
            section.hidden = !section.hidden;
        }
        for (TKFormRow *sectionRow in section.rows) {
            if ([rowTags containsObject:sectionRow.tag]) {
                sectionRow.hidden = !sectionRow.hidden;
            }
        }
    }
    
    iSection = 0;
    for (TKFormSection *section in self.sections) {
        NSUInteger iRow = 0;
        
        
        if (section.hidden) continue;
        for (TKFormRow *sectionRow in section.rows) {
            if (sectionRow.hidden) continue;
            iRow++;
        }
        if (iRow == 0) {
            // hide section
            [del_sectionIS addIndex:iSection];
            section.hidden = YES;
        }
        
        iSection++;
    }

    
    
    if (self.viewController) {
        UITableView *tv = self.viewController.tableView;
        [tv beginUpdates];
        
        if (add_sectionIS.count > 0) {
            [tv insertSections:add_sectionIS withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        if (del_sectionIS.count > 0) {
            [tv deleteSections:del_sectionIS withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        if (add_rowIPs.count > 0) {
            [tv insertRowsAtIndexPaths:add_rowIPs withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        if (del_rowIPs.count > 0) {
            [tv deleteRowsAtIndexPaths:del_rowIPs withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        
        [tv endUpdates];
        
        
    }

}


- (void)sectionHasBeenRemoved:(TKFormSection *)section atIndex:(NSUInteger)index {
    
}

- (void)sectionHasBeenAdded:(TKFormSection *)section atIndex:(NSUInteger)index {
    
}

- (void)rowHasBeenAdded:(TKFormRow *)formRow atIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)rowHasBeenRemoved:(TKFormRow *)formRow atIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)rowValueHasChanged:(TKFormRow *)row oldValue:(id)oldValue newValue:(id)newValue {
    
    if ([oldValue isKindOfClass:[NSNull class]]) {
        oldValue = nil;
    }
    if ([newValue isKindOfClass:[NSNull class]]) {
        newValue = nil;
    }
    
    if (!oldValue && row.type == TKFormRowTypeSwitch) {
        oldValue = @NO;
    }
    
    if (self.viewController) {
        [self.viewController rowValueHasChanged:row oldValue:oldValue newValue:newValue];
    }
    
    if (row.type == TKFormRowTypeSwitch && oldValue && (oldValue != newValue)) {
        //NSLog(@"%@ -> %@", oldValue, newValue);
        
        if ([newValue boolValue]) {
            [self toggleOffRowTags:row.toggleOffRowTags];
        }
        
        [self toggleSectionTags:row.toggleSectionTags rowTags:row.toggleRowTags];
    }
}

@end
