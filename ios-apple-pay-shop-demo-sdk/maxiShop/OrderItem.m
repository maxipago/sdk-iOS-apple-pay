//  Created by Leandro Souza
//  Copyright (c) 2017 maxiPago!. All rights reserved.
//

#import "OrderItem.h"

@implementation OrderItem

- (UIImage *)image {
    return [UIImage imageNamed:self.title];
}

- (NSString *)costString {
    return self.price.stringValue;
}


@end
