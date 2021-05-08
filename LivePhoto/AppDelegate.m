//
//  AppDelegate.m
//  LivePhoto
//
//  Created by tang bo on 2021/5/8.
//

#import "AppDelegate.h"
#import "LivePhotoViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    LivePhotoViewController * loginVC = [[LivePhotoViewController alloc] init];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.window.rootViewController = nav;

    return YES;
}




@end
