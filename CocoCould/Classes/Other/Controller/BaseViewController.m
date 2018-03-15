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
#import "LoadiPageViewController.h"
#import <UMSocialCore/UMSocialCore.h>
#import <UShareUI/UShareUI.h>

@interface BaseViewController ()<UIWebViewDelegate,UITabBarControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

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
    
    CGFloat ss = [self folderSize];
    NSLog(@"%f",ss);
    
    
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
    
    NSLog(@"开始加载");
    
    _progressLayer = [WYWebProgressLayer layerWithFrame:CGRectMake(0, 0, ScreenWidth, 3)];
    [self.view.layer addSublayer:_progressLayer];
    [_progressLayer startLoad];
    
    
}

//加载完成
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"加载完成");
    [Hud stop];
    [_progressLayer finishedLoad];
    
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    

    
    NSString *sss = [NSString stringWithFormat:@"updateIndustry({'codeValueCode':'14','codeValueName':'医疗'})"];
    [self.webView stringByEvaluatingJavaScriptFromString:sss];
    

    
    
    NSString *textJS = [NSString stringWithFormat:@"cacheAndVersion({'cache':'30M','version':'1.1.8'})"];
    [self.context evaluateScript:textJS];
    
            NSString *jsStr = [NSString stringWithFormat:@"updateIndustry({'codeValueCode':'14','codeValueName':'医疗'})"]; [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
    
//    设置缓存值和版本号   cacheAndVersion（{"cache":"30M","version":"1.1.8"}）
//    获取上传图片url     getPictrue（/test/2018/01/30/89c337bb54414df68b89d6e7129edb60.汽车.jpg,"headPortraitUrl"）
//    获取编码对象        updateIndustry（{"codeValueCode":"14","codeValueName":"医疗"}）
//    获取开票信息        getFinancial（{"id" : 1,"taxId" : "","billAddress" : "怒江北路","depositBank" : "招商","bankAccount" : "2131","tel" : "17621208540"）
//    获取object对象     getObject（object）
//    获取友盟token      getDeviceToken(token)
    
    // JS调用原生
    self.context[@"jsCallApp"] = self;
    
    
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{

    NSURL *URL = request.URL;
    NSString *urlStr = [NSString stringWithFormat:@"%@",URL];
    NSLog(@"请求的URL：%@",urlStr);
    
//    if([urlStr containsString:@"choose_industry.htm"])
//    {
//        LoadiPageViewController *LPVC = [LoadiPageViewController new];
//        LPVC.urlString = [NSString stringWithFormat:@"%@",urlStr];
//        LPVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:LPVC animated:YES];
//        return NO;
//    }
    
    return YES;
}




- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
    NSLog(@"web加载出错：%@",[error localizedDescription]);
    [Hud stop];
    [_progressLayer finishedLoad];
    
}


-(void)urlActionType:(NSString *)actionString
{
    NSLog(@"%@",actionString);
}


-(void)scanButtonAction
{
    NSLog(@"扫一扫");

}


-(void)loadPage:(NSDictionary *)dict  // 加载首页页面
{
    NSLog(@"%@",dict);
    LoadiPageViewController *LPVC = [LoadiPageViewController new];
    LPVC.urlString = [NSString stringWithFormat:@"%@%@",MainURL,dict[@"url"]];
    LPVC.titleString = [NSString stringWithFormat:@"%@",dict[@"title"]];
    LPVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:LPVC animated:YES];
    
}

-(void)cleanCache // 清除缓存
{
    NSLog(@"清除缓存");
    [self removeCache];
}
-(void)shared:(NSDictionary *)dict // 分享
{
    NSLog(@"分享");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showShareUIWithInfo:dict];
    });
    
}
-(void)checkVersion // 检测新版本
{
    NSLog(@"检测新版本");
    
    // 检测更新
    [MyNetworkRequest postRequestWithUrl:[MayiURLManage MayiURLManageWithURL:checkUpdate] withPrameters:@{} result:^(id result) {
        
        
        NSDictionary *dic = result[@"data"];
        //最新版本
        NSString *ver = [NSString stringWithFormat:@"%@",dic[@"lastVer"]];
        //更新内容
        NSString *updateContent = dic[@"updateContent"];
        //低于此版本需要强制更新
        NSString *mustUpdatedVer = [NSString stringWithFormat:@"%@",dic[@"mustUpdatedVer"]];
        
        NSInteger compareResults = [self CompareTheVersionWithLatestVersion:ver andMustUpdatedVer:mustUpdatedVer];
        
        // 0 代表无需更新 1 代表需要更新 2 代表需要强制更新
        
        if(compareResults==1)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"更新提示" message:updateContent preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"去更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self goToUpdatePagewith:dic[@"url"]];
                
            }]];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"下次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            
            [self presentViewController:alert animated:YES completion:^{
            }];
            
        }
        else
        {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"当前已是最新版本" preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            
            [self presentViewController:alert animated:YES completion:^{
            }];
            
        }
        
        
    } error:^(id error) {
        
    } withHUD:NO];

}

-(void)choosePicture:(NSString *)picUrl // 打开app上传图片功能
{
    NSLog(@"打开app上传图片功能");

    // 判断是否有权限
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) return;
    
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imgPicker.delegate = self;
    [self presentViewController:imgPicker animated:YES completion:nil];
    
}
-(void)chooseCode:(NSString *)code :(NSString *)name :(NSString *)type // 选择编码并关闭网页
{
    NSLog(@"选择编码并关闭网页");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.navigationController popViewControllerAnimated:YES];

        NSString *sss = [NSString stringWithFormat:@"updateIndustry({'codeValueCode':'14','codeValueName':'医疗'})"];
        [self.webView stringByEvaluatingJavaScriptFromString:sss];
        
        NSString *textJS = [NSString stringWithFormat:@"updateIndustry({'codeValueCode':'14','codeValueName':'医疗'})"];
        [self.context evaluateScript:textJS];
        
    });
    
    

    
//    updateIndustry（{"codeValueCode":"14","codeValueName":"医疗"}）
    
}
-(void)callPhone:(NSString *)phoneNumber // 打电话
{
    if(phoneNumber&&![phoneNumber isEqualToString:@""]&&![phoneNumber isEqualToString:@"null"])
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIWebView *callWebView = [[UIWebView alloc] init];
            NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNumber]];
            [callWebView loadRequest:[NSURLRequest requestWithURL:telURL]];
            [self.view addSubview:callWebView];
            
        });
        
    }
    
    NSLog(@"打电话");
}
-(void)saveFinancial:(NSString *)params // 保存公司开票信息并关闭页面
{
    NSLog(@"保存公司开票信息并关闭页面");
}
-(void)goMain // 返回主页
{
    NSLog(@"返回主页");
    
    dispatch_async(dispatch_get_main_queue(), ^{
         self.tabBarController.selectedIndex = 0;
    });
   
    
}
-(void)showLoading // 加载loding
{
    NSLog(@"加载loding");
}

- (void)wxLogin
{
    NSLog(@"微信登录");
    
    // 这个判断有毒?
    if([self booWeixin])
    {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"cococould";
        [WXApi sendReq:req];
    }
}

// 选择一个对象
-(void)setObject:(NSDictionary *)object
{
    NSLog(@"%@",object);
}

// 获取友盟token
-(void)getDeviceToken
{
    NSLog(@"获取友盟token");
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



- (void)shareType:(NSInteger )type withInfo:(NSDictionary *)shareInfo{
    
    
    /*
     创建网页内容对象
     根据不同需求设置不同分享内容，一般为图片，标题，描述，url
     */
    
    
    NSURL *url = [NSURL URLWithString:shareInfo[@"url"]];
    UIImage *shareImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"cocospace活动" descr:shareInfo[@"title"] thumImage:shareImage];
    
    //设置网页地址
    shareObject.webpageUrl = shareInfo[@"url"];
    
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    /**
     设置分享
     
     @param data 分享返回信息
     @param error 失败信息
     @param UMSocialPlatformType 分享平台
     */
    [[UMSocialManager defaultManager] shareToPlatform:type messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
    }];
    
}


-(void)showShareUIWithInfo:(NSDictionary *)shareInfo
{
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        
        NSLog(@"%lu\n====%@\n",platformType,userInfo);
        
        [self shareType:platformType withInfo:shareInfo];
        
    }];
}

// 缓存大小
- (CGFloat)folderSize{
    CGFloat folderSize = 0.0;
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)firstObject]; //获取所有文件的数组
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachePath];
    NSLog(@"文件数：%ld",files.count);
    for(NSString *path in files)
    {
        NSString*filePath = [cachePath stringByAppendingString:[NSString stringWithFormat:@"/%@",path]]; //累加
        folderSize += [[NSFileManager defaultManager]attributesOfItemAtPath:filePath error:nil].fileSize;
    
    }
    //转换为M为单位
    CGFloat sizeM = folderSize /1024.0/1024.0;
    
    return sizeM;
    
}

//===============清除缓存==============
- (void)removeCache{
    
    //获取路径
    NSString*cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)objectAtIndex:0]; //返回路径中的文件数组
    NSArray*files = [[NSFileManager defaultManager]subpathsAtPath:cachePath];
    NSLog(@"文件数：%ld",[files count]);
    for(NSString *p in files)
    {
        NSError*error; NSString*path = [cachePath stringByAppendingString:[NSString stringWithFormat:@"/%@",p]]; if([[NSFileManager defaultManager]fileExistsAtPath:path])
        {
            BOOL isRemove = [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
            if(isRemove) {
                NSLog(@"清除成功");
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"清除成功" preferredStyle:UIAlertControllerStyleAlert];
                
                [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alert animated:YES completion:^{
                    }];
                });
                
            }else{
                NSLog(@"清除失败");
                
            }
            
        }
        
    }
    
}


///判断是否需要更新
-(NSInteger )CompareTheVersionWithLatestVersion:(NSString *)latestVer andMustUpdatedVer:(NSString *)mustUpdatedVer
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 获取当前版本
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"当前版本号:%@",appCurVersion);
    
    NSInteger curVer = [[appCurVersion stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
    
    NSInteger latVer = [[latestVer stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
    
    NSInteger mustVer = [[mustUpdatedVer stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
    
    if(curVer<mustVer)
    {
        NSLog(@"需要强制更新");
        return 2;
    }
    
    if(latVer>curVer)
    {
        NSLog(@"需要更新版本");
        
        return 1;
    }
    
    NSLog(@"已是最新版本");
    
    return 0;
    
}
    


// 打开 safair 浏览器
-(void)goToUpdatePagewith:(NSString *)updateUrl
{
    NSString * urlStr = [NSString stringWithFormat:@"%@",updateUrl];
    NSURL *url = [NSURL URLWithString:urlStr];
    if([[UIDevice currentDevice].systemVersion floatValue] >= 10.0){
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [[UIApplication sharedApplication] openURL:url options:@{}
                                     completionHandler:^(BOOL success) {
                                         NSLog(@"Open %d",success);
                                     }];
        } else {
            BOOL success = [[UIApplication sharedApplication] openURL:url];
            NSLog(@"Open  %d",success);
        }
        
    } else{
        bool can = [[UIApplication sharedApplication] canOpenURL:url];
        if(can){
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}



#pragma mark - UINavigationControllerDelegate, UIImagePickerControllerDelegate
// 选择照片之后
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //    ChaosLog(@"%@",info);
    // 获取用户选择的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // 退出imagePickerController
    [self dismissViewControllerAnimated:YES completion:nil];
  
}



@end
