//
//  MYManage.h
//  Mayi_sales_app
//
//  Created by JayJay on 2017/12/12.
//  Copyright © 2017年 JayJay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MYManage : NSObject

//// token
//@property(nonatomic,strong)NSString *token;
//
//// data
//@property(nonatomic,strong)NSNumber *agencyId;
//@property(nonatomic,strong)NSString *agencyName;
//@property(nonatomic,strong)NSNumber *createOperator;
//@property(nonatomic,strong)NSNumber *customUserType;
//@property(nonatomic,strong)NSString *mobile; // 手机号码
//@property(nonatomic,strong)NSString *organizationName;
//@property(nonatomic,strong)NSNumber *status;
//@property(nonatomic,strong)NSString *userName;
//@property(nonatomic,strong)NSNumber *userType;
//@property(nonatomic,strong)NSString *ID;
//@property(nonatomic,strong)NSString *passport; // 账号
//
//// userInfo
// @property(nonatomic,strong)NSString *address;

@property(nonatomic,strong)NSString *code;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *type;
@property(nonatomic,strong)NSString *version;
@property(nonatomic,strong)NSDictionary *getObject;

+(instancetype)defaultManager;

-(void)setUserInfoWithDictionary:(NSDictionary *)dic;

-(void)setDataWithDictionary:(NSDictionary *)dic;

-(void)clearAllData;

@end
