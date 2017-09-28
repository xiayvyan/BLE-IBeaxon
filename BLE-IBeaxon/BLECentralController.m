//
//  BLECentralController.m
//  BLE&&IBeaxon
//
//  Created by 摇果 on 2017/9/6.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import "BLECentralController.h"
#import "BLECentralSingle.h"

@interface BLECentralController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) UITableView *tableView;


@end

@implementation BLECentralController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stop];
}

- (void)start {
    [self MBProgressWithText];
    [[BLECentralSingle single] start];
}

- (void)stop {
    [_hud hide:YES];
    [[BLECentralSingle single] stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [BLECentralSingle single].show = ^(NSString *value) {
        if (![self.array containsObject:value]) {
            [self.array addObject:value];
            [_tableView reloadData];
        }
    };
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cell_id = @"BLECell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell_id];
    }
    cell.textLabel.text = _array[indexPath.row];
    return cell;
}


#pragma mark - 菊花显示
- (void)MBProgressWithText {
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.mode = MBProgressHUDModeText;
    _hud.labelText = @"BLECentral正在搜索...";
    _hud.removeFromSuperViewOnHide = YES;
}

- (NSMutableArray *)array {
    if (!_array) {
        _array = [NSMutableArray array];
    }
    return _array;
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
