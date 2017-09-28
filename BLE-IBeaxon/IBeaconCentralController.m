//
//  IBeaconCentralController.m
//  BLE&&IBeaxon
//
//  Created by 摇果 on 2017/9/6.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import "IBeaconCentralController.h"
#import "IBeaconCentralSingle.h"
#import "IBeaconCentralCell.h"
#import "IbeaaconModel.h"

#import <CoreLocation/CoreLocation.h>

@interface IBeaconCentralController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation IBeaconCentralController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_isPush) {
        [self rightItmeAction];
    }
}

- (void)rightItmeAction {
    [self MBProgressWithText:@"IBeaconCentral正在搜索..."];
    [[IBeaconCentralSingle single] regionIBeacon];
    [[IBeaconCentralSingle single] start];
}

#pragma mark - 菊花显示
- (void)MBProgressWithText:(NSString *)text {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    if (!_isPush) {
        [IBeaconCentralSingle single].show = ^(NSMutableArray *array) {
            self.array = [NSMutableArray array];
            for (CLBeacon *beacon in array) {
                NSString *uuid = [NSString stringWithFormat:@"%@", beacon.proximityUUID];
                NSArray *array = [uuid componentsSeparatedByString:@" "];
                IbeaaconModel *model = [[IbeaaconModel alloc] init];
                model.uuid = [NSString stringWithFormat:@"%@", array.lastObject];
                model.major = [NSString stringWithFormat:@"%@", beacon.major];
                model.minor = [NSString stringWithFormat:@"%@", beacon.minor];
                model.rssi = [NSString stringWithFormat:@"%ld", beacon.rssi];
                [self.array addObject:model];                
            }
            [self.tableView reloadData];
        };
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 90.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cell_id = @"IBeacinCell";
    IBeaconCentralCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (!cell) {
        cell = [[IBeaconCentralCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    IbeaaconModel *model = _array[indexPath.row];
    cell.model = model;
    return cell;
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
