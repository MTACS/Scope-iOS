#import "AppDelegate.h"
#import "ScopeHomeController.h"
#import "ScopeSettingsController.h"

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    self.tabBarController = [[UITabBarController alloc] init];

    ScopeHomeController *homeController = [[ScopeHomeController alloc] init];
    homeController.title = @"Home";
    homeController.tabBarItem.image = [UIImage systemImageNamed:@"house.fill"];

    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:homeController];

    ScopeSettingsController *settingsController = [[ScopeSettingsController alloc] init];
    settingsController.title = @"Settings";
    settingsController.tabBarItem.image = [UIImage systemImageNamed:@"gearshape.fill"];

    UINavigationController *settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsController];

    self.tabBarController.viewControllers = @[homeNavigationController, settingsNavigationController];
	_window.rootViewController = self.tabBarController;
	[_window makeKeyAndVisible];
}
@end
