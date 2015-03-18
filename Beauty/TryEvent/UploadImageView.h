//
//  UploadImageView.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/18.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerHeader.h"
#import <MobileCoreServices/UTCoreTypes.h>
@interface UploadImageView : UIView<UIActionSheetDelegate,ELCImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *desciptLabel;
@property (nonatomic, copy) NSArray *chosenImages;
@property (nonatomic, strong) IBOutlet UIScrollView *containerView;

@property (nonatomic, strong)UIViewController *vc;
@end
