//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaAppDelegate.h"

#import "MafiaGameStoryboard.h"
#import "MafiaAboutStoryboard.h"


@interface MafiaAppDelegate ()

@property (strong, nonatomic) UITabBarController *tabBarController;  // The (typed) root controller.

@end


@implementation MafiaAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.tabBarController = (UITabBarController *)self.window.rootViewController;
    self.tabBarController.viewControllers = @[
        [MafiaGameStoryboard rootNavigationController],
        [MafiaAboutStoryboard rootNavigationController],
    ];
    self.tabBarController.selectedViewController = self.tabBarController.viewControllers[0];
    self.tabBarController.delegate = self;
    
    // Customize appearance globally.
    [self mafia_customizeApplicationAppearance];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - UITabBarControllerDelegate


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    // If user tapped a tab bar button whose associated view controller is the same as the
    // currently selected one, do nothing. When the selected view controller is a navigation
    // controller, this prevents it from popping to root view controller.
    return (tabBarController.selectedViewController != viewController);
}


#pragma mark - Private


- (void)mafia_customizeApplicationAppearance {
    [[UINavigationBar appearance] setTintColor:[UIColor darkGrayColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
        NSForegroundColorAttributeName: [UIColor darkGrayColor]
    }];
    // TODO: [[UITabBar appearance] setTintColor:...];
}




@end