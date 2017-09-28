//
//  IBeaconCentralSingle.h
//  BLE&&IBeaxon
//
//  Created by 摇果 on 2017/9/6.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ShowBlock)(NSMutableArray *array);
@interface IBeaconCentralSingle : NSObject

@property (nonatomic, copy) ShowBlock show;

+ (instancetype)single;

- (void)start;

- (void)stop;
//开始定位
- (void)startUpLocation;
//停止定位
- (void)stopUpLocation;
//注册ibeacon扫描
- (void)regionIBeacon;

@end
