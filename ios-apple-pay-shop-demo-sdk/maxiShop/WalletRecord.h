//  Created by Leandro Souza 9/23/14.
//  Copyright (c) 2017 maxiPago!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface WalletRecord : NSObject


@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phone;


@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *zip;
@property (nonatomic, strong) NSString *countryCode;


- (ABRecordRef)abRecord;
+ (instancetype)recordFromABRecord:(ABRecordRef)abRecord;
+ (instancetype)recordFromDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)toDictionary;

@end
