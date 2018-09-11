//
//  sessionSignal.h
//  csmall
//
//  Created by rock on 16/2/27.
//  Copyright © 2016年 csmall. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^Myblock) (NSError *err,id responseObject);

@interface sessionSignal : NSObject

+(instancetype)sharesessionSignal;


-(void)requestDataWithUrl:(NSString *)url params:(NSDictionary *)params block:(Myblock )block;

-(void)postDataWithUrl:(NSString *)url params:(NSDictionary *)params block:(Myblock )block;

-(void)deleteDataWithUrl:(NSString *)url params:(NSDictionary *)params block:(Myblock )block;

-(void)putPathWithUrl:(NSString *)url params:(NSDictionary *)params block:(Myblock )block;

@end
