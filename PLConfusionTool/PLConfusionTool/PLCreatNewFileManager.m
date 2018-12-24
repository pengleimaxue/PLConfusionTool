////
//  PLCreatNewFileManager.m
//  PLConfusionTool
//
//  Created by ___Fitfun___ on 2018/12/13.
//Copyright © 2018年 penglei. All rights reserved.
//

#import "PLCreatNewFileManager.h"
#import "MGTemplateEngine.h"
#import "ICUTemplateMatcher.h"
#import "modifyProjectTool.m"

@interface PLCreatNewFileManager ()

@property (nonatomic, strong) NSMutableArray *fileArray;
@property (nonatomic, strong) NSArray *channelArray;
@end

@implementation PLCreatNewFileManager
- (instancetype )init {
    if (self = [super init]) {
        self.classNamePrefix = @"PLConfusionTest";
        self.methodMinCount = 2;
        self.methodMaxCount = 8;
        self.classMinCount = 10;
        self.classMaxCount = 15;
        self.channelArray = @[
                              @"HW",
                              @"CN",
                              @"TW",
                              @"Other"
                              ];
    }
    return self;
}

//创建文件夹
- (BOOL)creatNewFileRootDirectory:(NSString *)rootPath path:(NSString *)path {
    NSArray *pathArray = [path componentsSeparatedByString:@"&"];
    self.fileArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isCreated = NO;
    BOOL existed = NO;
    NSError *error;
    for (NSString *fielPath in pathArray) {
         existed = [fileManager fileExistsAtPath:[rootPath stringByAppendingString:fielPath] isDirectory:&isDir];
        if (existed == YES) {
            [fileManager removeItemAtPath:[rootPath stringByAppendingString:fielPath] error:nil];
            isDir = NO;
        }
        existed = [fileManager fileExistsAtPath:[rootPath stringByAppendingString:fielPath] isDirectory:&isDir];
        if (isDir == NO && existed == NO) {
          isCreated = [fileManager createDirectoryAtPath:[rootPath stringByAppendingString:fielPath] withIntermediateDirectories:YES attributes:nil error:&error];
           // NSLog(@"error%@",error);
            if (isCreated == NO) {
                return NO;
            } else {
                [self.fileArray addObject:[rootPath stringByAppendingString:fielPath]];
            }
        } 
       
       
    }
    
    //给已有类添加方法
    if (self.selectClassFilePath && self.selectClassFilePath.length) {
        [self addConfusionMethondForExistClassM:self.selectClassFilePath];
    }
    if (self.selectAssetsPath && self.selectAssetsPath.length) {
        handleXcassetsFiles(self.selectAssetsPath);
    }
    //修改项目名称
    if (self.isNeedRenameProjectName) {
        [self renamProject:rootPath];
    }
    
    return [self creatClass];
}

- (BOOL)creatClass {
    NSString *sourceHName = [@"ClassTemplate" stringByAppendingFormat:@"%@_h",self.channelArray[self.selectChannel]];
    NSString *sourceMName = [@"ClassTemplate" stringByAppendingFormat:@"%@_m",self.channelArray[self.selectChannel]];
    NSString *templatePath_h = [[NSBundle mainBundle] pathForResource:sourceHName ofType:@"txt"];
    NSString *templatePath_m = [[NSBundle mainBundle] pathForResource:sourceMName ofType:@"txt"];
    
    MGTemplateEngine *engine = [MGTemplateEngine templateEngine];

    [engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
   
    for (NSString *path in self.fileArray) {
        
        NSUInteger classCout = [self getRandomNumber:self.classMinCount to:self.classMaxCount];
        for (NSInteger i = 0; i<classCout; i++) {
            NSString *className = [self getRandomClassName];
            NSDictionary *variables = @{
                                        @"Param": [self getRandomMethodArray],
                                        @"ClassName":className,
                                        @"CurrentDate":[self currentDate],
                                        @"CurrentYear":[self currentYear]
                                        };
            NSString *resultH = [engine processTemplateInFileAtPath:templatePath_h withVariables:variables];
            NSString *resultM = [engine processTemplateInFileAtPath:templatePath_m withVariables:variables];
            NSError *error = nil;
            BOOL isSuccessH = [resultH writeToFile:[path stringByAppendingString:[NSString stringWithFormat:@"/%@.h", className]] atomically:YES encoding:NSUTF8StringEncoding error:&error];
            BOOL isSuccessM = [resultM writeToFile:[path stringByAppendingString:[NSString stringWithFormat:@"/%@.m", className]] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            if (isSuccessH && isSuccessM) {
                NSLog(@"success");
            } else {
                return NO;
            }
        }
        
    }
    //[self beginRunRuby];
//    if (self.fileArray.count) {
//        [self showAllFileWithPath:self.fileArray[0]];
//    }
 
    return YES;
    
}

//给已有.m文件添加多余的方法
- (void)addConfusionMethondForExistClassM:(NSString *)path {
    [self showAllFileWithPath:path];
}

//遍历所有.m文件
- (void)showAllFileWithPath:(NSString *) path {
    NSFileManager * fileManger = [NSFileManager defaultManager];
     NSString *addClassMethond_m = [[NSBundle mainBundle] pathForResource:@"addClassMethodTemplate_m" ofType:@"txt"];
    NSString *addCalass_mContent =  [[NSString alloc] initWithContentsOfFile:addClassMethond_m encoding:NSUTF8StringEncoding error:nil];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:nil];
            NSString * subPath = nil;
            for (NSString * str in dirArray) {
                subPath  = [path stringByAppendingPathComponent:str];
                BOOL issubDir = NO;
                [fileManger fileExistsAtPath:subPath isDirectory:&issubDir];
                [self showAllFileWithPath:subPath];
            }
        }else{
            MGTemplateEngine *engine = [MGTemplateEngine templateEngine];
            
            [engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
            
            NSString *fileName = [[path componentsSeparatedByString:@"/"] lastObject];
            if ([fileName hasSuffix:@".m"] || [fileName hasSuffix:@".mm"]) {
                NSString *OriginalClass_m = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
               ;
                NSString *className = [self getRandomClassName];
                NSDictionary *variables = @{
                                            @"Param": [self getRandomMethodArray],
                                            @"ClassName":className
                                            };
                NSString *novelOriginalClass_m  = [self serachClassAllMethond:OriginalClass_m];
                //NSString *resultM = [engine processTemplateInFileAtPath:[OriginalClass_m stringByAppendingString:addClassMethond_m] withVariables:variables];
              NSString *resultM =  [engine processTemplate:[novelOriginalClass_m stringByAppendingString:addCalass_mContent] withVariables:variables];
                BOOL isSuccessH = [resultM writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
                if (isSuccessH) {
                    //NSLog(@"写入文件成功");
                }
                
                
            }
        }
    } else {
        //NSLog(@"this path is not exist!");
    }
}

- (void)renamProject:(NSString *)path {
    NSFileManager * fileManger = [NSFileManager defaultManager];
     BOOL isDir = NO;
     BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isDir && isExist) {
         NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:nil];
        NSString * subPath = nil;
        for (NSString * str in dirArray) {
            subPath  = [path stringByAppendingPathComponent:str];
            if ([str containsString:@"xcodeproj"]) {
                NSString *oldProjectName = [str componentsSeparatedByString:@"."].firstObject;
                NSString *projectPbxprojFilePath = [subPath stringByAppendingPathComponent:@"project.pbxproj"];
                 if ([fileManger fileExistsAtPath:projectPbxprojFilePath]) {
                     modifyProjectName(path, oldProjectName, self.novelProjectName);
                 }
                break;
            }
        }
    }
    
}

//遍历.m,找到所有方法，在方法中插入对应的随机的混淆代码

- (NSString *)serachClassAllMethond:(NSString *)classNameString {
    NSMutableString * newClassString = [[NSMutableString alloc]initWithString:classNameString];
     NSString *addCodesourceMName = [@"addCodeToClassMethodTemplate" stringByAppendingFormat:@"%@_m",self.channelArray[self.selectChannel]];
     NSString *addCodeToClassMethond_mPath = [[NSBundle mainBundle] pathForResource:addCodesourceMName ofType:@"txt"];
     NSString *addCodeToClassMethond_m =[[NSString alloc] initWithContentsOfFile:addCodeToClassMethond_mPath encoding:NSUTF8StringEncoding error:nil];
    NSUInteger countNewMethond = 0;
     NSInteger bracesPrefixCount = 0;
    BOOL isCanAdd = NO;
    NSMutableString *variableName = [[NSMutableString alloc] initWithCapacity:0];
    for (NSInteger i = 0; i < classNameString.length; i++) {
       
        NSString *temp = [classNameString substringWithRange:NSMakeRange(i, 1)];
        //排除在@interface {}和@implementation {}里面添加方法
        if (bracesPrefixCount == 0) {
            if ([temp isEqualToString:@"-" ]|| [temp isEqualToString:@")"]) {
                isCanAdd = YES;
            }
            
            if ([temp isEqualToString:@"@"]) {
                isCanAdd = NO;
            }
            
            if ([temp isEqualToString:@"="]) {
                isCanAdd = NO;
            }
            [variableName appendString:temp];
            //这些方法开头的不能在{}中加入混淆代码
            if ([variableName containsString:@"@interface"]
                || [variableName containsString:@"@implementation"]
                || [variableName containsString:@"enum"]
                || [variableName containsString:@"struct"]
                || [variableName containsString:@"typedef"]
                || [variableName containsString:@"#define"]
                || [variableName containsString:@"const"]
                || [variableName containsString:@"{}"]
                ) {
                isCanAdd = NO;
            }
        }
        
        if ([temp isEqualToString:@"{"]) {
            bracesPrefixCount ++;
        } else if ([temp isEqualToString:@"}"]) {
            bracesPrefixCount --;
            if (bracesPrefixCount == 0) {
                if (isCanAdd) {
                    [newClassString insertString:addCodeToClassMethond_m atIndex:countNewMethond+i];
                    countNewMethond += addCodeToClassMethond_m.length;
                    isCanAdd = NO;
                }
                variableName = [[NSMutableString alloc] initWithCapacity:0];
            }
           
           
        }
    }
    
    return newClassString;
}


- (void)beginRunRuby {
    NSString *ruString =   [[NSBundle mainBundle] pathForResource:@"run" ofType:@"sh"];
    NSTask *copyFileTask = [[NSTask alloc] init];
    //调用路径
    [copyFileTask setLaunchPath:@"/bin/sh"];
    copyFileTask.arguments =  @[ruString];
    //[copyFileTask setArguments:[NSArray arrayWithObjects:@"cd",@"cd","ruby",ruString,nil]];
    [copyFileTask launch];
    
}

- (NSString *)currentDate {
    NSDate *date = [NSDate date];
    NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
    [forMatter setDateFormat:@"yyyy-MM-dd"];
   return [forMatter stringFromDate:date];
   
}

- (NSString *)currentYear {
    NSDate *date = [NSDate date];
    
    NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
    
    [forMatter setDateFormat:@"yyyy"];
    return [forMatter stringFromDate:date];
    
}

//生成指定范围内的随机数
- (NSInteger )getRandomNumber:(NSInteger)fromNumber to:(NSInteger)toNumber {
    
    return (NSInteger)(fromNumber + (arc4random() % (toNumber - fromNumber + 1)));
}

//生成指定长度随机字符串
- (NSString *)randomStringWithLength:(NSInteger)len {
    NSString *letters = @"abcdefgCDEFGHIhijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZmnopqrGHIJKLMNstuvwxyzstuvwxyzABCDEFGHIJKLMNOP";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (NSInteger i = 0; i < len; i++) {
        [randomString appendFormat: @"%c", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    return randomString;
}

//得到每个类随机方法数
- (NSArray *)getRandomMethodArray {
    NSUInteger methodCout = [self getRandomNumber:self.methodMinCount to:self.methodMaxCount];
    NSArray * methodtypeArry = @[@"NSString",@"NSArray",@"NSDate",@"NSDictionary",@"NSURL",@"NSNumber",@"NSDate"];
    
    NSMutableArray *methodArray = [[NSMutableArray alloc]initWithCapacity:0];
    for (NSInteger i = 0; i<methodCout; i++) {
        NSMutableString *randomName = [[NSMutableString alloc] initWithCapacity:0];
        
        [randomName appendString: [self randomStringWithLength:arc4random()%3+1]];
        [randomName appendString: [self randomStringWithLength:arc4random()%6+1]];
        [randomName appendString: [self randomStringWithLength:arc4random()%(i%8+1)+1]];
        NSDictionary *dict = @{
                               @"key":methodtypeArry[arc4random_uniform(methodtypeArry.count)],
                               @"value":[@"pl_" stringByAppendingString:randomName]
                               };
        
        [methodArray addObject:dict];
    }
    
    return methodArray;
}

//得到随机的类名
- (NSString *)getRandomClassName {
    NSMutableString *className = [[NSMutableString alloc] initWithString:self.classNamePrefix];
    [className appendString:[self randomStringWithLength:2]];
    [className appendString:[self randomStringWithLength:arc4random()%10+1]];
    [className appendString:[self randomStringWithLength:2]];
     [className appendString:[self randomStringWithLength:arc4random()%3+1]];
    return className;
}


@end


