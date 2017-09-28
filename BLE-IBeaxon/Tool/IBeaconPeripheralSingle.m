//
//  IBeaconPeripheralSingle.m
//  BLE&&IBeaxon
//
//  Created by 摇果 on 2017/9/6.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import "IBeaconPeripheralSingle.h"
#import <CoreBluetooth/CoreBluetooth.h>


@interface IBeaconPeripheralSingle ()<CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager *manager;

@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

@end

@implementation IBeaconPeripheralSingle

+ (instancetype)single {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (void)stop {
    [_manager stopAdvertising];
}

- (void)start {
    _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

#pragma mark - CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    switch (peripheral.state) {
        case CBManagerStatePoweredOn:
            [self setUp];
            NSLog(@"IBeacon已经打开，可以使用IBeacon协议进行感知");
            break;
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"powered off");
            break;
        default:
            NSLog(@"%ld", peripheral.state);
            break;
    }
}

-(void)setUp {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:IBeaconUUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:_major minor:_minor identifier:@"MyIbeacon"];
    
    NSDictionary *dic = [_beaconRegion peripheralDataWithMeasuredPower:@(5)];
    [_manager startAdvertising:dic];
}

#pragma mark - 开始发送advertising
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (!error) {
        if (self.show) {
            self.show();
        }
        NSLog(@"in peripheralManagerDidStartAdvertisiong  开始发送advertising");
    }else{
        NSLog(@"发送advertising失败！%@", error);
    }
}



@end
