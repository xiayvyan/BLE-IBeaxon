//
//  IBeaconCentralSingle.m
//  BLE&&IBeaxon
//
//  Created by 摇果 on 2017/9/6.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import "IBeaconCentralSingle.h"
#import "AppDelegate.h"

#import <CoreLocation/CoreLocation.h>

@interface IBeaconCentralSingle ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, strong) NSMutableArray *feelArray;

@end


@implementation IBeaconCentralSingle
static CLLocationManager *_manager = nil;
+ (instancetype)single {
    static IBeaconCentralSingle *tools = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tools = [[IBeaconCentralSingle alloc] init];
        _manager = [[CLLocationManager alloc] init];
        if([_manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_manager requestAlwaysAuthorization];
        }
        _manager.pausesLocationUpdatesAutomatically = NO;
    });
    return tools;
}
#pragma mark - 开始定位
- (void)startUpLocation {
    if (!_manager.delegate) {
        _manager.delegate = self;
    }
    [_manager startUpdatingLocation];
}

#pragma mark - 停止定位
- (void)stopUpLocation {
    
    [_manager stopUpdatingLocation];
}

#pragma mark -注册iBeacon设备
- (void)regionIBeacon {
    
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"Authorized Always");
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"Authorized when in use");
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"Denied");
            break;
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"Not determined");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"Restricted");
            break;
        default:
            break;
    }
    [_manager startMonitoringForRegion:self.beaconRegion];
    [self startUpLocation];
}

- (void)start {
    [_manager startRangingBeaconsInRegion:self.beaconRegion];
    [self startUpLocation];
}

- (void)stop {
    [_manager stopRangingBeaconsInRegion:self.beaconRegion];
}

#pragma mark - iBeacon
//进入uuid范围
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"----------------------");
    [_manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    [_manager startUpdatingLocation];
}
//离开uuid范围
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"+++++++++++++++++++++++");
    [manager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
    [manager startMonitoringForRegion:region];
    [_manager startUpdatingLocation];
    
    self.array = nil;
    self.feelArray = nil;
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    _array = [NSMutableArray arrayWithArray:beacons];
    if (self.show) {
        self.show(_array);
    }
    
    for (CLBeacon *beacon in beacons) {
        NSString *major = [NSString stringWithFormat:@"%@", beacon.major];
        NSString *minor = [NSString stringWithFormat:@"%@", beacon.minor];
        NSString *uuid = [NSString stringWithFormat:@"%@", beacon.proximityUUID];
        NSArray *array = [uuid componentsSeparatedByString:@" "];
        NSString *str = [NSString stringWithFormat:@"%@%@%@", array.lastObject, major, minor];
        NSLog(@"-----------%@-------------", str);
        BOOL isPush = [[NSUserDefaults standardUserDefaults] boolForKey:@"isPush"];
        if (isPush && ![self.feelArray containsObject:str]) {
            [self.feelArray addObject:str];
            [self pushNotification:str withBeacon:beacon];
        }
    }
}

#pragma mark - 推送通知
- (void)pushNotification:(NSString *)message withBeacon:(CLBeacon *)beacon {
    
    NSString *uuid = [NSString stringWithFormat:@"%@", beacon.proximityUUID];
    NSArray *array = [uuid componentsSeparatedByString:@" "];
    NSString *rssi = [NSString stringWithFormat:@"%ld", beacon.rssi];
    NSDictionary *userInfo = @{@"type":@"iBeacon",
                               @"uuid":array.lastObject,
                               @"major":beacon.major,
                               @"minor":beacon.minor,
                               @"rssi":rssi};
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = message;
    notification.userInfo = userInfo;
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //角标 +1
    NSInteger value = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    value++;
    [UIApplication sharedApplication].applicationIconBadgeNumber = value;
}

#pragma mark - 懒加载
- (CLBeaconRegion *)beaconRegion {
    if (!_beaconRegion) {
        NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:IBeaconUUID];
        NSString *regionIdentifier = [NSString stringWithFormat:@"%@", beaconUUID];
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID identifier:regionIdentifier];
        _beaconRegion.notifyEntryStateOnDisplay = YES;
        _beaconRegion.notifyOnEntry = YES;
        _beaconRegion.notifyOnExit = YES;
    }
    return _beaconRegion;
}

- (NSMutableArray *)feelArray {
    
    if (!_feelArray) {
        _feelArray = [NSMutableArray array];
    }
    return _feelArray;
}


@end
