//
//  IBeaconPeripheralSingle.h
//  BLE&&IBeaxon
//
//  Created by 摇果 on 2017/9/6.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^ShowBlock)();
@interface IBeaconPeripheralSingle : NSObject

@property (nonatomic, assign) CLBeaconMajorValue major;

@property (nonatomic, assign) CLBeaconMinorValue minor;

@property (nonatomic, copy) ShowBlock show;

+ (instancetype)single;

- (void)start;

- (void)stop;

@end
