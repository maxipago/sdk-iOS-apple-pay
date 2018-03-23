//
//  TKFormViewController.m
//  ADYWallet
//
//  Created by Leandro Souza 9/10/14.
//  Copyright (c) 2017 Taras Kalapun. All rights reserved.
//

#import "TKFormViewController.h"
#import "TKForm.h"
#import "TKFormSection.h"
#import "TKFormRow.h"

@interface TKFormViewController ()
//@property UITableViewStyle tableViewStyle;

@property (nonatomic, strong) TKFormViewController *subController;
@property (nonatomic, strong) TKFormRow *selectedRow;

@end

@implementation TKFormViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        //_tableViewStyle = UITableViewStyleGrouped;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.form.viewController) {
        self.form.viewController = self;
    }
}

- (TKForm *)form {
    if (!_form) {
        _form = [TKForm form];
        _form.viewController = self;
    }
    return _form;
}

- (NSDictionary *)formValues {
    return [self.form formValues];
}

- (NSIndexPath *)indexPathForRow:(TKFormRow *)row {
    return [self.form indexPathForVisibleRow:row];
}

- (void)formDidSelectRow:(TKFormRow *)row {
    if ([self.form.delegate respondsToSelector:@selector(formDidSelectRow:)]) {
        [self.form.delegate formDidSelectRow:row];
    }
}

- (void)formDeselectRow:(TKFormRow *)row {
    NSIndexPath *indexPath = [self indexPathForRow:row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)rowValueHasChanged:(TKFormRow *)row oldValue:(id)oldValue newValue:(id)newValue {
}

#pragma mark - Stop editing

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.view endEditing:YES];
    }
}

#pragma mark - Navigation stack

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.navigationController pushViewController:viewController animated:animated];
}

- (void)popViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController.navigationController popViewControllerAnimated:animated];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.form.visibleSectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section >= self.form.visibleSectionsCount){
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"" userInfo:nil];
    }
    TKFormSection *formSection = [self.form visibleSectionAtIndex:section];
    return formSection.visibleRowsCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TKFormRow *row = [self.form visibleRowAtIndexPath:indexPath];
    UITableViewCell *cell = (id)[row cellForFormController:self];
    [row updateCell];
    
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.form visibleSectionAtIndex:section] title];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [[self.form visibleSectionAtIndex:section] footerTitle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TKFormRow *row = [self.form visibleRowAtIndexPath:indexPath];
    
    [self formDidSelectRow:row];
    
    if (row.type == TKFormRowTypeButton) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (row.viewControllerClass) {
            UIViewController *vc = [[row.viewControllerClass alloc] init];
            [self pushViewController:vc animated:YES];
        }
    }
    else if (row.type == TKFormRowTypeSelector && row.selectorType == TKFormRowSelectorTypePush) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (row.actionSelector) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:row.actionSelector];
#pragma clang diagnostic pop
    }
}

@end
