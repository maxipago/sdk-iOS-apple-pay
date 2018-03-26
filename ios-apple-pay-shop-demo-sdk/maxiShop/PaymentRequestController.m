//  Created by Leandro Souza
//  Copyright (c) 2017 maxiPago!. All rights reserved.
//

#import "PaymentRequestController.h"

#import "WalletRecord.h"
#import "RESTAPIClient.h"
#import "DataBase.h"

@interface PaymentRequestController () <PKPaymentAuthorizationViewControllerDelegate>
@property (nonatomic, strong) NSString *merchantName;
@property (nonatomic, strong) NSString *merchantReference;
@property (nonatomic, strong) NSArray *paymentItems;
@end
NSString *transactionTypeG = nil;

@implementation PaymentRequestController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.merchantName = @"maxiPago";
    }
    return self;
}

- (NSError *)errorWithCode:(PaymentRequestControllerError)code description:(NSString *)description error:(NSError *)underlyingError {

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:1];

    if (description) {
        d[NSLocalizedDescriptionKey] = description;
    }

    if (underlyingError) {
        d[NSUnderlyingErrorKey] = underlyingError;
    }

    NSError *error = [[NSError alloc] initWithDomain:@"merchant." code:code userInfo:d];
    return error;
}

- (void)startPaymentWithDelegate:(id<PaymentRequestControllerDelegate>)delegate merchantReference:(NSString *)reference items:(NSArray *)items doDelivery:(BOOL)doDelivery:(NSString *)transactionType {
    
    transactionTypeG =transactionType;
    self.delegate = delegate;

    if (![self canMakePayments]) return;

    self.merchantReference = reference;
    self.paymentItems = items;

    PKPaymentRequest *request = [PKPaymentRequest new];
    request.supportedNetworks = @[ PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex ];
    request.merchantCapabilities = PKMerchantCapability3DS;

    request.merchantIdentifier = @"merchant.your.merchant.com";
    request.countryCode = @"US";
    request.currencyCode = [DataBase shared].currency;
 //   NSData* transactionTypeConverted = [transactionType dataUsingEncoding:NSUTF8StringEncoding];
 //   request.applicationData = transactionTypeConverted;

    if (doDelivery) {
        request.requiredShippingAddressFields = PKAddressFieldAll;
    }

    NSArray *summaryItems = [self summaryItemsForShippingMethod:nil];

    request.paymentSummaryItems = summaryItems;

    if ([self.totalAmount doubleValue] <= 0) {
        NSError *error = [self errorWithCode:PaymentRequestControllerErrorAmountTooLow description:@"O total da compra deve ser maior que zero" error:nil];
        [self.delegate PaymentRequestControllerFinishedWithResponse:nil error:error];
        return;
    }

    self.paymentRequest = request;
    [self presentPaymentViewController];
}

- (BOOL)canMakePayments {

    if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[ PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex ]]) {
        NSError *error = [self errorWithCode:PaymentRequestControllerErrorCantMakePayments description:@"Pagamento não permitido" error:nil];
        [self.delegate PaymentRequestControllerFinishedWithResponse:nil error:error];
        return NO;
    }
    return YES;
}

- (void)presentPaymentViewController {

    PKPaymentAuthorizationViewController *vc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:self.paymentRequest];

    if (!vc) {
        NSError *error = [self errorWithCode:PaymentRequestControllerErrorCantMakePayments description:@"Cannot start payments" error:nil];
        [self.delegate PaymentRequestControllerFinishedWithResponse:nil error:error];
        return;
    }
    vc.delegate = self;
    [self.delegate presentViewController:vc animated:YES completion:nil];
}

- (NSDictionary *)prepareMaxiPagoRequestData:(PKPayment *)payment {
    
    NSData *paymentToken = payment.token.paymentData;
    
    NSString *paymentType = [self convertPaymentTypeToString:payment.token.paymentMethod.type];
    
    id paymentTokenJSON = [NSJSONSerialization JSONObjectWithData:paymentToken options:NSJSONReadingAllowFragments error:nil];
    
    NSDictionary *paymentHeader = paymentTokenJSON[@"header"];
    
    if (paymentHeader == nil){
        return nil;
    }
    
    if([transactionTypeG isEqualToString:@"Recurring"]){
        transactionTypeG = @"recurringPayment";
    }
    if([transactionTypeG isEqualToString:@"One-Time"]){
        transactionTypeG = @"sale";
    }
    if([transactionTypeG isEqualToString:@"Auth"]){
        transactionTypeG = @"auth";
    }
    NSDictionary *maxiPagoPaymentRequest = nil;
    
    if([transactionTypeG isEqualToString:@"recurringPayment"]){
        maxiPagoPaymentRequest =
        @{
          @"wallet": @"applePay",
          @"referenceNumber": @"TEST-APPLE-PAY-RF",
          @"installments": @4,
          @"chargeInterest": @"Y",
          @"walletDetail": @{
                  @"merchantIdentifier": @"merchant.your.merchant.com",
                  @"transactionType": transactionTypeG,
                  @"recurring":@{
                      @"action":@"new",
                      @"startDate":@"2018-10-07",
                      @"period":@"daily",
                      @"frequency":@"1",
                      @"installments":@"12",
                      @"firstAmount":@"100",
                      @"lastAmount":@"1000",
                      @"lastDate":@"2020-10-05",
                      @"failureThreshold":@"1"
                  },
                  @"applePayPayment": @{
                          @"paymentData": @{
                                  @"version": paymentTokenJSON[@"version"],
                                  @"data": paymentTokenJSON[@"data"],
                                  @"signature": paymentTokenJSON[@"signature"],
                                  @"header": @{
                                          @"ephemeralPublicKey": paymentHeader[@"ephemeralPublicKey"],
                                          @"publicKeyHash": paymentHeader[@"publicKeyHash"],
                                          @"transactionId": paymentHeader[@"transactionId"],
                                          }
                                  },
                          @"paymentMethod": @{
                                  @"displayName": payment.token.paymentMethod.displayName,
                                  @"network": payment.token.paymentMethod.network,
                                  @"type": paymentType
                                  },
                          @"transactionIdentifier": payment.token.transactionIdentifier
                          }
                  }
          };
    } else {
        maxiPagoPaymentRequest =
        @{
          @"wallet": @"applePay",
          @"referenceNumber": @"TEST-APPLE-PAY-RF",
          @"installments": @4,
          @"chargeInterest": @"Y",
          @"walletDetail": @{
                  @"merchantIdentifier": @"merchant.your.merchant.com",
                  @"transactionType": transactionTypeG,
                  @"applePayPayment": @{
                          @"paymentData": @{
                                  @"version": paymentTokenJSON[@"version"],
                                  @"data": paymentTokenJSON[@"data"],
                                  @"signature": paymentTokenJSON[@"signature"],
                                  @"header": @{
                                          @"ephemeralPublicKey": paymentHeader[@"ephemeralPublicKey"],
                                          @"publicKeyHash": paymentHeader[@"publicKeyHash"],
                                          @"transactionId": paymentHeader[@"transactionId"],
                                          }
                                  },
                          @"paymentMethod": @{
                                  @"displayName": payment.token.paymentMethod.displayName,
                                  @"network": payment.token.paymentMethod.network,
                                  @"type": paymentType
                                  },
                          @"transactionIdentifier": payment.token.transactionIdentifier
                          }
                  }
          };
    }
    
    return maxiPagoPaymentRequest;
}

- (NSArray *)shippingMethodsFromJson:(NSArray *)json {
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:json.count];
    for (NSDictionary *d in json) {
        PKShippingMethod *item = [PKShippingMethod summaryItemWithLabel:d[@"label"] amount:[NSDecimalNumber decimalNumberWithString:d[@"amount"]]];
        item.detail = d[@"detail"];
        item.identifier = d[@"identifier"];
        [a addObject:item];
    }
    return a;
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion {
    if (!payment.token.paymentData) {
        NSError *error = [self errorWithCode:PaymentRequestControllerErrorNoPaymentToken description:@"Payment token not found" error:nil];
        [self.delegate PaymentRequestControllerFinishedWithResponse:nil error:error];
        completion(PKPaymentAuthorizationStatusFailure);
        return;
    }

    NSDictionary *paymentData = [self prepareMaxiPagoRequestData:payment];

    NSLog(@"Payment data json: %@", paymentData);
    
    if (paymentData == nil){
        completion(PKPaymentAuthorizationStatusFailure);
    }else{
        [RESTAPIClient POST:@"/UniversalAPI/rest/EncryptedWallet/order"
            parameters:paymentData
            completion:^(id JSON, NSError *connectionError) {
              if (connectionError || !JSON) {
                  NSError *error = [self errorWithCode:PaymentRequestControllerErrorServerError description:@"Connection refused" error:connectionError];
                  [self.delegate PaymentRequestControllerFinishedWithResponse:nil error:error];
                  completion(PKPaymentAuthorizationStatusFailure);
                  return;
              }
                NSLog(@"Completed: %@", JSON);
                completion(PKPaymentAuthorizationStatusSuccess);
                
               //UIAlertView *myal = [[UIAlertView alloc] initWithTitle:@"Response from maxiPago!" message:JSON delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
           //     [myal show];
              completion(PKPaymentAuthorizationStatusSuccess);
              [self.delegate PaymentRequestControllerFinishedWithResponse:JSON error:nil];
            }];
        }
    }

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                   didSelectShippingMethod:(PKShippingMethod *)shippingMethod
                                completion:(void (^)(PKPaymentAuthorizationStatus, NSArray *summaryItems))completion {
    NSArray *summaryItems = [self summaryItemsForShippingMethod:shippingMethod];
    completion(PKPaymentAuthorizationStatusSuccess, summaryItems);
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self.delegate dismissViewControllerAnimated:YES completion:nil];
}
- (NSString*) convertPaymentTypeToString:(PKPaymentMethodType) paymentType {
    NSString *result = nil;
    
    switch(paymentType) {
        case 1:
            //PKPaymentMethodTypeDebit
            result = @"debit";
            break;
        case 2:
            //PKPaymentMethodTypeCredit
            result = @"credit";
            break;
            //PKPaymentMethodTypePrepaid
        case 3:
            result = @"prepaid";
            break;
        default:
            //PKPaymentMethodTypeUnknown
            result = @"unknown";
    }
    
    return result;
}
#pragma mark - Helpers

- (NSArray *)summaryItemsForItems:(NSArray *)items shippingMethod:(PKShippingMethod *)shippingMethod withTotalLabel:(NSString *)totalLabel {

    NSDecimalNumber *total = [NSDecimalNumber zero];
    for (PKPaymentSummaryItem *item in items) {
        total = [total decimalNumberByAdding:item.amount];
    }

    if (shippingMethod) {
        total = [total decimalNumberByAdding:shippingMethod.amount];
    }

    PKPaymentSummaryItem *totalItem = [PKPaymentSummaryItem summaryItemWithLabel:totalLabel amount:total];
    NSMutableArray *allItems = [NSMutableArray new];
    [allItems addObjectsFromArray:items];

    if (shippingMethod) [allItems addObject:shippingMethod];
    [allItems addObject:totalItem];

    return allItems;
}

- (NSArray *)summaryItemsForShippingMethod:(PKShippingMethod *)shippingMethod {
    NSArray *summaryItems = [self summaryItemsForItems:self.paymentItems
                                        shippingMethod:shippingMethod
                                        withTotalLabel:self.merchantName];

    self.totalAmount = [(PKPaymentSummaryItem *)summaryItems.lastObject amount];

    return summaryItems;
}


@end
