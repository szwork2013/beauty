//
//  UploadImageView.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/18.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "UploadImageView.h"
#import <BmobSDK/BmobProFile.h>
#import <BmobSDK/BmobFile.h>
#import "SVProgressHUD.h"
#import <BmobSDK/Bmob.h>

@implementation UploadImageView

- (void)createImagesArray {
    
}

-(void)createChosenImagesArray{
    self.chosenImages = [NSMutableArray array];
    self.fileUrlArray = [NSMutableArray array];
}
- (IBAction)selectUploadSource:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
        [sheet showInView:self];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self selectFromAblum];
    } else if(buttonIndex == 0) {
        [self takePhoto];
    }
}

- (void)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.vc presentViewController:picker animated:YES completion:NULL];
}

#pragma mark 选取照片操作之后的代理方法，即将图片置于ImageView中及赋值给image1等，并将回调的pid存于self.pidArray中。
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //    最原始的图
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //    先减半传到服务器
    UIImage *imageOriginal = [self shrinkImage:image toSize:CGSizeMake(0.2*image.size.width, 0.2*image.size.height)];
    NSInteger column = self.chosenImages.count % 3;
    NSInteger row = self.chosenImages.count / 3;
    CGRect frame = CGRectMake( 40 * column, 40 * row, 38.0, 38.0);
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.frame = frame;
    [imageView setImage:imageOriginal];
    [self.containerView addSubview:imageView];
    [self.chosenImages addObject:imageOriginal];
    [picker dismissViewControllerAnimated:YES completion:^{

        
            [SVProgressHUD showWithStatus:@"正在上传..." maskType:SVProgressHUDMaskTypeGradient];

                BmobFile *file = [[BmobFile alloc] initWithFileName:@"photo.jpg" withFileData:UIImageJPEGRepresentation(imageOriginal,0.6)];
                [file saveInBackground:^(BOOL isSuccessful, NSError *error) {
                    
                    if (isSuccessful) {
                        
                        [self.fileUrlArray addObject:file.url];

                            [SVProgressHUD dismiss];
//                        已有图片数 + 1
                        self.existChosenImagesCount++;

                    } else {
                        //                NSLog(@"%@",error);
                    }
                } withProgressBlock:^(float progress) {
                }];
                
        
        

    }];
}

#pragma mark 从手机中选择
- (void)selectFromAblum {

       	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    
        elcPicker.maximumImagesCount = 9 - self.existChosenImagesCount; //Set the maximum number of images to select to 100
        elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
        elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
        elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
        elcPicker.mediaTypes = @[(NSString *)kUTTypeImage]; //Supports image and movie types
        elcPicker.imagePickerDelegate = self;
        [self.vc presentViewController:elcPicker animated:YES completion:nil];
//        BmobFile *file = [BmobFile alloc]initWithClassName:<#(NSString *)#> withFileName:<#(NSString *)#> withFileData:<#(NSData *)#>
}


- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self.vc dismissViewControllerAnimated:YES completion:nil];
    
//    for (UIView *v in [self.containerView subviews]) {
//        [v removeFromSuperview];
//    }
    
//    CGRect workingFrame = self.containerView.frame;
//    workingFrame.origin.x = 0;

    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
//    NSMutableArray *imagesURL = [NSMutableArray arrayWithCapacity:[info count]];
    int i = 0;
    self.existChosenImagesCount += self.chosenImages.count;
    for (NSDictionary *dict in info) {
        
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                [images addObject:image];
//                NSURL *imageURL=[dict objectForKey:UIImagePickerControllerReferenceURL];
//                [imagesURL addObject:imageURL.path];
                
                UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
                [imageview setContentMode:UIViewContentModeScaleAspectFill];
                imageview.clipsToBounds = YES;
                
                NSInteger column = (i + self.existChosenImagesCount) % 3;
                NSInteger row = (i + self.existChosenImagesCount) / 3;
                CGRect frame = CGRectMake( 40 * column, 40 * row, 38.0, 38.0);
                imageview.frame = frame;
                
                [self.containerView addSubview:imageview];
                
//                workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else {
            NSLog(@"Uknown asset type");
        }
        i++;
    }
    //                传完后，就自己清空，以免重复上传
    [self.chosenImages removeAllObjects];
    [self.chosenImages addObjectsFromArray:images];
//    self.imagesURL = imagesURL;
//    [self.containerView setPagingEnabled:YES];
//    [self.containerView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
    [self uploadImages];
    
}
- (void)uploadImages {
    [SVProgressHUD showWithStatus:@"正在上传..." maskType:SVProgressHUDMaskTypeGradient];
    __block int finishCount = 0;
    for (int i = 0; i < self.chosenImages.count; i++) {
        BmobFile *file = [[BmobFile alloc] initWithFileName:@"image.jpg" withFileData:UIImageJPEGRepresentation(self.chosenImages[i],0.6)];
        [file saveInBackground:^(BOOL isSuccessful, NSError *error) {
            
            if (isSuccessful) {
                
                [self.fileUrlArray addObject:file.url];
//                NSLog(@"file1 url %@",file.url);

                finishCount++;
                if (finishCount == self.chosenImages.count) {
                    [SVProgressHUD dismiss];
                }
            } else {
//                NSLog(@"%@",error);
            }
        } withProgressBlock:^(float progress) {
        }];
        
    }
}

#pragma mark 缩小图片
- (UIImage *)shrinkImage:(UIImage *)original toSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    CGFloat originalAspect = original.size.width / original.size.height;
    CGFloat targetAspect = size.width / size.height;
    CGRect targetRect;
    if (originalAspect > targetAspect) {
        // original is wider than target
        targetRect.size.width = size.width * originalAspect / targetAspect;
        targetRect.size.height = size.height;
        targetRect.origin.x = 0;
        targetRect.origin.y = (size.height - targetRect.size.height) * 0.5;
    } else if (originalAspect < targetAspect) {
        // original is narrower than target
        targetRect.size.width = size.width;
        targetRect.size.height = size.height * targetAspect / originalAspect;
        targetRect.origin.x = (size.width - targetRect.size.width) * 0.5;
        targetRect.origin.y = 0;
    } else {
        // original and target have same aspect ratio
        targetRect = CGRectMake(0, 0, size.width, size.height);
    }
    //    targetRect = CGRectMake(0, 0, .5*original.size.width, .5*original.size.height);
    [original drawInRect:targetRect];
    UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return final;
}

//
//+(void)filesUploadBatchWithDataArray:(NSArray *)dataArray
//                       progressBlock:(BmobFileBatchProgressBlock)progress
//                         resultBlock:(BmobFileBatchResultBlock)block{
//    
//    NSMutableArray *fileArray = [NSMutableArray array];
//    
//    [[self class] uploadFilesWithDatas:dataArray
//                                 index:0
//                           resultBlock:block
//                              progress:progress
//                             fileArray:fileArray];
//    
//}
//
//+(void)uploadFilesWithDatas:(NSArray *)array
//                      index:(int)index
//                resultBlock:(BmobFileBatchResultBlock)block
//                   progress:(BmobFileBatchProgressBlock)progressBlock
//                  fileArray:(NSMutableArray *)fileArray{
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        if (index + 1 < [array count]) {
//            if (!array[index]) {
//                if (block) {
//                    NSError *error = nil;
//                    block(nil,NO,error);
//                }
//            }else{
//                NSDictionary *dic  = array[index];
//                NSString *fileName = dic[@"filename"];
//                NSData *data       = dic[@"data"];
//                BmobFile *tmpFile  = [[BmobFile alloc] initWithFileName:fileName withFileData:data];
//                [tmpFile saveInBackgroundByDataSharding:^(BOOL isSuccessful, NSError *error) {
//                    if (isSuccessful) {
//                        int next = index +1;
//                        [fileArray addObject:tmpFile];
//                        [[self class] uploadFilesWithDatas:array
//                                                     index:next
//                                               resultBlock:block
//                                                  progress:progressBlock
//                                                 fileArray:fileArray];
//                        
//                    }else{
//                        if (block) {
//                            block(fileArray,NO,error);
//                        }
//                    }
//                } progressBlock:^(float progress) {
//                    if (progressBlock) {
//                        progressBlock(index,progress);
//                    }
//                }];
//                tmpFile = nil;
//            }
//            
//        }else if(index +1 == [array count]){
//            NSDictionary *dic  = array[index];
//            NSString *fileName = dic[@"filename"];
//            NSData *data       = dic[@"data"];
//            BmobFile *tmpFile  = [[BmobFile alloc] initWithFileName:fileName withFileData:data];
//            [tmpFile saveInBackgroundByDataSharding:^(BOOL isSuccessful, NSError *error) {
//                if (isSuccessful) {
//                    [fileArray addObject:tmpFile];
//                    if (block) {
//                        block(fileArray,YES,nil);
//                    }
//                }else{
//                    if (block) {
//                        block(fileArray,NO,error);
//                    }
//                }
//            } progressBlock:^(float progress) {
//                if (progressBlock) {
//                    progressBlock(index,progress);
//                }
//            }];
//            tmpFile = nil;
//        }
//    });
//}
//
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self.vc dismissViewControllerAnimated:YES completion:nil];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
