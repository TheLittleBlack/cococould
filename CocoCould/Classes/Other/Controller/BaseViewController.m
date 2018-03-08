//
//  BaseViewController.m
//  CocoCould
//
//  Created by JayJay on 2018/3/5.
//  Copyright © 2018年 JayJay. All rights reserved.
//

#import "BaseViewController.h"
#import "WYWebProgressLayer.h"
#import "UIView+Frame.h"
#import "WLWebProgressLayer.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "WXApi.h"

@interface BaseViewController ()<UIWebViewDelegate,UITabBarControllerDelegate>

{
    WYWebProgressLayer *_progressLayer; ///< 网页加载进度条
}

@property(nonatomic,strong)NSURLRequest *request;

@end

@implementation BaseViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.request)
    {
        [self.webView loadRequest:self.request];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
//    UIBarButtonItem *scanButton = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"icon_scan"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]  style:UIBarButtonItemStylePlain target:self action:@selector(scanButtonAction)];
//    
//    
//    self.navigationItem.rightBarButtonItems = @[scanButton];
    
    
    [self.view addSubview:self.webView];
    [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.left.and.right.and.bottom.equalTo(self.view);
        make.top.mas_equalTo(0);
        
    }];
    
    
    
    
    
}


-(UIWebView *)webView
{
    if(!_webView)
    {
        _webView = [UIWebView new];
        _webView.scalesPageToFit = YES;
        _webView.userInteractionEnabled = YES;
        _webView.delegate = self;
        NSURL *url = [NSURL URLWithString:self.urlString];
        self.request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:6];
        [_webView loadRequest:self.request];
    }
    return _webView;
}




#pragma mark <UIWebViewDelegate>

//开始加载
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_progressLayer finishedLoad]; // 先结束掉上个请求的进度
    
    MyLog(@"开始加载");
    
    _progressLayer = [WYWebProgressLayer layerWithFrame:CGRectMake(0, 0, ScreenWidth, 3)];
    [self.view.layer addSublayer:_progressLayer];
    [_progressLayer startLoad];
    
    
}

//加载完成
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    MyLog(@"加载完成");
    [Hud stop];
    [_progressLayer finishedLoad];
    
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    
//    NSString *textJS = [NSString stringWithFormat:@"findNearbyShop(%f,%f,'%@','gps')",self.longitude,self.latitude,self.locationName];
//    [self.context evaluateScript:textJS];
    
//    设置缓存值和版本号   cacheAndVersion（{"cache":"30M","version":"1.1.8"}）
//    获取上传图片url     getPictrue（/test/2018/01/30/89c337bb54414df68b89d6e7129edb60.汽车.jpg,"headPortraitUrl"）
//    获取编码对象        updateIndustry（{"codeValueCode":"14","codeValueName":"医疗"}）
//    获取开票信息        getFinancial（{"id" : 1,"taxId" : "","billAddress" : "怒江北路","depositBank" : "招商","bankAccount" : "2131","tel" : "17621208540"）
    
    // JS调用原生
    self.context[@"jsCallApp"] = self;
    
    
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{

    NSURL *URL = request.URL;
    NSString *urlStr = [NSString stringWithFormat:@"%@",URL];
    MyLog(@"请求的URL：%@",urlStr);
    
    return YES;
}




- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
    MyLog(@"web加载出错：%@",[error localizedDescription]);
    [Hud stop];
    [_progressLayer finishedLoad];
    
}


-(void)urlActionType:(NSString *)actionString
{
    
}


-(void)scanButtonAction
{
    MyLog(@"扫一扫");

}


-(void)loadPage:(NSDictionary *)dict  // 加载首页页面
{
    MyLog(@"%@",dict);
    
}

-(void)cleanCache // 清除缓存
{
    MyLog(@"清除缓存");
}
-(void)shared:(NSDictionary *)dict // 分享
{
    MyLog(@"分享");
}
-(void)checkVersion // 检测新版本
{
    MyLog(@"检测新版本");
}
-(void)choosePicture:(NSString *)picUrl // 打开app上传图片功能
{
    MyLog(@"打开app上传图片功能");
}
-(void)chooseCode:(NSDictionary *)dict // 选择编码并关闭网页
{
    MyLog(@"选择编码并关闭网页");
}
-(void)callPhone:(NSString *)phoneNumber // 打电话
{
    MyLog(@"打电话");
}
-(void)saveFinancial:(NSString *)params // 保存公司开票信息并关闭页面
{
    MyLog(@"保存公司开票信息并关闭页面");
}
-(void)goMain // 返回主页
{
    MyLog(@"返回主页");
}
-(void)showLoading // 加载loding
{
    MyLog(@"加载loding");
}

- (void)wxLogin
{
    MyLog(@"微信登录");
    
    // 这个判断有毒?
    if([self booWeixin])
    {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"cococould";
        [WXApi sendReq:req];
    }
}




// 判断是否安装微信及是否支持当前调用的api
-(BOOL)booWeixin{
    
//    [self showAlterWithTitle:@"如果未安装微信，请先安装"];
    
    if ([WXApi isWXAppInstalled])
    {
        //判断当前微信的版本是否支持OpenApi
        if ([WXApi isWXAppSupportApi])
        {
            return YES;
        }
        else{
            
            [self showAlterWithTitle:@"请升级微信至最新版本！"];
            return NO;
        }
        
    }else{
        
        [self showAlterWithTitle:@"请安装微信客户端"];
        return NO;
    }
    
}



// 弹出Alter
-(void)showAlterWithTitle:(NSString *)title
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    // 为了不产生延时的现象，直接放在主线程中调用
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self presentViewController:alert animated:YES completion:^{
        }];
        
    });
}


-(void)logCookie
{
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies) {
        NSDictionary *dict = cookie.properties;
        NSLog(@"+++++++++%@$+++++++++",dict);
    }
}

// 保存cookie
-(void)setCookie:(NSDictionary *)properties
{
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:[NSHTTPCookie cookieWithProperties:properties]];
}

// 清除cookie
-(void)deleteCookie
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieJar cookies])
    {
        [cookieJar deleteCookie:cookie];
    }
}





- (void)setCookie{
    
    NSString *domain = [MainURL stringByReplacingOccurrencesOfString:@"https://"withString:@""];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"systemType" forKey:NSHTTPCookieName];
    [cookieProperties setObject:@"iOS" forKey:NSHTTPCookieValue];
    [cookieProperties setObject:domain forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:60*60*24] forKey:NSHTTPCookieExpires];
    
    NSHTTPCookie *cookieuser = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookieuser];
}


    


@end
