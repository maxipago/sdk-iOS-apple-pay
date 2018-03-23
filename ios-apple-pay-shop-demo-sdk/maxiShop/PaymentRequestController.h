//  Created by Leandro Souza 
//  Copyright (c) 2017 maxiPago!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>

typedef enum : NSUInteger {
    PaymentRequestControllerErrorCantMakePayments,
    PaymentRequestControllerErrorAmountTooLow,
    PaymentRequestControllerErrorNoPaymentToken,
    PaymentRequestControllerErrorServerError,
} PaymentRequestControllerError;

@protocol PaymentRequestControllerDelegate <NSObject>

- (void)PaymentRequestControllerFinishedWithResponse:(NSDictionary *)data error:(NSError *)error;

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion;
- (void)dismissViewControllerAnimated: (BOOL)flag completion: (void (^ __nullable)(void))completion;

@end

@interface PaymentRequestController : NSObject

@property (nonatomic, assign) id<PaymentRequestControllerDelegate> delegate;

@property (nonatomic, strong) NSDecimalNumber *totalAmount;

@property (nonatomic, strong) PKPaymentRequest *paymentRequest;

- (void)startPaymentWithDelegate:(id<PaymentRequestControllerDelegate>)delegate merchantReference:(NSString *)reference items:(NSArray *)items doDelivery:(BOOL)doDelivery:(NSString *)transactionType;
- (BOOL)canMakePayments;

@end
