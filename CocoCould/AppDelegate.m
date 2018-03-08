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

@interface AppDelegate ()<UITabBarControllerDelegate>

@property(nonatomic,strong)UITabBarController *tabBarController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 向微信终端程序注册第三方应用
    [WXApi registerApp:WXAPPID];
    
    // 设置cookie
    [self setCookie];
    
    // 获取当前版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *phoneVersion = [[UIDevice currentDevice] systemVersion];
    
    NSString *UserAgentString = [NSString stringWithFormat:@"{\"systemType\":\"iOS\",\"appVersion\":\"%@\",\"model\":\"model\",\"systemVersion\":\"%@\"}",appCurVersion,phoneVersion];
    MyLog(@"%@",UserAgentString);
    
    // 设置自定义 UserAgent 用于区分app调用H5  WebView会自动从NSUserDefaults中拿到UserAgent
    NSDictionary * dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:UserAgentString, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    [[NSUserDefaults standardUserDefaults] setObject:UserAgentString forKey:@"User-Agent"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _tabBarController = [UITabBarController new];
    [_tabBarController.tabBar setTintColor:MainColor];
    _tabBarController.tabBar.backgroundColor = [UIColor whiteColor];
    _tabBarController.delegate = self;
    
    [self creatViewControllerView:[HomeViewController new] andTitle:@"首页" andImage:@"tab_home_selected" andSelectedImage:@"tab_home_selected"];
    [self creatViewControllerView:[CommunityViewController new] andTitle:@"社区" andImage:@"tab_home_selected" andSelectedImage:@"tab_home_selected"];
    [self creatViewControllerView:[ActivityViewController new] andTitle:@"活动" andImage:@"tab_home_selected" andSelectedImage:@"tab_home_selected"];
    [self creatViewControllerView:[ServeViewController new] andTitle:@"服务" andImage:@"tab_home_selected" andSelectedImage:@"tab_home_selected"];
    [self creatViewControllerView:[MineViewController new] andTitle:@"我的" andImage:@"tab_home_selected" andSelectedImage:@"tab_home_selected"];
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    //此属性可以让导航栏的颜色与主题色保持一致，但会导致原本64的高度差消失！！！！！！！！！！！！！！！！！！！！！！！！！
    [UINavigationBar appearance].translucent = NO;
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]}   forState:UIControlStateNormal];
    
    [UIApplication sharedApplication].keyWindow.rootViewController = self.tabBarController;
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
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
    else if (self.tabBarController.selectedIndex==3)
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


@end
