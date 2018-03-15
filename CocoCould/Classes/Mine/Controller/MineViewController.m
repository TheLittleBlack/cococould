//
//  MineViewController.m
//  CocoCould
//
//  Created by JayJay on 2018/3/5.
//  Copyright © 2018年 JayJay. All rights reserved.
//

#import "MineViewController.h"

@interface MineViewController ()

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"我的";
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WXLoginSuccess:) name:@"WXLoginSuccess" object:nil];
    
}

-(void)WXLoginSuccess:(NSNotification *)notification
{
    
    MyLog(@"登录授权成功，接下来获取access_token及用户信息");
    NSString *code = notification.userInfo[@"info"];
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
    
    NSString *loginURL = [NSString stringWithFormat:@"%@%@&deviceToken=%@",[MayiURLManage MayiWebURLManageWithURL:WXLogin],code,token];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:loginURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:6];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView loadRequest:request];
    });
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}




@end
