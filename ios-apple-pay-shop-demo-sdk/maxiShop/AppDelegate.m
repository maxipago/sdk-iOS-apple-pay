//  Created by Leandro Souza 
//  Copyright (c) 2017 maxiPago!. All rights reserved.
//

#import "AppDelegate.h"
#import "DataBase.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0.04 green:0.29 blue:0.42 alpha:1]];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"maxiPagoCartUpdated" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        int cartVCIndex = 1;
        UITabBarController *tbc = (id)[UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *vc = tbc.viewControllers[cartVCIndex];
        int count = (int)[DataBase shared].cartItems.count;
        
        vc.tabBarItem.badgeValue = (count > 0) ? [NSString stringWithFormat:@"%i", count] : nil;
    }];
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
   
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application {

}

@end
