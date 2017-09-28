//
//  BLEPeripheralSingle.m
//  BLE&&IBeaxon
//
//  Created by 摇果 on 2017/9/6.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import "BLEPeripheralSingle.h"
#import <CoreBluetooth/CoreBluetooth.h>


@interface BLEPeripheralSingle ()<CBPeripheralManagerDelegate>
{
    NSInteger _serviceNum;
    NSTimer *_timer;
}
@property (nonatomic, strong) CBPeripheralManager *manager;

@property (nonatomic, strong) CBUUID *CBUUIDCharacteristicUserDescriptionStringUUID;

@end

@implementation BLEPeripheralSingle

+ (instancetype)single {
    
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        
        return [[self alloc] init];
    });
}

- (void)start {
    _serviceNum = 0;
    _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

- (void)stop {
    
    [_manager stopAdvertising];
}

#pragma mark - CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    switch (peripheral.state) {
        case CBManagerStatePoweredOn:
            [self setUp];
            NSLog(@"设备名%@已经打开，可以使用center进行连接", LocalNameKey);
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
    //特征
    _CBUUIDCharacteristicUserDescriptionStringUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];
    //可以通知的Characteristic
    CBMutableCharacteristic *notiyCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:notiyCharacteristicUUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    //可读写的characteristics
    CBMutableCharacteristic *readwriteCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:readwriteCharacteristicUUID] properties:CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    //只读的Characteristic
    NSData *data = [self.characteristic dataUsingEncoding:NSUTF8StringEncoding];
    CBMutableCharacteristic *readCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:readCharacteristicUUID] properties:CBCharacteristicPropertyRead value:data permissions:CBAttributePermissionsReadable];
    
    //描述
    //设置description
    CBMutableDescriptor *readwriteCharacteristicDescription1 = [[CBMutableDescriptor alloc]initWithType:_CBUUIDCharacteristicUserDescriptionStringUUID value:@"name"];
    [readwriteCharacteristic setDescriptors:@[readwriteCharacteristicDescription1]];
    
    //服务
    CBMutableService *service1 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:ServiceUUID1] primary:YES];
    [service1 setCharacteristics:@[notiyCharacteristic,readwriteCharacteristic]];
    NSLog(@"%@",service1.UUID);
    
    CBMutableService *service2 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:ServiceUUID2] primary:YES];
    [service2 setCharacteristics:@[readCharacteristic]];
    
    [_manager addService:service1];
    [_manager addService:service2];
}

#pragma mark - 开启广播advertising
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    
    if (!error) {
        _serviceNum ++;
        if (_serviceNum == 2) {
            [_manager startAdvertising:@{
                                         CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:ServiceUUID1], [CBUUID UUIDWithString:ServiceUUID2]],
                                         CBAdvertisementDataLocalNameKey:LocalNameKey
                                         }];
        }
    }else{
        NSLog(@"error:%@", error);
    }
}

#pragma mark - 开始发送advertising
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (!error) {
        if (self.show) {
            self.show();
        }
        NSLog(@"in peripheralManagerDidStartAdvertisiong  开始发送advertising");
    }else{
        NSLog(@"发送advertising失败！");
    }
}

#pragma mark - 读取
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    // 判断是否可读
    if (request.characteristic.properties & CBCharacteristicPropertyRead) {
        NSString *message;
        NSString *uuid = [NSString stringWithFormat:@"%@", request.characteristic.UUID];
        if ([uuid isEqual:readwriteCharacteristicUUID]) {
            message = request.characteristic.descriptors.firstObject.value;
            NSLog(@"%@", message);
        }
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        request.value = data;
        
        // 对请求成功做出响应
        [_manager respondToRequest:request withResult:CBATTErrorSuccess];
    }else
    {
        [_manager respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }
}

#pragma mark - 写入
//写characteristics请求
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
    CBATTRequest *request = requests[0];
    //判断是否有写数据的权限
    if (request.characteristic.properties & CBCharacteristicPropertyWrite) {
        //需要转换成CBMutableCharacteristic对象才能进行写值
        CBMutableCharacteristic *characteristic =(CBMutableCharacteristic *)request.characteristic;
        NSString *str = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
        CBMutableDescriptor *readwriteCharacteristicDescription1 = [[CBMutableDescriptor alloc]initWithType:_CBUUIDCharacteristicUserDescriptionStringUUID value:str];
        [characteristic setDescriptors:@[readwriteCharacteristicDescription1]];
        NSLog(@"%@",str);
        [_manager respondToRequest:request withResult:CBATTErrorSuccess];
    }else{
        [_manager respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }
}



@end
