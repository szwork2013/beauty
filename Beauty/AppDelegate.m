//
//  AppDelegate.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/1.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import <BmobSDK/Bmob.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *appKey = @"4f9af9412c122816f905cfbdc5efd2e1";
    [Bmob registerWithAppKey:appKey];
    UIColor *tintColor = [UIColor colorWithRed:187.0/255.0 green:122.0/255.0 blue:178.0/255.0 alpha:1.0];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setBarTintColor:tintColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance]setTintColor:tintColor];
    

    
//    //查找GameScore表
//    BmobQuery   *bquery = [BmobQuery queryWithClassName:@"TryEvent"];
//    //查找GameScore表里面id为0c6db13c的数据
//    
//    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
//        for (BmobObject *obj in array) {
//            //打印playerName
//            NSLog(@"name = %@", [obj objectForKey:@"name"]);
//            NSLog(@"image = %@", [obj objectForKey:@"avatar"]);
//        }
//    }];
//    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
