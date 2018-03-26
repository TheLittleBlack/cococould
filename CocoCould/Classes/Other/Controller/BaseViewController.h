//
//  BaseViewController.h
//  CocoCould
//
//  Created by JayJay on 2018/3/5.
//  Copyright © 2018年 JayJay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "WYWebProgressLayer.h"

@protocol TestJSExport <JSExport>

-(void)wxLogin; // 微信登录
-(void)loadPage:(NSDictionary *)dict; // 加载首页页面
-(void)cleanCache; // 清楚缓存
-(void)shared:(NSDictionary *)dict; // 分享
-(void)checkVersion; // 检测新版本
-(void)choosePicture:(NSString *)picUrl; // 打开app上传图片功能
-(void)chooseCode:(NSString *)code :(NSString *)name :(NSString *)type; // 选择编码并关闭网页
-(void)callPhone:(NSString *)phoneNumber; // 打电话
-(void)saveFinancial:(NSString *)params; // 保存公司开票信息并关闭页面
-(void)goMain; // 返回主页
-(void)showLoading; // 加载loding
-(void)setObject:(NSDictionary *)object; // 选择一个对象
-(void)getDeviceToken; // 获取友盟token

@end

@interface BaseViewController : UIViewController<UIWebViewDelegate,TestJSExport>

{
    WYWebProgressLayer *_progressLayer; ///< 网页加载进度条
}

@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,copy)NSString *urlString;
@property(nonatomic,strong)JSContext *context;
@property(nonatomic,strong)NSURLRequest *request;
@property(nonatomic,assign)BOOL openMYRefresh; // 开启下拉刷新


@end
