//  Created by Leandro Souza 
//  Copyright (c) 2017 maxiPago!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderItem.h"

@interface OrderItemCell : UITableViewCell

@property (nonatomic, strong) UIButton *priceButton;
@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, strong) NSDecimalNumber *price;


@property (nonatomic, assign) OrderItem *item;

@end
