//
//  MayiURLManage.m
//  Mayi_sales_app
//
//  Created by JayJay on 2017/12/10.
//  Copyright © 2017年 JayJay. All rights reserved.
//

#import "MayiURLManage.h"

@implementation MayiURLManage


+(NSString *)MayiURLManageWithURL:(MayiURLType)MayiUrlType
{
    
    NSString *baseURL;
    
    switch (MayiUrlType)
    {

        case checkUpdate:
        {
            baseURL = @"/check_for_update.htm"; //更新检测
        }
            break;
        
    }
    
    // 判断环境    0 使用测试服务器     1 使用正式服务器
    
    NSString *url = [MainURL stringByAppendingString:baseURL];
    
    MyLog(@"URL = %@",url);
    
    return url;
    
}




+(NSString *)MayiWebURLManageWithURL:(MayiWebUrlType)MayiWebUrlType
{

    
    NSString *baseURL;
    
    switch (MayiWebUrlType)
    {
        case Home:
        {
            baseURL = @"/index.htm"; //首页
        }
            break;
        case Community:
        {
            baseURL = @"/site/site_distribute.htm"; // 社区
        }
            break;
        case Activity:
        {
            baseURL = @"/activities/activities_list.htm"; // 活动
        }
            break;
        case Serve:
        {
            baseURL = @"/facilitator/facilitator_list.htm"; // 服务
        }
            break;
        case Mine:
        {
            baseURL = @"/user/myProfile.htm"; // 我的
        }
            break;
        case WXLogin:
        {
            baseURL = @"/loginCallback.htm?app_login_code="; // 微信登录
        }
            break;

    }
    
    // 判断环境    0 使用测试服务器     1 使用正式服务器
    
    NSString *url = [MainURL stringByAppendingString:baseURL];
    
    MyLog(@"URL = %@",url);
    
    
    return url;
    
}

@end
