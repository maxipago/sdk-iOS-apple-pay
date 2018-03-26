//  Created by Leandro Souza 
//  Copyright (c) 2017 maxiPago!. All rights reserved.
//

#import "DataBase.h"
#import <PassKit/PassKit.h>

@implementation DataBase

+ (DataBase *)shared {
    static DataBase* instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupDefaults];
        [self setupItems];
    }
    return self;
}

- (NSString *)currencySymbol {
        return @"R$";
}

- (void)setupDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud stringForKey:@"endpoint"]) {
        [ud setObject:@"merchant.your.merchant.com" forKey:@"endpoint"];
    }

    [ud synchronize];
}

- (void)setupItems {
    NSArray *is = @[
                    @[@"Cafézinho",  @"Programadores gostam muito", @"4.55"],
                    @[@"Hamburger",  @"Amanhã você começa a dieta :) ", @"25.25"],
                    @[@"CD-ROM",     @"Ótimo para suas músicas", @"3.99"],
                    @[@"Shampoo",    @"Bom para os cabelos", @"19.99"]
                    ];
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:is.count];
    for (NSArray *a in is) {
        OrderItem *item = [OrderItem new];
        item.title = a[0];
        item.subtitle = a[1];
        item.price = [NSDecimalNumber decimalNumberWithString:a[2]];
        [arr addObject:item];
    }
    
    self.items = arr;
    self.cartItems = [NSMutableArray array];
    
    self.currency = @"BRL";
    
}

- (void)_maxiPagoCartUpdated {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"maxiPagoCartUpdated" object:nil];
}

- (BOOL)hasItem:(OrderItem *)item {
    if ([self.cartItems containsObject:item]) {
        return YES;
    }
    return NO;
}

- (void)addItem:(OrderItem *)item {
    [self.cartItems addObject:item];
    [self _maxiPagoCartUpdated];
}

- (void)deleteItem:(OrderItem *)item {
    [self.cartItems removeObject:item];
    [self _maxiPagoCartUpdated];
}

- (void)removeCart {
    self.cartItems = [NSMutableArray array];
    [self _maxiPagoCartUpdated];
}

- (OrderItem *)itemForIndexPath:(NSIndexPath *)indexPath {
    return self.items[indexPath.row];
}

- (OrderItem *)cartItemForIndexPath:(NSIndexPath *)indexPath {
    return self.cartItems[indexPath.row];
}

- (NSArray *)paymentItems {
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:self.cartItems.count];
    
    for (OrderItem *item in self.cartItems) {
        PKPaymentSummaryItem *si = [PKPaymentSummaryItem summaryItemWithLabel:item.title amount:item.price];
        [a addObject:si];
    }
    return a;
}


- (NSDecimalNumber *)totalCartAmount {
    NSDecimalNumber *num = [NSDecimalNumber zero];
    
    for (OrderItem *item in self.cartItems) {
        num = [num decimalNumberByAdding:item.price];
    }
    return num;
}


@end
