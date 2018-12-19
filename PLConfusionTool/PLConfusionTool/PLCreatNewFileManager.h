////
//  PLCreatNewFileManager.h
//  PLConfusionTool
//
//  Created by ___Fitfun___ on 2018/12/13.
//Copyright © 2018年 penglei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLCreatNewFileManager : NSObject

//创建文件夹路径
- (BOOL)creatNewFileRootDirectory:(NSString *)rootPath path:(NSString *)path;
//给已有.m文件添加多余的方法
- (void)addConfusionMethondForExistClassM:(NSString *)path;
//自动生成的类名前缀
@property (nonatomic, copy)  NSString *classNamePrefix;
//每个文件下生成类的包含方法的数量
@property (nonatomic, assign) NSUInteger  methodMinCount;
@property (nonatomic, assign) NSUInteger  methodMaxCount;
//每个文件下生成的类数量范围
@property (nonatomic, assign) NSUInteger  classMinCount;
@property (nonatomic, assign) NSUInteger  classMaxCount;

@end

NS_ASSUME_NONNULL_END
