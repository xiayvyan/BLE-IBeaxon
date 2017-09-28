//
//  BLECentralSingle.m
//  BLE&&IBeaxon
//
//  Created by 摇果 on 2017/9/6.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import "BLECentralSingle.h"
#import "AppDelegate.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLECentralSingle ()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *manager;
//准备链接的蓝牙
@property (nonatomic, strong) CBPeripheral *peripheral;
//蓝牙状态
@property (nonatomic, assign) CBCentralManagerState bluetoothFailState;

@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation BLECentralSingle

+ (instancetype)single {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (void)stop {
    [_manager stopScan];
    //断开连接
    if (_peripheral) {
        [_manager cancelPeripheralConnection:_peripheral];
    }
}

- (void)start {
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

#pragma mark - CBCentralManagerDelegate
//@required  检测蓝牙状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:{
            NSLog(@"蓝牙已开启");
            _bluetoothFailState = CBCentralManagerStatePoweredOn;
            //扫描开始
            NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
            NSArray *services = @[[CBUUID UUIDWithString:ServiceUUID2]];
            [self.manager scanForPeripheralsWithServices:services options:options];
        }
            break;
        case CBCentralManagerStatePoweredOff://关闭
            NSLog(@"连接失败了\n请您再检查一下您的手机蓝牙是否开启，\n然后再试一次吧");
            _bluetoothFailState = CBCentralManagerStatePoweredOff;
            break;
        case CBCentralManagerStateResetting://复位
            _bluetoothFailState = CBCentralManagerStateResetting;
            break;
        case CBCentralManagerStateUnsupported://表明设备不支持蓝牙低功耗
            NSLog(@"检测到您的手机不支持蓝牙4.0\n所以建立不了连接.建议更换您\n的手机再试试。");
            _bluetoothFailState = CBCentralManagerStateUnsupported;
            break;
        case CBCentralManagerStateUnauthorized://该应用程序是无权使用蓝牙低功耗
            NSLog(@"连接失败了\n请您再检查一下您的手机蓝牙是否开启，\n然后再试一次吧");
            _bluetoothFailState = CBCentralManagerStateUnauthorized;
            break;
        case CBCentralManagerStateUnknown://未知
            _bluetoothFailState = CBCentralManagerStateUnknown;
            break;
        default:
            break;
    }
}

//扫描外设(peripheral)
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
//    NSLog(@"did discover peripheral: %@, data: %@, %1.2f", peripheral.name, advertisementData, [RSSI floatValue]);
    self.peripheral = peripheral;
    [_manager connectPeripheral:peripheral options:nil];
}

//链接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"连接成功");
    //设置代理
    self.peripheral.delegate = self;
    //扫描外设的服务(service)
    [self.peripheral discoverServices:nil];
}

//链接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    NSLog(@"连接失败:%@", error);
}

//断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    NSLog(@"已断开与设备:[%@]的连接", peripheral.name);
}

//已发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        
    }else{
        //遍历服务
        for (CBService *s in peripheral.services) {
            NSLog(@"发现蓝牙服务 UUID:%@", [s.UUID UUIDString]);
//            if ([[s.UUID UUIDString] isEqual:ServiceUUID2]) {
                //扫描服务的特征(characteristic)
                [peripheral discoverCharacteristics:nil forService:s];
//            }
        }
    }
}

//已发现的特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error {
    
    NSLog(@"发现特征的服务:%@ (%@)",service.UUID.data ,service.UUID);
    for (CBCharacteristic *characteristic in service.characteristics) {
    //情景一：读取
        if ([[characteristic.UUID UUIDString] isEqual:readCharacteristicUUID]) {
            [_peripheral readValueForCharacteristic:characteristic];//会弹框配对
        }
    //情景二：写数据
        if (characteristic.properties & CBCharacteristicPropertyWrite ||
            characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {
            if ([[characteristic.UUID UUIDString] isEqual:readwriteCharacteristicUUID]) {
                [peripheral writeValue:[@"hello,外设" dataUsingEncoding:NSUTF8StringEncoding]  forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            }
        }
    }
}

//获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSData *data0 = characteristic.value;
    NSString *value = [[NSString alloc] initWithData:data0 encoding:NSUTF8StringEncoding];
    NSLog(@"获取外设发来的数据 uuid:%@ value:%@", characteristic.UUID, value);
    NSString *uuid = [characteristic.UUID UUIDString];
    if ([uuid isEqualToString:readCharacteristicUUID]) {
        NSString *str = [NSString stringWithFormat:@"%@:%@", readCharacteristicUUID, value];
        if (self.show) {
            self.show(str);
        }
        BOOL isPush = [[NSUserDefaults standardUserDefaults] boolForKey:@"isPush"];
        if (isPush && ![self.array containsObject:str]) {
            [self.array addObject:str];
            [self pushNotification:str];
        }
    }
}

#pragma mark - 推送通知
- (void)pushNotification:(NSString *)message {
    
    NSDictionary *userInfo = @{@"value":message};
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

#pragma mark - 写入结果回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error) {
        NSLog(@"Error writing characteristic value: %@", [error localizedDescription]);
    }else{
        NSString *str = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"写入成功！%@", str);
    }
}

//停止扫描并断开连接
-(void)disconnectPeripheral:(CBCentralManager *)centralManager
                 peripheral:(CBPeripheral *)peripheral{
    //停止扫描
    [centralManager stopScan];
    //断开连接
    [centralManager cancelPeripheralConnection:peripheral];
}

- (NSMutableArray *)array {
    if (!_array) {
        _array = [NSMutableArray array];
    }
    return _array;
}


@end
