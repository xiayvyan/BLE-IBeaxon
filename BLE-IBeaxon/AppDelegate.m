//
//  AppDelegate.m
//  BLE-IBeaxon
//
//  Created by 摇果 on 2017/9/28.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "BLECentralController.h"
#import "IBeaconCentralController.h"
#import "IBeaconCentralSingle.h"
#import "IbeaaconModel.h"

#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //注册本地推送
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge+UNAuthorizationOptionSound+UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    
                }];
            }
        }];
    }else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:setting];
    }else{
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    
    [[IBeaconCentralSingle single] startUpLocation];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    ViewController *vc = [[ViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nc;
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - 点击弹框的代理方法（本地通知）
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    UINavigationController *rootVC = (UINavigationController *)self.window.rootViewController;
    NSDictionary *userInfo = notification.userInfo;
    if ([userInfo[@"type"] isEqualToString:@"iBeacon"]) {
        
        IbeaaconModel *model = [[IbeaaconModel alloc] init];
        [model setValuesForKeysWithDictionary:userInfo];
        IBeaconCentralController *vc = [[IBeaconCentralController alloc] init];
        vc.array = [NSMutableArray arrayWithObject:model];
        vc.isPush = YES;
        [rootVC pushViewController:vc animated:YES];
    }else{
        UINavigationController *nc = (UINavigationController *)[self getCurrentVC];
        BLECentralController *vc = (BLECentralController *)nc.childViewControllers.lastObject;
        [vc.array addObject:userInfo[@"value"]];
        [vc stop];
    }
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //即将进入后台
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isPush"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    //已经进入后台
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //即将进入前台
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // 已经进入前台
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isPush"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
    //角标
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    //程序杀死时
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isPush"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
