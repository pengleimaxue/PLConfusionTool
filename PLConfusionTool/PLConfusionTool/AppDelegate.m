////
//  AppDelegate.m
//  PLConfusionTool
//
//  Created by ___Fitfun___ on 2018/12/13.
//Copyright © 2018年 penglei. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)windowShouldClose:(id)sender //close box quits the app
{
    [NSApp terminate:self];
    return YES;
}

- (void)performClose:(nullable id)sender {
    
}

//关闭按钮之后退出应用
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end



