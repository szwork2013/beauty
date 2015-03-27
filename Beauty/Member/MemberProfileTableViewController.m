//
//  MemberProfileTableViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/26.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "MemberProfileTableViewController.h"
#import "Global.h"
#import "CommonUtil.h"
#import "UIImageView+AFNetworking.h"
#import "SVProgressHUD.h"
#import "KGModal.h"
typedef void(^modalViewBlock)(void);
@interface MemberProfileTableViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *ageButton;
@property (weak, nonatomic) IBOutlet UIButton *skinTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *tagButton;
@property (weak, nonatomic) IBOutlet UITextField *nicknameLabel;
@property (strong, nonatomic) UIPickerView *agePickView;
@property (strong, nonatomic) UIPickerView *skinTypePickView;
@property (strong, nonatomic) NSArray *ageArray;
@property (strong, nonatomic) NSArray *skinTypeArray;
@property (assign, nonatomic) NSInteger selectedSkinType;
//弹窗
@property (strong, nonatomic) UIView *containerView;
//标签背景色
@property (strong, nonatomic) NSArray *colorArray;
//全部标签
@property (strong, nonatomic) NSArray *tagArray;
@property (strong, nonatomic) NSMutableArray *tagStatusArray;
@property (strong, nonatomic) NSMutableArray *checkedImageViewArray;
@property (strong, nonatomic) IBOutlet UIView *selectedTagContainerView;
@property (assign, nonatomic) BOOL isInitForTag;
@property (strong , nonatomic) NSArray *userSavedTagArry;
@end

@implementation MemberProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    初始化变量
    self.checkedImageViewArray = [NSMutableArray array];
    self.tagStatusArray = [NSMutableArray array];
    //表格下边距
    self.tableView.contentInset = UIEdgeInsetsMake(-36.0, 0, 0, 0);
    
//    标题栏
    self.navigationItem.title = @"修改资料";
    
//    头像圆角带边框
    self.avatarImageView.layer.cornerRadius = 40.0;
    self.avatarImageView.layer.borderColor = [TINYGRAY_COLOR CGColor];
    self.avatarImageView.layer.borderWidth = 2.0;
    self.avatarImageView.clipsToBounds = YES;
    BmobFile *avatarFile = [self.user objectForKey:@"avatar"];
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:avatarFile.url] placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
    
//    保存按钮圆角
    self.submitButton.layer.cornerRadius = 4.0;
    
//    1.年龄 2.肤质 3.标签 圆角
    self.ageButton.layer.cornerRadius = 4.0;
    self.skinTypeButton.layer.cornerRadius = 4.0;
    self.tagButton.layer.cornerRadius = 4.0;
    
//    初始化年龄、肤质pickView
    self.ageArray = [self createAgePickerViewDataSource];
    self.agePickView = [[UIPickerView alloc]init];
    self.agePickView.center = CGPointMake(SCREEN_WIDTH / 2.0, 135.0);
    self.agePickView.showsSelectionIndicator = YES;
    self.agePickView.dataSource = self;
    self.agePickView.delegate = self;

    
    self.skinTypeArray = [self createSkinPickerViewDataSource];
    self.skinTypePickView = [[UIPickerView alloc]init];
    self.skinTypePickView.center = CGPointMake(SCREEN_WIDTH / 2.0, 135.0);
    self.skinTypePickView.dataSource = self;
    self.skinTypePickView.delegate = self;
    
//    读取昵称、年龄、肤质
    self.nicknameLabel.text = [self.user objectForKey:@"nickname"];
    [self.ageButton setTitle:[[self.user objectForKey:@"age"]stringValue] forState:UIControlStateNormal];
    [self.skinTypeButton setTitle:self.skinTypeArray[[[self.user objectForKey:@"skinType"] intValue]] forState:UIControlStateNormal];
    self.selectedSkinType = [[self.user objectForKey:@"skinType"] intValue];
    
//    生成颜色数组
    self.colorArray = @[
                        [CommonUtil colorWithHexString:@"#7ecdf4" alpha:1.0],
                        [CommonUtil colorWithHexString:@"#cbe198" alpha:1.0],
                        [CommonUtil colorWithHexString:@"#f29ec2" alpha:1.0],
                        [CommonUtil colorWithHexString:@"#facd89" alpha:1.0],
                        [CommonUtil colorWithHexString:@"#eb6876" alpha:1.0]
                    ];
    [self fetchTags];
    [self loadTag];
}

#pragma mark 点击头像选择拍照或本地选取
- (IBAction)avatarImageViewTapped:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册",nil];
    [sheet showInView:self.view];
}

//点击选取or从本机相册选择的ActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (0 == buttonIndex) {
        [self takeOrSelectPhoto:UIImagePickerControllerSourceTypeCamera];
    } else if (1 == buttonIndex){
        [self takeOrSelectPhoto:UIImagePickerControllerSourceTypeSavedPhotosAlbum];

    }
    
    
}

- (void)takeOrSelectPhoto:(UIImagePickerControllerSourceType)sourceType {
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.mediaTypes = mediaTypes;
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];
}
//用户上传照片-取消操作
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark 选取照片操作之后的代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //    最原始的图
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //    先减半传到服务器
    UIImage *imageOriginal = [CommonUtil shrinkImage:image toSize:CGSizeMake(0.3*image.size.width, 0.3*image.size.height)];
    
    //    整理成正方形放在控件中
    UIImage *imageThumb = [CommonUtil shrinkImage:image toSize:CGSizeMake(80, 80)];
    [self.avatarImageView setImage:imageThumb];
    [picker dismissViewControllerAnimated:YES completion:^{
        BmobFile *file = [[BmobFile alloc] initWithFileName:@"avata.jpg" withFileData:UIImageJPEGRepresentation(imageOriginal,0.6)];
        [file saveInBackground:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
//                更新用户头像
                [self.user setObject:file forKey:@"avatar"];
                [self.user updateInBackground];
                [SVProgressHUD showSuccessWithStatus:@"上传成功"];
            } else {
                //                NSLog(@"%@",error);
            }
        } withProgressBlock:^(float progress) {
            [SVProgressHUD showProgress:progress status:@"正在上传"];
        }];
    }];
}

#pragma mark 保存资料
- (IBAction)saveProfile:(id)sender {
    if ([self.nicknameLabel.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请填写昵称" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        
    } else {
        //        保存之前要先删除原来所有的Tag，然后再加入新的
        BmobRelation *tagRemovingRelation = [[BmobRelation alloc]init];
        for (int i = 0; i < self.tagStatusArray.count; i++) {
            BmobObject *tagRemovingObject = [BmobObject objectWithoutDatatWithClassName:@"Tag" objectId:[self.tagArray[i] objectId]];
            [tagRemovingRelation removeObject:tagRemovingObject];
        }
        [self.user addRelation:tagRemovingRelation forKey:@"tag"];
        [self.user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
//                删除干净了，可以设置新Tag值了
                //        做保存提交操作
                [self.user setObject:self.nicknameLabel.text forKey:@"nickname"];
                [self.user setObject:[NSNumber numberWithInteger:[[self.ageButton titleForState:UIControlStateNormal] intValue]] forKey:@"age"];
                [self.user setObject:[NSNumber numberWithInteger:self.selectedSkinType] forKey:@"skinType"];
                //        保存tag操作
                BmobRelation *tagRelation = [[BmobRelation alloc]init];
                for (int i = 0; i < self.tagStatusArray.count; i++) {
                    NSNumber *tagStatus = self.tagStatusArray[i];
                    //        保存之前要先删除原来所有的Tag，然后再加入新的
                    if ([tagStatus boolValue]) {
                        BmobObject *removedObject = [BmobObject objectWithoutDatatWithClassName:@"Tag" objectId:[self.tagArray[i] objectId]];
                        [tagRelation addObject:removedObject];
                    }
                }
                [self.user addRelation:tagRelation forKey:@"tag"];
                
                [self.user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    if (isSuccessful) {
                        [SVProgressHUD showSuccessWithStatus:@"保存成功"];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }
        }];
        
    }
    
}

#pragma mark -
#pragma mark 生成年龄数组
- (NSArray *)createAgePickerViewDataSource {
    NSMutableArray *ageArray = [NSMutableArray arrayWithCapacity:100];
    for (int i = 0; i < 100; i++) {
        [ageArray addObject:[NSNumber numberWithInt:i]];
    }
    return ageArray;
}

#pragma mark 生成肤质数组
- (NSArray *)createSkinPickerViewDataSource {
    return @[@"混合", @"中性", @"油性", @"干性", @"敏感"];
}

#pragma mark -
#pragma mark 年龄、肤质弹出容器公共函数
- (void) modalView:(modalViewBlock)block title:(NSString *)title {
    //    容器view
//    UIView *containerView = self.containerView;
    
    
    _containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 260.0)];
    _containerView.backgroundColor = [UIColor whiteColor];
    //    添加标题与分隔线
    //    标题
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10.0, 0, SCREEN_WIDTH, 50.0)];
    label.textColor = MAIN_COLOR;
    label.font = [UIFont systemFontOfSize:18.0];
    label.text = title;
    [_containerView addSubview:label];
    //    分隔线
    UIView *seperatedView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame), SCREEN_WIDTH, 1)];
    seperatedView.backgroundColor = TINYGRAY_COLOR;
    [_containerView addSubview:seperatedView];
    
    block();
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [submitButton setTitle:@"确定" forState:UIControlStateNormal];
    submitButton.frame = CGRectMake(0, 220.0, SCREEN_WIDTH, 40.0);
    submitButton.backgroundColor = MAIN_COLOR;
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(hiddenModalView) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:submitButton];
    

}
#pragma mark 年龄选择
- (IBAction)pickAge:(id)sender {
    [self modalView:^{
        //    添加年龄选择器
        [_containerView addSubview: self.agePickView];
        //    选择默认项
        NSInteger defaultRow = [[self.ageButton titleForState:UIControlStateNormal]intValue] == 0 ? 25 : [[self.ageButton titleForState:UIControlStateNormal]intValue];
        [self.agePickView selectRow:defaultRow inComponent:0 animated:YES];
        [[KGModal sharedInstance] showWithContentView:_containerView andAnimated:YES];
    } title:@"请选择年龄"];
    
}

#pragma mark 肤质选择
- (IBAction)pickSkinType:(id)sender {
    [self modalView:^{
        //    添加肤质选择器
        [_containerView addSubview: self.skinTypePickView];
        //    选择默认项
        [self.agePickView selectRow:self.selectedSkinType inComponent:0 animated:YES];
        [[KGModal sharedInstance] showWithContentView:_containerView andAnimated:YES];
    } title:@"请选择肤质"];
}
#pragma mark 从网络加载全部Tag
- (void)fetchTags {
    BmobQuery *query = [BmobQuery queryWithClassName:@"Tag"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        self.tagArray = array;
    }];
}
#pragma mark 标签选择
- (IBAction)pickTag:(id)sender {
    self.isInitForTag = NO;
    CGFloat width = SCREEN_WIDTH;
    CGFloat buttonWidth = 80.0;
    CGFloat buttonHeight = 30.0;
    CGFloat buttonMargin = 20.0;
    CGFloat buttonForSubmitHeight = 40.0;
    UIView *containerView = [[UIView alloc]init];
    containerView.backgroundColor = [UIColor whiteColor];
    //    标题
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10.0, 0, width, 50.0)];
    label.textColor = MAIN_COLOR;
    label.font = [UIFont systemFontOfSize:18.0];
    label.text = @"请选择标签(多选)";
    [containerView addSubview:label];
    //    分隔线
    UIView *seperatedView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame), width, 1)];
    seperatedView.backgroundColor = TINYGRAY_COLOR;
    [containerView addSubview:seperatedView];
    
    //    Tag按钮列表
//    tagStatus生成
//    先移除原来的UIImageView
    [self.checkedImageViewArray removeAllObjects];
    [self.tagStatusArray removeAllObjects];
    for (int i = 0; i < self.tagArray.count; i++) {
        int column = i  % 3;
        int row = i / 3;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:[self.tagArray[i]objectForKey:@"name"] forState:UIControlStateNormal];
        [button setBackgroundColor:self.colorArray[[[self.tagArray[i]objectForKey:@"backgroundColorType"] intValue]]];
        button.bounds = CGRectMake(0, 0, buttonWidth, buttonHeight);
        button.center = CGPointMake(width / 3.0 * (column + 0.5), CGRectGetMaxY(seperatedView.frame) + (buttonHeight + buttonMargin) * row + buttonHeight);
        [button addTarget:self action:@selector(tagButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 8.0;
        button.tag = i;
        [containerView addSubview:button];
//        再添加按钮上的对勾
        UIImageView *checkImageView = [[UIImageView alloc]init];
        checkImageView.bounds = CGRectMake(0, 0, buttonWidth, buttonHeight);
        checkImageView.center = CGPointMake(width / 3.0 * (column + 0.5), CGRectGetMaxY(seperatedView.frame) + (buttonHeight + buttonMargin) * row + buttonHeight);
        checkImageView.contentMode = UIViewContentModeScaleAspectFit;
        checkImageView.userInteractionEnabled = NO;
//        复显原选取项，做一出取反的操作即可
//        NSLog(@"count : %zi",self.tagStatusArray.count);
//        if (self.tagStatusArray.count > 0) {
//            checkImageView.hidden = ![self.tagStatusArray[i] boolValue];
//        }
        checkImageView.hidden = YES;
        checkImageView.image = [UIImage imageNamed:@"checked.png"];
        [self.checkedImageViewArray addObject:checkImageView];
        [containerView addSubview:checkImageView];
        
        [self.tagStatusArray addObject:[NSNumber numberWithBool:NO]];
    }

    //确定按钮生成
    CGFloat ButtonMaxY = CGRectGetMaxY(seperatedView.frame) + buttonMargin + (buttonHeight + buttonMargin) * ceil(self.tagArray.count / 3.0);
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [submitButton setTitle:@"确定" forState:UIControlStateNormal];
    submitButton.frame = CGRectMake(0, ButtonMaxY, SCREEN_WIDTH, buttonForSubmitHeight);
    submitButton.backgroundColor = MAIN_COLOR;
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(tagSubmitButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:submitButton];
    
    containerView.frame = CGRectMake(0, 0, width, ButtonMaxY + buttonForSubmitHeight);
    
    [[KGModal sharedInstance]showWithContentView:containerView andAnimated:YES];
}
#pragma mark 属性按钮点击
- (void)tagButtonPress:(UIButton *)button {
//    为自身状态取反
    self.tagStatusArray[button.tag] = [NSNumber numberWithBool:![self.tagStatusArray[button.tag] boolValue]];
//给自己加对勾或去掉对勾
    UIImageView *checkedImageView = self.checkedImageViewArray[button.tag];
    checkedImageView.hidden = ![self.tagStatusArray[button.tag] boolValue];
    
}

#pragma mark 标签tag选择确定按钮点击
- (void)tagSubmitButtonPress {
//先删除原来的所有按钮
    for (UIButton *button in self.selectedTagContainerView.subviews) {
        [button removeFromSuperview];
    }
    [[KGModal sharedInstance] hideAnimated:YES withCompletionBlock:^{
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationAutomatic];
//        刷新单元格高度
        [self.tableView reloadData];
//        设置已选内容
        
        CGFloat width = self.selectedTagContainerView.frame.size.width;
        CGFloat buttonWidth = 80.0;
        CGFloat buttonHeight = 30.0;
        CGFloat buttonMargin = 20.0;
        BOOL hasSelectedButton = NO;
        int iPosition = 0;
        for (int i = 0; i < self.tagArray.count; i++) {
            NSNumber *tagStatus = self.tagStatusArray[i];
            if ([tagStatus boolValue]) {
                hasSelectedButton = YES;
                int column = iPosition  % 3;
                int row = iPosition / 3;
                UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
                button.titleLabel.font = [UIFont systemFontOfSize:15.0];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button setTitle:[self.tagArray[i] objectForKey:@"name"] forState:UIControlStateNormal];
                [button setBackgroundColor:self.colorArray[[[self.tagArray[i]objectForKey:@"backgroundColorType"] intValue]]];
                button.bounds = CGRectMake(0, 0, buttonWidth, buttonHeight);
                button.center = CGPointMake(width / 3.0 * (column + 0.5), CGRectGetMinY(self.selectedTagContainerView.frame) + (buttonHeight + buttonMargin / 2) * row + 23.0);
                [button addTarget:self action:@selector(pickTag:) forControlEvents:UIControlEventTouchUpInside];
                button.layer.cornerRadius = 8.0;
                [self.selectedTagContainerView addSubview:button];
                iPosition ++;
            }
        }
        //一旦有选择任何一个标签，那么就隐藏默认的标签
        if (hasSelectedButton) {
            self.tagButton.hidden = YES;
        } else {
            self.tagButton.hidden = NO;
        }
    }];
}

#pragma mark 加载原来的Tag
- (void)loadTag {
    self.isInitForTag = YES;
    BmobQuery *tagQuery = [BmobQuery queryWithClassName:@"Tag"];
    [tagQuery orderByAscending:@"rank"];
    [tagQuery whereObjectKey:@"tag" relatedTo:self.user];
    [tagQuery findObjectsInBackgroundWithBlock:^(NSArray *tagArray, NSError *error) {
        CGFloat width = self.selectedTagContainerView.frame.size.width;
        CGFloat buttonWidth = 80.0;
        CGFloat buttonHeight = 30.0;
        CGFloat buttonMargin = 20.0;
        self.userSavedTagArry = tagArray;
        for (int i = 0; i < tagArray.count; i++) {
            int column = i  % 3;
            int row = i / 3;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.titleLabel.font = [UIFont systemFontOfSize:15.0];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitle:[tagArray[i] objectForKey:@"name"] forState:UIControlStateNormal];
            [button setBackgroundColor:self.colorArray[[[tagArray[i]objectForKey:@"backgroundColorType"] intValue]]];
            button.bounds = CGRectMake(0, 0, buttonWidth, buttonHeight);
            button.center = CGPointMake(width / 3.0 * (column + 0.5), CGRectGetMinY(self.selectedTagContainerView.frame) + (buttonHeight + buttonMargin / 2) * row + 23.0);
            [button addTarget:self action:@selector(pickTag:) forControlEvents:UIControlEventTouchUpInside];
            button.layer.cornerRadius = 8.0;
            [self.selectedTagContainerView addSubview:button];
        }
        if (tagArray.count > 0) {
            self.tagButton.hidden = YES;
        }
        [self.tableView reloadData];
    }];
    
    

}
#pragma mark 单元格高度
- (CGFloat)tableView:tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 4) {
//        运算出用户选择了几个Tag，然后得出高度
        NSInteger selectedTagCount = 0;
        for (NSNumber *tagStatus in self.tagStatusArray) {
            if ([tagStatus boolValue]) {
                selectedTagCount ++;
            }
        }
        //        为初始化加载适配高度
        if (self.isInitForTag) {
            selectedTagCount = self.userSavedTagArry.count;
        }
        selectedTagCount = selectedTagCount == 0 ? selectedTagCount = 1 : selectedTagCount;
        return ceil(selectedTagCount / 3.0) * 44.0;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark 年龄、肤质选择确定按钮点击
- (void)hiddenModalView {
    [[KGModal sharedInstance] hideAnimated:YES];
}

#pragma mark -
#pragma mark 选择器的代理方法

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.agePickView) {
        return self.ageArray.count;
    }
    return self.skinTypeArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.agePickView) {
        return [NSString stringWithFormat:@"%d",[self.ageArray[row] intValue]];
    }
    return [NSString stringWithFormat:@"%@",self.skinTypeArray[row]];
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40.0;
}
//选中某行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.agePickView) {
        [self.ageButton setTitle:[NSString stringWithFormat:@"%zi",row] forState:UIControlStateNormal];
    } else if (pickerView == self.skinTypePickView) {
        
        self.selectedSkinType = row;
        [self.skinTypeButton setTitle:self.skinTypeArray[row] forState:UIControlStateNormal];
    }
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
