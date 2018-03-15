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

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
    
}


@end
