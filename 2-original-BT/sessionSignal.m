//
//  sessionSignal.m
//  csmall
//
//  Created by rock on 16/2/27.
//  Copyright © 2016年 csmall. All rights reserved.
//

#import "sessionSignal.h"
@implementation sessionSignal
{
   AFHTTPSessionManager *manager;
}


+(instancetype)sharesessionSignal
{
    static sessionSignal *signal=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        signal=[[sessionSignal alloc]init];
    });
    return signal;
}

-(instancetype)init
{
    if ([super init]) {
        manager=[AFHTTPSessionManager manager];
        manager.responseSerializer=[AFHTTPResponseSerializer serializer];
         [self loadCookie];
    }
    return self;
}


-(void)requestDataWithUrl:(NSString *)url params:(NSDictionary *)params block:(Myblock )block
{

    [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        //NSLog(@"%lld", downloadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(nil,responseObject);
        [self refreshCookieWith:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(error,nil);
        [self refreshUserInfo:task];
    }];
    
}

-(void)postDataWithUrl:(NSString *)url params:(NSDictionary *)params block:(Myblock)block
{
    
    
    [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(nil,responseObject);
      [self refreshCookieWith:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(error,nil);
         [self refreshUserInfo:task];
    }];
    
}
-(void)deleteDataWithUrl:(NSString *)url params:(NSDictionary *)params block:(Myblock)block
{
    [manager DELETE:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        block(nil,responseObject);
        [self refreshCookieWith:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(error,nil);
    }];
}

-(void)putPathWithUrl:(NSString *)url params:(NSDictionary *)params block:(Myblock)block
{
    
   [manager PUT:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       block(nil,responseObject);
       [self refreshCookieWith:task];
   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       block(error,nil);
   }];

}


-(void)refreshUserInfo:(NSURLSessionDataTask*)task
{
    
    NSHTTPURLResponse * responses = (NSHTTPURLResponse *)task.response;
    
    NSLog(@"%@",responses);
    
    NSLog(@"responses.statusCode---》%ld",responses.statusCode);
    
    
    if (responses.statusCode == 401) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"relogin" object:nil];
    }
    
}

// 做cookie 持久化保存

-(void)refreshCookieWith:(NSURLSessionDataTask*)task
{
    
    
    NSHTTPURLResponse * responses = (NSHTTPURLResponse *)task.response;
    
        NSDictionary *fields = responses.allHeaderFields;
    
//        NSLog(@"%@",fields);
//        NSLog(@"%@",[fields objectForKey:@"Set-Cookie"]);
    
    if ([fields objectForKey:@"Set-Cookie"]) { // 更新cookie
        NSString *cookieStr = [NSString stringWithFormat:@"%@",[fields objectForKey:@"Set-Cookie"]];

        NSArray *cookieKey = [NSArray arrayWithArray:[cookieStr componentsSeparatedByString:@";"]];
        
        NSMutableString *targetStr = [[NSMutableString alloc]init];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        for (NSString *str in cookieKey) {
            
            if ([str containsString:@"remember-me="]) {
                if (targetStr.length>0) {
                    [targetStr insertString:[NSString stringWithFormat:@"%@;",str] atIndex:0];
                } else {
                    [targetStr appendFormat:@"%@;",str ];
                }
                
                NSRange range = [str rangeOfString:@"remember-me="];
                NSString *subStr = [str substringFromIndex:(range.location+range.length)];
                [dict setValue:subStr  forKey:@"remember-me"];
                
            }
            
            
            
            if ([str containsString:@"JSESSIONID="]) {
                NSRange range = [str rangeOfString:@"JSESSIONID="];
                NSString *subStr2;
                if ([str containsString:@" "]) {
                    NSArray *subArr = [NSArray arrayWithArray:[cookieStr componentsSeparatedByString:@" "]];
                    for (NSString *subStr in subArr) {
                        if ([subStr containsString:@"JSESSIONID="]) {
                            subStr2 = [str substringFromIndex:(range.location+range.length)];
                        }
                    }
                }else{
                    subStr2 = [str substringFromIndex:(range.location+range.length)];
                }
                [dict setValue:subStr2 forKey:@"JSESSIONID"];

            }
        }
        
//        NSLog(@"%@",dict);
        
        
     // 如果返回的set_cookie 中只有jssessionid 字段，就需要将之前保存的remember-me 重新保存
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSDictionary *cookieDic = [defaults objectForKey:@"set_cookie"];
        
        NSLog(@"%@",cookieDic);
        
        if (cookieDic && ![dict objectForKey:@"remember-me"]) {
            [dict setValue:[cookieDic objectForKey:@"remember-me"] forKey:@"remember-me"];
        }
        
        // 更新cookie
        
        [defaults setObject:[NSDictionary dictionaryWithDictionary:dict]  forKey:@"set_cookie"];
        [defaults synchronize];
        [self loadCookie];
    }
    
}


-(void)loadCookie
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *cookieDic = [defaults objectForKey:@"set_cookie"];
    
    NSLog(@"%@",[cookieDic class]);
    NSLog(@"%@",cookieDic);
    
    NSArray *cookieArr;
    
    if ([cookieDic isKindOfClass: [NSDictionary class]] && cookieDic.count>0) {
        cookieArr = [[NSArray alloc]initWithArray:[cookieDic allKeys]];
        [self clearCookies];
        for (NSString *key in cookieArr) {
            NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
            [cookieProperties setObject:key forKey:NSHTTPCookieName];
            [cookieProperties setObject:cookieDic[key] forKey:NSHTTPCookieValue];
            [cookieProperties setObject:@"pay.csmall.com" forKey:NSHTTPCookieDomain]; // 需要写入对应的网址
            [cookieProperties setObject:@"pay.csmall.com" forKey:NSHTTPCookieOriginURL];
            [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
            [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
            NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    
}


-(void)clearCookies{
    
    //获取所有cookies
    
    NSArray*array = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    for(NSHTTPCookie*cookie in array)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie: cookie];
    }
    
}




@end
