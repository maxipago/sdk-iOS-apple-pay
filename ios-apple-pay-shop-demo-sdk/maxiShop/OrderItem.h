//  Created by Leandro Souza 
//  Copyright (c) 2017 maxiPago!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OrderItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSDecimalNumber *price;
@property (nonatomic, strong) NSString *costString;
@property (nonatomic, strong) UIImage *image;

@end
