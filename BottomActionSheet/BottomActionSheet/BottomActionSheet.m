//
//  BottomActionSheet.m
//  BottomActionSheet
//
//  Created by Zhuochenming on 16/2/26.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import "BottomActionSheet.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

// 文本高度
static CGFloat const TopLabelTextHeight = 45.0;
// 每个按钮的高度
static CGFloat const ButtonHeight = 45.0;
// 线高度
static CGFloat const SeparateLineWidth = 0.5;
// 取消按钮上面的间隔高度
static CGFloat const Margin = 8.0;



#define RGBColor(r, g, b) [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:1.0]
// 背景色
#define GlobelBgColor RGBColor(237, 240, 242)
// 分割线颜色
#define GlobelSeparatorColor RGBColor(226, 226, 226)
// 普通状态下的图片
#define normalImage [self createImageWithColor:RGBColor(255, 255, 255)]
// 高亮状态下的图片
#define highImage [self createImageWithColor:RGBColor(242, 242, 242)]



// 字体
#define HeitiLight(f) [UIFont fontWithName:@"STHeitiSC-Light" size:f]

@interface BottomActionSheet ()

@property (nonatomic, assign) NSInteger privateTag;

@property (nonatomic, weak) BottomActionSheet *actionSheet;

@property (nonatomic, weak) UIView *sheetView;

@property (nonatomic, copy) NSString *labelText;

@end

@implementation BottomActionSheet

- (instancetype)initWithDelegate:(id<BottomActionSheetDelegate>)delegate
                       labelText:(NSString *)title
                     CancelTitle:(NSString *)cancelTitle
                     OtherTitles:(NSString *)otherTitles, ... {
    
    BottomActionSheet *actionSheet = [self init];
    self.actionSheet = actionSheet;
    actionSheet.delegate = delegate;
    self.labelText = title;
    
    // 黑色遮盖
    actionSheet.frame = [UIScreen mainScreen].bounds;
    actionSheet.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication].keyWindow addSubview:actionSheet];
    actionSheet.alpha = 0.0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverClick)];
    [actionSheet addGestureRecognizer:tap];
    
    // sheet
    UIView *sheetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    sheetView.backgroundColor = GlobelBgColor;
    sheetView.alpha = 0.9;
    [[UIApplication sharedApplication].keyWindow addSubview:sheetView];
    self.sheetView = sheetView;
    sheetView.hidden = YES;
    self.privateTag = 1;
    
    NSString *curStr;
    va_list list;
    if(otherTitles) {
        [self setupBtnWithTitle:otherTitles];
        
        va_start(list, otherTitles);
        while ((curStr = va_arg(list, NSString *))) {
            [self setupBtnWithTitle:curStr];
            
        }
        va_end(list);
    }
    
    CGRect sheetViewF = sheetView.frame;
    
#pragma mark - add
    sheetViewF.size.height = ButtonHeight * _privateTag + Margin + (_labelText.length > 0 ? TopLabelTextHeight : 0);
    sheetView.frame = sheetViewF;
    
    // 取消按钮
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, sheetView.frame.size.height - ButtonHeight, ScreenWidth, ButtonHeight)];
    [btn setBackgroundImage:normalImage forState:UIControlStateNormal];
    [btn setBackgroundImage:highImage forState:UIControlStateHighlighted];
    [btn setTitle:cancelTitle forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = ScreenWidth > 320 ? HeitiLight(18) : HeitiLight(17);
    btn.tag = 0;
    [btn addTarget:self action:@selector(sheetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetView addSubview:btn];
    
    return actionSheet;
}

- (void)show {
    self.sheetView.hidden = NO;
    CGRect sheetViewF = self.sheetView.frame;
    sheetViewF.origin.y = ScreenHeight;
    self.sheetView.frame = sheetViewF;
    
    CGRect newSheetViewF = self.sheetView.frame;
    newSheetViewF.origin.y = ScreenHeight - self.sheetView.frame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.sheetView.frame = newSheetViewF;
        self.actionSheet.alpha = 0.8;
    }];
}

- (void)setupBtnWithTitle:(NSString *)title{
#pragma mark - add label
    if (_labelText.length > 0) {
        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, TopLabelTextHeight)];
        titleLbl.text = _labelText;
        titleLbl.textAlignment = NSTextAlignmentCenter;
        titleLbl.font = [UIFont systemFontOfSize:13.0];
        titleLbl.textColor = [UIColor grayColor];
        titleLbl.backgroundColor = [UIColor whiteColor];
        [self.sheetView addSubview:titleLbl];
    }
    
    // 创建按钮
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, (_labelText.length > 0 ? TopLabelTextHeight + SeparateLineWidth : 0) + (ButtonHeight + SeparateLineWidth) * (_privateTag - 1) , ScreenWidth, ButtonHeight)];
    [btn setBackgroundImage:normalImage forState:UIControlStateNormal];
    [btn setBackgroundImage:highImage forState:UIControlStateHighlighted];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = ScreenWidth > 320 ? HeitiLight(18) : HeitiLight(17);
    btn.tag = _privateTag;
    [btn addTarget:self action:@selector(sheetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetView addSubview:btn];
    
    _privateTag++;
}

- (void)coverClick {
    CGRect sheetViewF = self.sheetView.frame;
    sheetViewF.origin.y = ScreenHeight;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.sheetView.frame = sheetViewF;
        self.actionSheet.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.actionSheet removeFromSuperview];
        [self.sheetView removeFromSuperview];
    }];
}

- (void)sheetBtnClick:(UIButton *)btn {
    if (btn.tag == 0) {
        [self coverClick];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        [self.delegate actionSheet:self.actionSheet clickedButtonAtIndex:btn.tag];
        [self coverClick];
    }
}

- (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
