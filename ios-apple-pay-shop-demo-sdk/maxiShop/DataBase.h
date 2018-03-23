//  Created by Leandro Souza
//  Copyright (c) 2017 maxiPago!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderItem.h"

@interface DataBase : NSObject

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *cartItems;
@property (nonatomic, strong) NSString *currency;


+ (DataBase *)shared;

- (NSString *)currencySymbol;

- (BOOL)hasItem:(OrderItem *)item;
- (void)addItem:(OrderItem *)item;
- (void)deleteItem:(OrderItem *)item;
- (void)removeCart;

- (OrderItem *)itemForIndexPath:(NSIndexPath *)indexPath;
- (OrderItem *)cartItemForIndexPath:(NSIndexPath *)indexPath;

- (NSArray *)paymentItems;
- (NSDecimalNumber *)totalCartAmount;

@end
