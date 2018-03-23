//  Created by Leandro Souza 6/29/15.
//  Copyright © 2017 maxiPago!. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RESTAPIClient : NSObject

+ (void)POST:(NSString *)path parameters:(NSDictionary *)params
  completion:(void (^)(id JSON, NSError *error))completion;

+ (void)processPayment:(NSURLRequest *)request
            completion:(void (^)(id JSON, NSError *error))completion;

@end
