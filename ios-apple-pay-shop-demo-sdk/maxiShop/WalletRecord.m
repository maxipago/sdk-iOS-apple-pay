//  Created by Leandro Souza.
//  Copyright (c) 2017 maxiPago!. All rights reserved.
//

#import "WalletRecord.h"

@implementation WalletRecord


- (ABRecordRef)abRecord {
    
    if (self.name.length == 0 && self.email.length == 0 && self.phone.length == 0
        && ![self shouldAddAddress]) {
        return nil;
    }
    
    ABRecordRef persona = ABPersonCreate();
    
    if (self.name.length > 0) {
        ABRecordSetValue(persona, kABPersonFirstNameProperty, (__bridge CFTypeRef)(self.name), nil);
    }
    
    if (self.email.length > 0) {
        ABMutableMultiValueRef multiValue = ABMultiValueCreateMutable(kABStringPropertyType);
        BOOL added = ABMultiValueAddValueAndLabel(multiValue, (__bridge CFTypeRef)(self.email), kABOtherLabel, NULL);
        if (added) {
            ABRecordSetValue(persona, kABPersonEmailProperty, multiValue, nil);
        }
        
        CFRelease(multiValue);
    }
    
    if (self.phone.length > 0) {
        ABMutableMultiValueRef multiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        BOOL added = ABMultiValueAddValueAndLabel(multiValue, (__bridge CFTypeRef)(self.phone), kABPersonPhoneMainLabel, NULL);
        if (added) {
            ABRecordSetValue(persona, kABPersonPhoneProperty, multiValue, nil);
        }
        
        CFRelease(multiValue);
    }
    

    if ([self shouldAddAddress]) {
        ABMutableMultiValueRef multiValue = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
        
        BOOL added = ABMultiValueAddValueAndLabel(multiValue, (__bridge CFTypeRef)([self abAddressDictionary]), kABOtherLabel, NULL);
        
        if (added) {
            ABRecordSetValue(persona, kABPersonAddressProperty, multiValue, NULL);
        }
    }
    
    

    return persona;
}

- (NSDictionary *)abAddressDictionary {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    if (self.street.length > 0)
        d[(NSString *)kABPersonAddressStreetKey] = self.street;
    
    if (self.city.length > 0)
        d[(NSString *)kABPersonAddressCityKey] = self.city;
    
    if (self.state.length > 0)
        d[(NSString *)kABPersonAddressStateKey] = self.state;
    
    if (self.zip.length > 0)
        d[(NSString *)kABPersonAddressZIPKey] = self.zip;
    
    if (self.countryCode.length > 0)
        d[(NSString *)kABPersonAddressCountryCodeKey] = [self.countryCode lowercaseString];
    
    return d;
}

- (NSDictionary *)addressDictionary {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    if (self.street.length > 0)
        d[@"street"] = self.street;
    
    if (self.city.length > 0)
        d[@"city"] = self.city;
    
    if (self.state.length > 0)
        d[@"state"] = self.state;
    
    if (self.zip.length > 0)
        d[@"zip"] = self.zip;
    
    if (self.countryCode.length > 0)
        d[@"countryCode"] = [self.countryCode uppercaseString];
    
    return d;
}

- (BOOL)shouldAddAddress {
    return (self.street.length > 0 ||
            self.city.length > 0 ||
            self.state.length > 0 ||
            self.zip.length > 0 ||
            self.countryCode.length > 0);
}


+ (instancetype)recordFromABRecord:(ABRecordRef)abRecord {
    
    if (!abRecord) {
        return nil;
    }
    
    WalletRecord *record = [[WalletRecord alloc] init];
    
    record.name = (__bridge NSString *)(ABRecordCopyCompositeName(abRecord));
    
    ABMutableMultiValueRef multiEmail = ABRecordCopyValue(abRecord, kABPersonEmailProperty);
    if (ABMultiValueGetCount(multiEmail) > 0) {
        
        record.email = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(multiEmail, 0));
        
    }
    if (multiEmail) CFRelease(multiEmail);
    
    ABMutableMultiValueRef multiPhone = ABRecordCopyValue(abRecord, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(multiPhone) > 0) {
        
        NSString *p = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(multiPhone, 0));
        
        p = [[p componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];

        if ([p length] > 3) {
            if (![p hasPrefix:@"+"]) {
                p = [@"+" stringByAppendingString:p];
            }
            record.phone = p;
        }
        
    }
    if (multiPhone) CFRelease(multiPhone);
    
    ABMultiValueRef sAddresses = ABRecordCopyValue(abRecord, kABPersonAddressProperty);
    if (sAddresses && ABMultiValueGetCount(sAddresses) > 0) {
        NSDictionary *d = (__bridge NSDictionary *)(ABMultiValueCopyValueAtIndex(sAddresses, 0));
        record.street      = d[(NSString *)kABPersonAddressStreetKey];
        record.city        = d[(NSString *)kABPersonAddressCityKey];
        record.state       = d[(NSString *)kABPersonAddressStateKey];
        record.zip         = d[(NSString *)kABPersonAddressZIPKey];
        record.countryCode = d[(NSString *)kABPersonAddressCountryCodeKey];
    }
    
    return record;
}

+ (instancetype)recordFromDictionary:(NSDictionary *)d {
    if (!d) {
        return nil;
    }
    
    WalletRecord *record = [[WalletRecord alloc] init];
    
    record.name  = d[@"name"];
    record.email = d[@"email"];
    record.phone = d[@"phone"];
    
    record.street      = d[@"street"];
    record.city        = d[@"city"];
    record.state       = d[@"state"];
    record.zip         = d[@"zip"];
    record.countryCode = d[@"countryCode"];
    
    return record;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    
    if (self.name.length > 0) {
        d[@"name"] = self.name;
    }
    
    if (self.email.length > 0) {
        d[@"email"] = self.email;
    }
    
    if (self.phone.length > 0) {
        d[@"phone"] = self.phone;
    }
    
    [d addEntriesFromDictionary:[self addressDictionary]];
    
    
    return d;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", [self toDictionary]];
}

@end
