//
//  ConnType.m
//  OwnTracks
//
//  Created by Christoph Krey on 05.10.16.
//  Copyright © 2016-2017 OwnTracks. All rights reserved.
//

#import "ConnType.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation ConnType

+ (ConnectionType)connectionType:(NSString *)host {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [host cStringUsingEncoding:NSASCIIStringEncoding]);
    SCNetworkReachabilityFlags flags;
    BOOL success = SCNetworkReachabilityGetFlags(reachability, &flags);
    CFRelease(reachability);
    if (!success) {
        return ConnectionTypeUnknown;
    }
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL isNetworkReachable = (isReachable && !needsConnection);

    if (!isNetworkReachable) {
        return ConnectionTypeNone;
    } else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        return ConnectionTypeWWAN;
    } else {
        return ConnectionTypeWIFI;
    }
}


@end
