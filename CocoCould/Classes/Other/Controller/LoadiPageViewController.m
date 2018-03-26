//
//  LoadiPageViewController.m
//  CocoCould
//
//  Created by JayJay on 2018/3/10.
//  Copyright © 2018年 JayJay. All rights reserved.
//

#import "LoadiPageViewController.h"
#import "UIBarButtonItem+customItem.h"

@interface LoadiPageViewController ()

@end

@implementation LoadiPageViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.titleString)
    {
        self.navigationItem.title = self.titleString;
    }
    else
    {
        self.navigationItem.title = @"cocospace";
    }
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem BackButtonItemWithTarget:self action:@selector(back)];
    
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
    NSLog(@"web加载出错：%@",[error localizedDescription]);
    [Hud stop];
    [_progressLayer finishedLoad];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSURL *URL = request.URL;
    NSString *urlStr = [NSString stringWithFormat:@"%@",URL];
    NSLog(@"请求的URL：%@",urlStr);
    
    if([urlStr containsString:@"cocospace.com.cn/login"])
    {
        self.navigationItem.title = @"我的";
    }
    
    
    
    if([urlStr containsString:@"open_agreement.htm"])
    {
        [MYManage defaultManager].homeRefresh = NO;
    }
    
    
    NSString *code = [MYManage defaultManager].code;
    NSString *name = [MYManage defaultManager].name;
    NSString *type = [MYManage defaultManager].type;
    
    if(code)
    {
        // 选择标签
        NSString *updateIndustry = [NSString stringWithFormat:@"appCallJs.updateIndustry(\"%@\",\"%@\",\"%@\")",code,name,type];
        [self.context evaluateScript:updateIndustry];
        
        // 生效后重置
        [MYManage defaultManager].code = NULL;
        [MYManage defaultManager].name = NULL;
        [MYManage defaultManager].type = NULL;
        
        return NO;
    }
    
    NSDictionary *object = [MYManage defaultManager].getObject;
    
    if(object)
    {
        NSString *jsonStr = [self dictionaryToJson:object];
        NSString *jsStr = [NSString stringWithFormat:@"appCallJs.getObject(%@)",jsonStr];
        NSLog(@"%@",jsStr);
        
        [self.context evaluateScript:jsStr];
        
        [MYManage defaultManager].getObject = NULL; // 重置
        
        return NO;
    }
    
    return YES;
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
    
    // 原生点击返回按钮调用 为了js局部刷新
    NSString *jsString = [NSString stringWithFormat:@"appCallJs.retreatCallBack()"];
    [self.context evaluateScript:jsString];
    
}


// 将对象转化为json格式
-(NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


@end
