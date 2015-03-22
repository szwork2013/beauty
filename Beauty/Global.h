//
//  Global.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/4.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#ifndef Beauty_Global_h
#define Beauty_Global_h

#define MAIN_COLOR [UIColor colorWithRed:187.0/255.0 green:122.0/255.0 blue:178.0/255.0 alpha:1.0]
#define TINYGRAY_COLOR [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0]
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define TOPBAR_HEIGHT 64
#define PAGEINDICATOR_WIDTH 100
#define PER_PAGE 3
#define NO_MORE @"没有新数据了"
#define NO_DATAS @"结果空空如也～"
#define BASE_TAG 1000
#define RECT_LOG(f) NSLog(@"\nx:%f\ny:%f\nwidth:%f\nheight:%f\n",f.origin.x,f.origin.y,f.size.width,f.size.height)
#define MARGIN 8.0
#endif
