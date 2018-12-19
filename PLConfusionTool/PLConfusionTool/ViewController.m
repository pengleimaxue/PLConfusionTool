////
//  ViewController.m
//  PLConfusionTool
//
//  Created by ___Fitfun___ on 2018/12/13.
//Copyright © 2018年 penglei. All rights reserved.
//

#import "ViewController.h"
#import "PLCreatNewFileManager.h"

@interface ViewController ()
//选择目标文件路径
@property (nonatomic, strong) NSOpenPanel *selectFilePathPanel;
@property (weak) IBOutlet NSTextField *selectFilePath;
@property (weak) IBOutlet NSTextField *creatNewPathTF;
@property (nonatomic, strong) PLCreatNewFileManager * creatNewFileManager;
@property (nonatomic, strong) NSAlert *warningAlert;

@property (weak) IBOutlet NSTextField *minClassesTextField;
@property (weak) IBOutlet NSTextField *maxClassesTextField;
@property (weak) IBOutlet NSTextField *minMethodTextField;
@property (weak) IBOutlet NSTextField *maxMethodTextField;
@property (weak) IBOutlet NSTextField *classPreNameTextField;

@property (weak) IBOutlet NSTextField *selectClassFilePath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    // Do any additional setup after loading the view.
}

- (void)viewDidLayout {
    [super viewDidLayout];
    self.view.window.title  = @"亿动iOS混淆工具";
}



//点击选择文件目录
- (IBAction)selectOriginalFile:(id)sender {
    
    [self.selectFilePathPanel beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
             NSString * path = [_selectFilePathPanel URL].absoluteString;
            self.selectFilePath.stringValue = [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
        }
    }];
  
}
- (IBAction)selectConfusionFile:(id)sender {
    [self.selectFilePathPanel beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            NSString * path = [_selectFilePathPanel URL].absoluteString;
            self.selectClassFilePath.stringValue = [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
        }
    }];
}

- (IBAction)createNewFile:(id)sender {
    [self.view.window makeKeyAndOrderFront:nil];
    self.creatNewFileManager.classNamePrefix = @"PLConfusionTest";
    self.creatNewFileManager.methodMinCount = 2;
    self.creatNewFileManager.methodMaxCount = 8;
    self.creatNewFileManager.classMinCount = 10;
    self.creatNewFileManager.classMaxCount = 15;
    
    if ([self isPureInt:self.minMethodTextField.stringValue]) {
        self.creatNewFileManager.methodMinCount = self.minMethodTextField.stringValue.integerValue;
    }
    
    if ([self isPureInt:self.maxMethodTextField.stringValue ]) {
        NSUInteger maxMethodCount = self.maxMethodTextField.stringValue.integerValue;
        if (maxMethodCount<self.creatNewFileManager.methodMinCount) {
            self.creatNewFileManager.methodMaxCount = self.creatNewFileManager.methodMinCount +1;
        } else {
            self.creatNewFileManager.methodMaxCount = maxMethodCount;
        }
    } else {
        self.creatNewFileManager.methodMaxCount = self.creatNewFileManager.methodMinCount +1;
    }
    
    if ([self isPureInt:self.minClassesTextField.stringValue]) {
        self.creatNewFileManager.classMinCount = self.minClassesTextField.stringValue.integerValue;
    }
    
    if ([self isPureInt:self.maxClassesTextField.stringValue ]) {
        NSUInteger maxClassesCount = self.maxClassesTextField.stringValue.integerValue;
        if (maxClassesCount<self.creatNewFileManager.classMinCount) {
            self.creatNewFileManager.classMaxCount = self.creatNewFileManager.classMinCount +1;
        } else {
            self.creatNewFileManager.classMaxCount = maxClassesCount;
        }
    } else {
        self.creatNewFileManager.classMaxCount = self.creatNewFileManager.classMinCount +1;
    }
    
    if (self.classPreNameTextField.stringValue.length) {
        self.creatNewFileManager.classNamePrefix = self.classPreNameTextField.stringValue;
    }
    
    if (self.selectFilePath.stringValue == nil || !self.selectFilePath.stringValue.length ) {
         [self.warningAlert setMessageText:@"请选择目标文件！"];
         [self.warningAlert beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSModalResponse returnCode) {
            if(returnCode == NSAlertFirstButtonReturn) {
                
            }
            
        }];
        return;
    }
    
    
    
    NSString * newPath = [self.creatNewPathTF.stringValue  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *rootDir = self.selectFilePath.stringValue;
    if ([rootDir hasPrefix:@"file://"]) {
        rootDir = [rootDir substringFromIndex:7];
    }
    

   BOOL isSuccess =   [self.creatNewFileManager creatNewFileRootDirectory:rootDir  path:newPath.length?newPath:@"confusionFile"];
    if (isSuccess == NO) {
        [self.warningAlert setInformativeText:@"创建文件失败"];
        [self.warningAlert beginSheetModalForWindow:[NSApp mainWindow] completionHandler:nil];
    } else {
        [self.warningAlert setInformativeText:@"创建文件成功，请到目标文件下手动copy到工程中"];
        [self.warningAlert beginSheetModalForWindow:[NSApp mainWindow] completionHandler:nil];
        NSString *selectClassFilePath = self.selectClassFilePath.stringValue;
        if ([selectClassFilePath hasPrefix:@"file://"]) {
            selectClassFilePath = [selectClassFilePath substringFromIndex:7];
        }
        if (selectClassFilePath.length) {
            [self.creatNewFileManager addConfusionMethondForExistClassM:selectClassFilePath];
        }
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


#pragma -private method

//判断是否是正整数
- (BOOL)isPureInt:(NSString*)string{
    
    NSScanner* scan = [NSScanner scannerWithString:string];
    
    int val;
    
    return  string.length &&[scan scanInt:&val] && [scan isAtEnd] && ![string containsString:@"-"];
    
}
#pragma mark - getter && setter

- (NSOpenPanel *)selectFilePathPanel {
    if (!_selectFilePathPanel) {
        _selectFilePathPanel = [NSOpenPanel openPanel];
        //设置单选模式
        [_selectFilePathPanel setAllowsMultipleSelection:NO];
        //设置只能选择文件夹
        [_selectFilePathPanel setCanChooseFiles:NO];
        [_selectFilePathPanel setCanChooseDirectories:YES];
        [_selectFilePathPanel setMessage:@"亿动友情提示:请选择目标路径"];
    }
    
    return _selectFilePathPanel;
}

- (PLCreatNewFileManager *)creatNewFileManager {
    if (!_creatNewFileManager) {
        _creatNewFileManager = [[PLCreatNewFileManager alloc] init];
    }
    return _creatNewFileManager;
}

- (NSAlert *)warningAlert {
    if (!_warningAlert) {
        _warningAlert = [[NSAlert alloc] init];
        [_warningAlert setAlertStyle:NSAlertStyleWarning];
        [_warningAlert addButtonWithTitle:@"确定"];//添加按钮
    }
    return _warningAlert;
}

@end


