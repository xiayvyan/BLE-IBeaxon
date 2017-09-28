//
//  IbeaaconModel.h
//  BLE&&IBeaxon
//
//  Created by 摇果 on 2017/9/8.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IbeaaconModel : NSObject

@property (nonatomic, copy) NSString *uuid;

@property (nonatomic, copy) NSString *major;

@property (nonatomic, copy) NSString *minor;

@property (nonatomic, copy) NSString *rssi;

@end
