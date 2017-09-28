//
//  ViewController.m
//  BLE-IBeaxon
//
//  Created by 摇果 on 2017/9/28.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import "ViewController.h"
#import "BLEPeripheralController.h"
#import "BLECentralController.h"
#import "IBeaconPeripheralController.h"
#import "IBeaconCentralController.h"

#import "IBeaconCentralSingle.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"choose";
    self.view.backgroundColor = [UIColor whiteColor];
    
    for (int i = 0; i < self.array.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 150+(i*(35+20)), 200, 35)];
        label.tag = 1000+i;
        label.text = self.array[i];
        label.userInteractionEnabled = YES;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor grayColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseType:)];
        [label addGestureRecognizer:tap];
    }
}

- (void)chooseType:(UITapGestureRecognizer *)tap {
    UIViewController *vc;
    UILabel *label = (UILabel *)tap.view;
    NSInteger tag = label.tag;
    switch (tag) {
        case 1000:
            vc = [[BLEPeripheralController alloc] init];
            break;
        case 1001:
            vc = [[IBeaconPeripheralController alloc] init];
            break;
        case 1002:
            vc = [[BLECentralController alloc] init];
            break;
        case 1003:
            vc = [[IBeaconCentralController alloc] init];
            break;
        default:
            break;
    }
    vc.title = label.text;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (NSMutableArray *)array {
    if (!_array) {
        _array = [NSMutableArray arrayWithObjects:@"BLE外放", @"IBeacon外放", @"BLE搜索", @"IBeacon搜索", nil];
    }
    return _array;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
