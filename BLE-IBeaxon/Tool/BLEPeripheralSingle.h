//
//  BLEPeripheralSingle.h
//  BLE&&IBeaxon
//
//  Created by 摇果 on 2017/9/6.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ShowBlock)();
@interface BLEPeripheralSingle : NSObject

@property (nonatomic, copy) ShowBlock show;

@property (nonatomic, copy) NSString *characteristic;

+ (instancetype)single;

- (void)start;

- (void)stop;

@end
