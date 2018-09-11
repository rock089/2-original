//
//  ViewController.m
//  2-original-BT
//
//  Created by apple on 2018/9/11.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UIButton *netWorkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [netWorkBtn setFrame:CGRectMake(100, 100, 80, 50)];
    [netWorkBtn setTitle:@"开始监控网络" forState:UIControlStateNormal];
    [netWorkBtn addTarget:self action:@selector(startMonotNetwork) forControlEvents:UIControlEventTouchUpInside];
    netWorkBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    netWorkBtn.backgroundColor = [UIColor purpleColor];
    
    [self.view addSubview:netWorkBtn];
    
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self startMonotNetwork];
    
}


-(void)startMonotNetwork
{
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:{
                NSLog(@"无网络");
                break;
            }
                
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                NSLog(@"WiFi网络");
                break;
            }
                
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                NSLog(@"3G网络");
                break;
            }
            case AFNetworkReachabilityStatusUnknown:{
                NSLog(@"4G网络");
                break;
            }
                
            default:
                
                break;
        }
    }];
    
    [manager startMonitoring];
}




@end
