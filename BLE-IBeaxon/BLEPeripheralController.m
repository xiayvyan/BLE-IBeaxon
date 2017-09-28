//
//  BLEPeripheralController.m
//  BLE&&IBeaxon
//
//  Created by 摇果 on 2017/9/6.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import "BLEPeripheralController.h"
#import "BLEPeripheralSingle.h"

@interface BLEPeripheralController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@end

@implementation BLEPeripheralController

- (void)rightItmeAction {
    if (_textField.text.length < 1) {
        [self MBProgressWithText:@"FFE0的值不能为空!!!"];
        return;
    }
    [self.view endEditing:YES];
    [BLEPeripheralSingle single].characteristic = _textField.text;
    [[BLEPeripheralSingle single] start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[BLEPeripheralSingle single] stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *itme = [[UIBarButtonItem alloc] initWithTitle:@"开始" style:UIBarButtonItemStyleDone target:self action:@selector(rightItmeAction)];
    self.navigationItem.rightBarButtonItem = itme;
    
    __weak typeof(self) weakSelf = self;
    [BLEPeripheralSingle single].show = ^() {
        
        [weakSelf MBProgressWithText:@"BLEPeripheral正在外放..."];
    };
    
    UILabel *serviceLabel0 = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, 100, 35)];
    serviceLabel0.text = readCharacteristicUUID;
    serviceLabel0.textColor = [UIColor whiteColor];
    serviceLabel0.backgroundColor = [UIColor grayColor];
    serviceLabel0.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:serviceLabel0];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(130, 150, 160, 35)];
    _textField.delegate = self;
    _textField.text = @"123456";
    _textField.layer.borderColor = [UIColor grayColor].CGColor;
    _textField.layer.borderWidth = 1.0;
    [self.view addSubview:_textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.view endEditing:YES];
    return YES;
}
#pragma mark - 菊花显示
- (void)MBProgressWithText:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = NO;
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
