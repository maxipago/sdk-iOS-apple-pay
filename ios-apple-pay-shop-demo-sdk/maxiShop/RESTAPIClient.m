//  Created by Leandro Souza 
//  Copyright © 2017 maxiPago!. All rights reserved.
//

#import "RESTAPIClient.h"

@implementation RESTAPIClient

+ (void)POST:(NSString *)path parameters:(NSDictionary *)params completion:(void (^)(id, NSError *))completion {
    NSURLRequest *request = [self requestPath:path method:@"POST" params:params];
    [self processPayment:request completion:completion];
}

+ (void)processPayment:(NSURLRequest *)request completion:(void (^)(id, NSError *))completion {

    NSLog(@"Request to: %@, data: \n%@", request.URL.absoluteString, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSLog(@"Error: %@", connectionError);
                               NSLog(@"Response: %@, Code From maxiPago: %i, data: \n%@", response, (int)[(NSHTTPURLResponse*)response statusCode], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                               
                             id json = nil;
                             if (data) {
                                 json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                             }
                               
                               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                   completion(json, connectionError);
                               });
                               
                             
                           }];
}

+ (NSMutableURLRequest *)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params {

    NSString *baseUrlmaxiPago = @"https://testapi.maxipago.net";
    

    NSURL *url = [NSURL URLWithString:baseUrlmaxiPago];
    url = [url URLByAppendingPathComponent:path];

    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:url
                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                            timeoutInterval:30.0];


    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    [request setHTTPBody:data];
    

    [request setHTTPMethod:method];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];

    return request;
}

@end
