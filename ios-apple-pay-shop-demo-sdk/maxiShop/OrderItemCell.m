//  Created by Leandro Souza 
//  Copyright (c) 2017 maxiPago!. All rights reserved.
//

#import "OrderItemCell.h"
#import "DataBase.h"

@implementation OrderItemCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    CGRect frame = CGRectMake(0, 0, 60, 28);
    
    self.priceLabel = [[UILabel alloc] initWithFrame:frame];
    self.priceLabel.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium];
    self.priceLabel.textColor = [UIColor darkTextColor];
    self.priceLabel.textAlignment = NSTextAlignmentRight;
    self.accessoryView = self.priceLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)setItem:(OrderItem *)item {
    
    self.textLabel.text = item.title;
    self.detailTextLabel.text = item.subtitle;
    self.imageView.image = item.image;
    self.price = item.price;
    
    NSString *sp = [NSString stringWithFormat:@"%@%@",
                    DataBase.shared.currencySymbol, self.price.stringValue];
    self.priceLabel.text = sp;

}

@end
