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
@interface UploadImageView : UIView<UIActionSheetDelegate,ELCImagePickerControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *desciptLabel;
@property (nonatomic, strong) NSMutableArray *chosenImages;
@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) NSMutableArray *fileUrlArray;
@property (nonatomic, strong)UIViewController *vc;
@property (nonatomic, assign) NSInteger existChosenImagesCount;
-(void)createChosenImagesArray;
@end
