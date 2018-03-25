//
//  HomeViewController.m
//  CocoCould
//
//  Created by JayJay on 2018/3/5.
//  Copyright © 2018年 JayJay. All rights reserved.
//

#import "HomeViewController.h"
#import "ScanQRCodeViewController.h"
#import "LoadiPageViewController.h"

#define ADTime 3  //广告时间

@interface HomeViewController ()

{
    BOOL _ForcedUpdate;
    NSString *_ForcedUpdateURL;
}

@property(nonatomic,strong)UIButton *daoJiShiButton;
@property(nonatomic,strong)UIImageView *imageView ;
@property(nonatomic,strong)UIWindow *window;
@property(nonatomic,weak)NSTimer *timer;
@property(nonatomic,strong)NSString *ForcedUpdateText;

@end

@implementation HomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_toolbar"]];
    
        UIBarButtonItem *scanButton = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"icon_scan"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]  style:UIBarButtonItemStylePlain target:self action:@selector(scanButtonAction)];
    
    self.navigationItem.rightBarButtonItems = @[scanButton];
    
    // 加载启动广告
    [self addLoadImage];
    
    // 更新检测
    [self checkUpdate];
    
    
    
    
}



-(void)scanButtonAction
{
    MyLog(@"扫一扫");
    ScanQRCodeViewController *SQVC = [ScanQRCodeViewController new];
    SQVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:SQVC animated:YES];
}


-(void)addLoadImage
{
    
    self.window = [UIApplication sharedApplication].keyWindow;
    self.imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pic_splash"]];
    [self.window addSubview:self.imageView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(ScreenWidth);
        make.height.mas_equalTo(ScreenHeight);
        make.center.equalTo(self.window);
        
    }];
    self.imageView.userInteractionEnabled = YES;
    
    [self createButton];
    
}

#pragma mark 创建按钮
-(void)createButton
{
    _daoJiShiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _daoJiShiButton.frame = CGRectMake(ScreenWidth-85, 30, 70, 36);
    _daoJiShiButton.backgroundColor = MyColor(0, 0, 0, 0.5);
    _daoJiShiButton.layer.cornerRadius = 18;
    _daoJiShiButton.layer.masksToBounds = YES;
    _daoJiShiButton.layer.borderWidth = 1.5;
    _daoJiShiButton.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5].CGColor;
    [_daoJiShiButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_daoJiShiButton setTitle:[NSString stringWithFormat:@"跳过  %d",ADTime] forState:UIControlStateNormal];
    _daoJiShiButton.titleLabel.font = [UIFont systemFontOfSize:15.5];
    [_daoJiShiButton addTarget:self action:@selector(goToHome) forControlEvents:UIControlEventTouchDown];
    [self.imageView addSubview:_daoJiShiButton];
    
    //创建定时器
    [self createTimer];
    
}

#pragma mark 创建定时器
-(void)createTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(daoJiShi:) userInfo:nil repeats:YES];
}


//定时器响应事件
-(void)daoJiShi:(NSTimer *)sender
{
    
    static int i = ADTime;
    
    if(i<=0)
    {
        return ;
    }
    
    i--;
    [_daoJiShiButton setTitle:[NSString stringWithFormat:@"跳过  %d",i] forState:UIControlStateNormal];
    if(i==0)
    {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            //延时1秒后移除
            [self goToHome];
            
        });
        
    }
}

-(void)goToHome
{
    [self.timer invalidate];
    self.timer = nil;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.imageView.alpha = 0;
        self.imageView.My_x = -(self.view.My_Width * 0.4)/2;
        self.imageView.My_y = -(self.view.My_Height * 0.4)/2;
        self.imageView.My_Width = self.view.My_Width * 1.4;
        self.imageView.My_Height = self.view.My_Height *1.4;
        
    } completion:^(BOOL finished) {
        
        [self.imageView removeFromSuperview];
        
    }];
    
    
    
}



-(void)checkUpdate
{
    
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
        else if (compareResults==2)
        {
            _ForcedUpdate = YES;
            _ForcedUpdateURL = dic[@"url"];
            self.ForcedUpdateText = updateContent;
            [self ForcedUpdateWithURL:dic[@"url"]];
            
        }
        else
        {
            MyLog(@"已是最新版本");
        }
        
        
        
        
        
    } error:^(id error) {
        
    } withHUD:NO];
    
}

//强制更新
-(void)ForcedUpdateWithURL:(NSString *)url
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"更新提示" message:self.ForcedUpdateText preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"去更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self goToUpdatePagewith:url];
        [self ForcedUpdateWithURL:url]; // 无限循环
        
    }]];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
    
}

///判断是否需要更新
-(NSInteger )CompareTheVersionWithLatestVersion:(NSString *)latestVer andMustUpdatedVer:(NSString *)mustUpdatedVer
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 获取当前版本
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    MyLog(@"当前版本号:%@",appCurVersion);
    
    NSInteger curVer = [[appCurVersion stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
    
    NSInteger latVer = [[latestVer stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
    
    NSInteger mustVer = [[mustUpdatedVer stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
    
    if(curVer<mustVer)
    {
        MyLog(@"需要强制更新");
        return 2;
    }
    
    if(latVer>curVer)
    {
        MyLog(@"需要更新版本");
        
        return 1;
    }
    
    MyLog(@"已是最新版本");
    
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











@end
