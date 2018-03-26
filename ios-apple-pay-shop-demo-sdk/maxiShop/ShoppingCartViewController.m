//  Created by Leandro Souza 11/10/14.
//  Copyright (c) 2017 maxiPago!. All rights reserved.
//

#import "ShoppingCartViewController.h"
#import "DataBase.h"
#import "OrderItemCell.h"
#import "PaymentRequestController.h"
#import "RESTAPIClient.h"

#define ShowAlert(title, text) [[[UIAlertView alloc] initWithTitle:title message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show]

#define ShowError(error) [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show]

@interface ShoppingCartViewController () <PaymentRequestControllerDelegate>
{
    NSArray *_pickerData;
}
@property (nonatomic, weak) IBOutlet UIButton *payButton;
@property (nonatomic, weak) IBOutlet UISegmentedControl *deliverySegmentedControl;

@property (strong, nonatomic) IBOutlet UIView *deliveryOptionsView;
@property (strong, nonatomic) IBOutlet UIView *payButtonView;

@property (nonatomic, strong) PaymentRequestController *PaymentRequestController;
@property (nonatomic, assign) BOOL doDelivery;


@end

@implementation ShoppingCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    // Initialize Data
    _pickerData = @[@"Auth", @"One-Time", @"Recurring"];
    
    // Connect data
    self.picker.dataSource = self;
    self.picker.delegate = self;
    UILabel *emptyCartLabel = [[UILabel alloc] init];
    emptyCartLabel.text = @"Carrinho vazio :(";
    emptyCartLabel.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightLight];
    emptyCartLabel.textAlignment = NSTextAlignmentCenter;
    emptyCartLabel.textColor = [UIColor lightGrayColor];
    self.tableView.backgroundView = emptyCartLabel;
    
    [[DataBase shared] addItem:[DataBase shared].items.lastObject];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:@"maxiPagoCartUpdated" object:nil];
    [self update];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.payButton.hidden) {
        return;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)update {
    [self updateEmptyCartView];
    [self.tableView reloadData];
}

- (IBAction)pickupTypeChanged:(id)sender {
    UISegmentedControl *sc = sender;
    self.doDelivery = (sc.selectedSegmentIndex == 1);
}

- (void)updateEmptyCartView {
    NSUInteger count = [DataBase shared].cartItems.count;
    self.deliveryOptionsView.hidden = (count == 0);
    self.payButtonView.hidden = (count == 0);
    self.tableView.backgroundView.hidden = (count > 0);
}

#pragma mark - Payment




- (IBAction)startPayment:(id)sender {
    
    NSString *transactionTypeSelected = [_pickerData objectAtIndex:[_picker selectedRowInComponent:0]] ;
    NSLog (@"%@", transactionTypeSelected);
    
    NSMutableArray *items = [NSMutableArray new];
    
    for (OrderItem *item in [DataBase shared].cartItems) {
        PKPaymentSummaryItem *si = [PKPaymentSummaryItem summaryItemWithLabel:item.title amount:item.price];
        [items addObject:si];
    }
    
    NSString *ref = [NSString stringWithFormat:@"TMRef%.0f", [NSDate timeIntervalSinceReferenceDate]];
    
    self.PaymentRequestController  = [PaymentRequestController new];
    [self.PaymentRequestController startPaymentWithDelegate:self merchantReference:ref items:items doDelivery:self.doDelivery:transactionTypeSelected];
    
}
-(void)hideAlert:(UIAlertView*)x{
    [x dismissWithClickedButtonIndex:-1 animated:YES];
}


#pragma mark - PaymentRequestControllerDelegate

- (void)PaymentRequestControllerFinishedWithResponse:(NSDictionary *)data error:(NSError *)error {
    if (error) {
        ShowError(error);
        return;
    }
    if (data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[DataBase shared] removeCart];
            [self update];
        });
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = [DataBase shared].cartItems.count;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    OrderItem *item = [[DataBase shared] cartItemForIndexPath:indexPath];

    cell.item = item;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        OrderItem *item = [[DataBase shared] cartItemForIndexPath:indexPath];
        [[DataBase shared] deleteItem:item];
        [self updateEmptyCartView];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

@end
