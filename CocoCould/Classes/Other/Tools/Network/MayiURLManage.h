//
//  MayiURLManage.h
//  Mayi_sales_app
//
//  Created by JayJay on 2017/12/10.
//  Copyright © 2017年 JayJay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MayiURLManage : NSObject

typedef NS_ENUM(NSUInteger,MayiURLType) {
    
    checkUpdate, // 更新检测
    uploadImage, // 上传图片
    
};


typedef NS_ENUM(NSUInteger,MayiWebUrlType) {
    
    Home, // 首页
    Community, // 社区
    Activity, // 活动
    Serve, // 服务
    Mine, // 我的
    WXLogin, // 微信登录
    WXLoginWithYM, // 微信登录联合友盟
};

+(NSString *)MayiURLManageWithURL:(MayiURLType)MayiUrlType;
+(NSString *)MayiWebURLManageWithURL:(MayiWebUrlType)MayiWebUrlType;

@end
