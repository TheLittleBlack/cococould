//
//  AppDelegate.m
//  CocoCould
//
//  Created by JayJay on 2018/3/5.
//  Copyright © 2018年 JayJay. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "CommunityViewController.h"
#import "ActivityViewController.h"
#import "ServeViewController.h"
#import "MineViewController.h"
#import "WXApi.h"
#import <UMSocialCore/UMSocialCore.h>
#import <UMessage.h>

@interface AppDelegate ()<UITabBarControllerDelegate,UNUserNotificationCenterDelegate>

@property(nonatomic,strong)UITabBarController *tabBarController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 向微信终端程序注册第三方应用
    [WXApi registerApp:WXAPPID];
    
    // 配置友盟推送
    [self configureUMessageWithLaunchOptions:launchOptions];
    
    // 注册友盟分享
    [[UMSocialManager defaultManager] setUmSocialAppkey:uMengKey];
    
    // 友盟分享 => 微信
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:WXAPPID appSecret:WXSecret redirectURL:@"http://mobile.umeng.com/social"];
    
    // 移除不需要显示的平台
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformType:UMSocialPlatformType_TencentWb];
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformType:UMSocialPlatformType_Sms];
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformType:UMSocialPlatformType_Email];
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformType:UMSocialPlatformType_Renren];
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformType:UMSocialPlatformType_Facebook];
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformType:UMSocialPlatformType_Twitter];
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformType:UMSocialPlatformType_KakaoTalk];
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformType:UMSocialPlatformType_Douban];
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformType:UMSocialPlatformType_Pinterest];
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformType:UMSocialPlatformType_Line];
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformType:UMSocialPlatformType_Linkedin];
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformType:UMSocialPlatformType_DropBox];
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformType:UMSocialPlatformType_VKontakte];

    

    
    // 设置cookie
    [self setCookie];
    
    // 获取当前版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *phoneVersion = [[UIDevice currentDevice] systemVersion];
    
    NSString *UserAgentString = [NSString stringWithFormat:@"{\"systemType\":\"iOS\",\"appVersion\":\"%@\",\"model\":\"model\",\"systemVersion\":\"%@\"}",appCurVersion,phoneVersion];
    MyLog(@"%@",UserAgentString);
    
    [MYManage defaultManager].version = appCurVersion;
    
    // 设置自定义 UserAgent 用于区分app调用H5  WebView会自动从NSUserDefaults中拿到UserAgent
    NSDictionary * dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:UserAgentString, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    [[NSUserDefaults standardUserDefaults] setObject:UserAgentString forKey:@"User-Agent"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _tabBarController = [UITabBarController new];
    [_tabBarController.tabBar setTintColor:MainColor];
    _tabBarController.tabBar.backgroundColor = [UIColor whiteColor];
    _tabBarController.delegate = self;
    
    [self creatViewControllerView:[HomeViewController new] andTitle:@"首页" andImage:@"icon_home" andSelectedImage:@"icon_home_selected"];
    [self creatViewControllerView:[CommunityViewController new] andTitle:@"社区" andImage:@"icon_community" andSelectedImage:@"icon_community_selected"];
    [self creatViewControllerView:[ActivityViewController new] andTitle:@"活动" andImage:@"icon_activity" andSelectedImage:@"icon_activity_selected"];
    [self creatViewControllerView:[ServeViewController new] andTitle:@"服务" andImage:@"icon_service" andSelectedImage:@"icon_service_selected"];
    [self creatViewControllerView:[MineViewController new] andTitle:@"我的" andImage:@"icon_mine" andSelectedImage:@"icon_mine_selected"];
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    //此属性可以让导航栏的颜色与主题色保持一致，但会导致原本64的高度差消失！！！！！！！！！！！！！！！！！！！！！！！！！
    [UINavigationBar appearance].translucent = NO;
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]}   forState:UIControlStateNormal];
    
    [UIApplication sharedApplication].keyWindow.rootViewController = self.tabBarController;
//    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = _tabBarController;
    [self.window makeKeyAndVisible];
    
  
    
    
    return YES;
}



//创建视图控制器
-(void)creatViewControllerView:(BaseViewController *)VC andTitle:(NSString *)titleString andImage:(NSString *)image andSelectedImage:(NSString *)selectedImage
{
    if([titleString isEqualToString:@"首页"])
    {
        VC.urlString = [MayiURLManage MayiWebURLManageWithURL:Home];
    }
    else if([titleString isEqualToString:@"社区"])
    {
        VC.urlString = [MayiURLManage MayiWebURLManageWithURL:Community];
    }
    else if([titleString isEqualToString:@"活动"])
    {
        VC.urlString = [MayiURLManage MayiWebURLManageWithURL:Activity];
    }
    else if([titleString isEqualToString:@"服务"])
    {
        VC.urlString = [MayiURLManage MayiWebURLManageWithURL:Serve];
    }
    else if([titleString isEqualToString:@"我的"])
    {
        VC.urlString = [MayiURLManage MayiWebURLManageWithURL:Mine];
    }
    VC.tabBarItem.title = titleString;
    VC.tabBarItem.image =[[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    VC.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UINavigationController *NVC = [[UINavigationController alloc]initWithRootViewController:VC];
    [_tabBarController addChildViewController:NVC];
    
    
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


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if(self.tabBarController.selectedIndex==0)
    {
        // 点击了首页
        BaseViewController *homeVC = (BaseViewController *)[self topViewController];
        
        NSString *loginURL = [NSString stringWithFormat:@"%@",[MayiURLManage MayiWebURLManageWithURL:Home]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:loginURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:6];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [homeVC.webView loadRequest:request];
        });
        
    }
    else if (self.tabBarController.selectedIndex==1)
    {
        
        BaseViewController *CommunityVC = (BaseViewController *)[self topViewController];
        
        NSString *loginURL = [NSString stringWithFormat:@"%@",[MayiURLManage MayiWebURLManageWithURL:Community]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:loginURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:6];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [CommunityVC.webView loadRequest:request];
        });
    }
    else if (self.tabBarController.selectedIndex==2)
    {
       
        BaseViewController *ActivityVC = (BaseViewController *)[self topViewController];
        
        NSString *loginURL = [NSString stringWithFormat:@"%@",[MayiURLManage MayiWebURLManageWithURL:Activity]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:loginURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:6];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [ActivityVC.webView loadRequest:request];
        });
    }
    else if (self.tabBarController.selectedIndex==3)
    {
        
        BaseViewController *ServeVC = (BaseViewController *)[self topViewController];
        
        NSString *loginURL = [NSString stringWithFormat:@"%@",[MayiURLManage MayiWebURLManageWithURL:Serve]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:loginURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:6];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [ServeVC.webView loadRequest:request];
        });
    }
    else if (self.tabBarController.selectedIndex==4)
    {
      
        BaseViewController *mineVC = (BaseViewController *)[self topViewController];
        
        NSString *loginURL = [NSString stringWithFormat:@"%@",[MayiURLManage MayiWebURLManageWithURL:Mine]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:loginURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:6];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [mineVC.webView loadRequest:request];
        });
    }
    
    
}



//获取当前屏幕显示的viewcontroller
- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

- (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    
    NSString *urlString = [NSString stringWithFormat:@"%@",url];

    // 微信跳转回来的
    if([urlString containsString:WXAPPID])
    {
        // 登录回调
        if([urlString containsString:@"oauth"])
        {
            // 分割获取code  @"wxfe2e1687ec8a27af://oauth?code=001SpTig1XcNJy0pDAjg1kExig1SpTiz&state=mayi_shop"
            
            NSArray *arrayA = [urlString componentsSeparatedByString:@"code="];
            NSString *stringA = arrayA[1];
            NSArray *arrayB = [stringA componentsSeparatedByString:@"&"];
            NSString *code = arrayB[0];
            
            MyLog(@"%@",code);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WXLoginSuccess" object:self userInfo:@{@"info":code}];
        }
        
    }
    
    [WXApi handleOpenURL:url delegate:nil];
    
    return YES;
}


// 支持所有iOS系统版本回调
//-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
//{
//    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
//    if (!result) {
//        // 其他如支付等SDK的回调
//    }
//    return result;
//}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

// ===================================================================
// 友盟推送相关

- (void)configureUMessageWithLaunchOptions:(NSDictionary *)launchOptions {
    
    //设置AppKey & LaunchOptions
    [UMessage startWithAppkey:uMengPushKey launchOptions:launchOptions];
    
    //推送注册
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    
    //开启log
    [UMessage setLogEnabled:YES];
    //检查是否为iOS 10以上版本
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0) {
        
    } else {
        //如果是iOS 10以上版本则必须执行以下操作
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate=self;
        UNAuthorizationOptions types10 = UNAuthorizationOptionBadge|  UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
        [center requestAuthorizationWithOptions:types10   completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //点击允许
                //这里可以添加一些自己的逻辑
            } else {
                //点击不允许
                //这里可以添加一些自己的逻辑
            }
        }];
        
    }
}


-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    NSLog(@"按钮：identifier:%@",identifier);//
    
    [UMessage sendClickReportForRemoteNotification:userInfo];
    //通过identifier对各个交互式的按钮进行业务处理
}


//iOS10之前使用这个方法接收通知
// 前台状态
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    NSString *url = userInfo[@"pathUrl"];
    
    // 当应用在前台时，不推送
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        //关闭对话框
        [UMessage setAutoAlert:NO];
        //        [self goToMessageDetails:url];
        
    }
    [UMessage didReceiveRemoteNotification:userInfo];
}

// 后台状态
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    NSString *url = userInfo[@"pathUrl"];
    
    // 当应用在前台时，不推送
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        //关闭对话框
        [UMessage setAutoAlert:NO];
        //        [self goToMessageDetails:url];
        
    }
    [UMessage didReceiveRemoteNotification:userInfo];
}


//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    MyLog(@"%@",userInfo);
    
    NSString *url = userInfo[@"pathUrl"];
    MyLog(@"url:%@",url);
    
    //    [self goToMessageDetails:url];
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        
        
        //可以自定义前台弹出框
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userInfoNotification" object:self userInfo:userInfo];
        
        //应用处于前台时的远程推送接受
        //关闭友盟自带的弹出框
        [UMessage setAutoAlert:NO];
        //        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
    }else{
        //应用处于前台时的本地推送接受
    }
    //当应用处于前台时提示设置，需要哪个可以设置哪一个
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

//iOS10新增：处理后台点击通知的代理方法
//iOS10以后接收的方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    NSLog(@"后台括号外：userNotificationCenter:didReceiveNotificationResponse");
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"后台括号内：userNotificationCenter:didReceiveNotificationResponse");
        
        //        代理方法
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userInfoNotification" object:self userInfo:userInfo];
        
        [UMessage didReceiveRemoteNotification:userInfo];
        if([response.actionIdentifier isEqualToString:@"*****你定义的action id****"])
        {
            
        }else
        {
            
        }
        //这个方法用来做action点击的统计
        [UMessage sendClickReportForRemoteNotification:userInfo];
        
    }else{
        //应用处于后台时的本地推送接受
    }
    
    
    NSString *url = userInfo[@"pathUrl"];
    
    //    [self goToMessageDetails:url];
}



//获取device_Token
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    [UMessage registerDeviceToken:deviceToken];
    NSString *dt = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                    stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    MyLog(@"deviceToken:%@",dt);
    // 保存
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 保存用户偏好设置
    if(dt)
    {
        [defaults setObject:dt forKey:@"deviceToken"];
    }
    else
    {
        [defaults setObject:@" " forKey:@"deviceToken"];
    }
    [defaults synchronize]; // 立刻保存（默认是定时保存）
}

@end
