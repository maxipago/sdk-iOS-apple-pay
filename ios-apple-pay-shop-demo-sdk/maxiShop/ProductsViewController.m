//  Created by Leandro Souza 
//  Copyright (c) 2017 maxiPago!. All rights reserved.
//

#import "ProductsViewController.h"
#import "DataBase.h"
#import "OrderItemCell.h"
#import "UIHelper.h"

@interface ProductsViewController ()

@end

@implementation ProductsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITabBarController *tbc = (id)[UIApplication sharedApplication].keyWindow.rootViewController;
    tbc.selectedIndex = 1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DataBase shared].items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    OrderItem *item = [[DataBase shared] itemForIndexPath:indexPath];
    cell.item = item;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    OrderItem *item = [[DataBase shared] itemForIndexPath:indexPath];
    
    if ([[DataBase shared] hasItem:item]) {
        return;
    }
    
    CGPoint endPoint = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height - 100);
    endPoint = [cell.contentView convertPoint:endPoint fromView:self.view];
    CGPoint centerPoint = [cell.contentView convertPoint:self.view.center fromView:self.view];
    
    CGPoint p1 = centerPoint;
    p1.y -= 100;
    
    CGPoint p2 = centerPoint;
    p2.x += 110;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:cell.imageView.center];

    [path addCurveToPoint:endPoint controlPoint1:p1 controlPoint2:p2];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"position";
    anim.path = path.CGPath;
    anim.duration = 0.5;

    anim.calculationMode = kCAAnimationPaced;

    
    anim.timingFunctions = @[
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
                                 ];
    
    [cell.imageView.layer addAnimation:anim forKey:@"move"];
    
    
    [[DataBase shared] addItem:item];
}

@end
