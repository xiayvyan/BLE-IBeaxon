//
//  IBeaconCentralCell.m
//  BLE&&IBeaxon
//
//  Created by 摇果 on 2017/9/7.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import "IBeaconCentralCell.h"
#import "IbeaaconModel.h"

@interface IBeaconCentralCell ()

@property (nonatomic, strong) UILabel *uuid;

@property (nonatomic, strong) UILabel *major;

@property (nonatomic, strong) UILabel *minor;

@property (nonatomic, strong) UILabel *rssi;

@end

@implementation IBeaconCentralCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createAllSubviews];
    }
    return self;
}

- (void)createAllSubviews {
    
    _uuid = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, ScreenWidth, 35)];
    _uuid.textColor = [UIColor grayColor];
    _uuid.font = [UIFont systemFontOfSize:12.0];
    _uuid.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_uuid];
    
    _major = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 90, 35)];
    _major.textColor = [UIColor grayColor];
    _major.font = [UIFont systemFontOfSize:12.0];
    _major.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_major];
    
    _minor = [[UILabel alloc] initWithFrame:CGRectMake(110, 50, 90, 35)];
    _minor.textColor = [UIColor grayColor];
    _minor.font = [UIFont systemFontOfSize:12.0];
    _minor.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_minor];
    
    _rssi = [[UILabel alloc] initWithFrame:CGRectMake(200, 50, 90, 35)];
    _rssi.textColor = [UIColor grayColor];
    _rssi.font = [UIFont systemFontOfSize:12.0];
    _rssi.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_rssi];
}

- (void)setModel:(IbeaaconModel *)model {
    
    _model = model;
    _uuid.text = [NSString stringWithFormat:@"uuid: %@", model.uuid];
    _major.text = [NSString stringWithFormat:@"major: %@", model.major];
    _minor.text = [NSString stringWithFormat:@"minor: %@", model.minor];
    _rssi.text = [NSString stringWithFormat:@"rssi: %@", model.rssi];
}

@end
