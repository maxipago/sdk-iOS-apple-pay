//  Created by Leandro Souza
//  Copyright (c) 2017 maxiPago!. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShoppingCartViewController : UITableViewController<UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@end
