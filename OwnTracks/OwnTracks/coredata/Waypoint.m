//
//  Waypoint.m
//  OwnTracks
//
//  Created by Christoph Krey on 28.09.15.
//  Copyright © 2015-2017 OwnTracks. All rights reserved.
//

#import "Waypoint.h"
#import "Friend+CoreDataClass.h"
#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "CoreData.h"

@implementation Waypoint

- (void)getReverseGeoCode {
    if (!self.placemark) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:(self.lat).doubleValue
                                                          longitude:(self.lon).doubleValue];
        [geocoder reverseGeocodeLocation:location completionHandler:
         ^(NSArray *placemarks, NSError *error) {
             [self.managedObjectContext performBlock:^{
                 if (!self.isDeleted) {
                     if (placemarks.count > 0) {
                         CLPlacemark *placemark = placemarks[0];
                         self.placemark = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
                     } else {
                         self.placemark = [NSString stringWithFormat:@"%@\n%@ %ld\n%@",
                                           NSLocalizedString(@"Address resolver failed", @"reverseGeocodeLocation error"),
                                           error.domain,
                                           (long)error.code,
                                           NSLocalizedString(@"due to rate limit or off-line", @"reverseGeocodeLocation text")
                                           ];
                     }
                     self.belongsTo.topic = self.belongsTo.topic;
                     [CoreData.sharedInstance sync:self.managedObjectContext];
                 }
             }];
         }];
    }
}

- (NSString *)coordinateText {
    return [NSString stringWithFormat:@"%g,%g (%@%.0f%@)",
            (self.lat).doubleValue,
            (self.lon).doubleValue,
            NSLocalizedString(@"±", @"Short for deviation plus/minus"),
            (self.acc).doubleValue,
            NSLocalizedString(@"m", @"Short for meters")
            ];
}

- (NSString *)timestampText {
    return [NSDateFormatter localizedStringFromDate:self.tst
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterMediumStyle];
}

- (NSString *)infoText {
    return [NSString stringWithFormat:@"%@%0.f%@ (%@%.0f%@) %0.f%@ %0.f%@",
            NSLocalizedString(@"✈︎", @"Short for altitude as in ✈︎1000m"),
            (self.alt).doubleValue,
            NSLocalizedString(@"m", @"Short for meters"),
            NSLocalizedString(@"±", @"Short for deviation plus/minus"),
            (self.vac).doubleValue,
            NSLocalizedString(@"m", @"Short for meters"),
            (self.vel).doubleValue,
            NSLocalizedString(@"km/h", @"Short for kilometers per hour as in 120km/h"),
            (self.cog).doubleValue,
            NSLocalizedString(@"°", @"Short for degrees celsius as in 20°")
            ];
}



@end
