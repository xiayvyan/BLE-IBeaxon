//
//  IBeaconPeripheralController.m
//  BLE&&IBeaxon
//
//  Created by 摇果 on 2017/9/6.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import "IBeaconPeripheralController.h"
#import "IBeaconPeripheralSingle.h"
#import <CoreLocation/CoreLocation.h>

@interface IBeaconPeripheralController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *majorField;

@property (nonatomic, strong) UITextField *minorField;

@end

@implementation IBeaconPeripheralController

- (void)rightItmeAction {
    [self.view endEditing:YES];
    if (_majorField.text.length < 1 || _minorField.text.length < 1) {
        [self MBProgressWithText:@"major 或 minor 的值不能为空!!!" withMargin:2.0];
    }
    NSInteger major = [_majorField.text integerValue];
    NSInteger minor = [_minorField.text integerValue];
    if (major < 0 || major > 65532 || minor < 0 || minor > 65532) {
        [self MBProgressWithText:@"major 或 minor 的取值为0～65532" withMargin:2.0];
        return;
    }
    [IBeaconPeripheralSingle single].major = major;
    [IBeaconPeripheralSingle single].minor = minor;
    [[IBeaconPeripheralSingle single] start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[IBeaconPeripheralSingle single] stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *itme = [[UIBarButtonItem alloc] initWithTitle:@"开始" style:UIBarButtonItemStyleDone target:self action:@selector(rightItmeAction)];
    self.navigationItem.rightBarButtonItem = itme;
    
    UILabel *uuidLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, ScreenWidth, 35)];
    uuidLabel.font = [UIFont systemFontOfSize:12.0];
    uuidLabel.textColor = [UIColor whiteColor];
    uuidLabel.backgroundColor = [UIColor grayColor];
    uuidLabel.textAlignment = NSTextAlignmentCenter;
    uuidLabel.text = [NSString stringWithFormat:@"UUID:%@", IBeaconUUID];
    [self.view addSubview:uuidLabel];
    
    UILabel *majorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 100, 35)];
    majorLabel.text = @"major";
    majorLabel.textColor = [UIColor whiteColor];
    majorLabel.backgroundColor = [UIColor grayColor];
    majorLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:majorLabel];
    
    _majorField = [[UITextField alloc] initWithFrame:CGRectMake(130, 200, 160, 35)];
    _majorField.delegate = self;
    _majorField.text = @"10109";
    _majorField.textAlignment = NSTextAlignmentCenter;
    _majorField.layer.borderColor = [UIColor grayColor].CGColor;
    _majorField.layer.borderWidth = 1.0;
    [self.view addSubview:_majorField];
    
    UILabel *minorLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 250, 100, 35)];
    minorLable.text = @"minor";
    minorLable.textColor = [UIColor whiteColor];
    minorLable.backgroundColor = [UIColor grayColor];
    minorLable.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:minorLable];
    
    _minorField = [[UITextField alloc] initWithFrame:CGRectMake(130, 250, 160, 35)];
    _minorField.delegate = self;
    _minorField.text = @"24308";
    _minorField.textAlignment = NSTextAlignmentCenter;
    _minorField.layer.borderColor = [UIColor grayColor].CGColor;
    _minorField.layer.borderWidth = 1.0;
    [self.view addSubview:_minorField];
        
    __weak typeof(self) weakSelf = self;
    [IBeaconPeripheralSingle single].show = ^() {
        
        [weakSelf MBProgressWithText:@"IBeaconPeripheral正在外放..." withMargin:0.0];
    };
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - 菊花显示
- (void)MBProgressWithText:(NSString *)message withMargin:(CGFloat)margin {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.0;
    if (margin) {
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:margin];
    }else{
        hud.removeFromSuperViewOnHide = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
