#import "AppDelegate.h"
#import "./Controllers/ScopeHomeController.h"
#import "./Controllers/ScopeSettingsController.h"
#import "./Controllers/ScopeSearchController.h"
#import "./Controllers/ScopeFavoritesController.h"

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    self.tabBarController = [[UITabBarController alloc] init];

    ScopeHomeController *homeController = [[ScopeHomeController alloc] init];
    homeController.title = @"Home";
    homeController.tabBarItem.image = [UIImage systemImageNamed:@"house.fill"];
    
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:homeController];

    ScopeSearchController *searchController = [[ScopeSearchController alloc] init];
    searchController.title = @"Search";
    searchController.tabBarItem.image = [UIImage systemImageNamed:@"magnifyingglass.circle.fill"];

    UINavigationController *searchNavigationController = [[UINavigationController alloc] initWithRootViewController:searchController];

    ScopeSettingsController *settingsController = [[ScopeSettingsController alloc] init];
    settingsController.title = @"Settings";
    settingsController.tabBarItem.image = [UIImage systemImageNamed:@"gearshape.fill"];

    UINavigationController *settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsController];

    ScopeFavoritesController *favoritesController = [[ScopeFavoritesController alloc] init];
    favoritesController.title = @"Favorites";
    favoritesController.tabBarItem.image = [UIImage systemImageNamed:@"star.fill"];

    UINavigationController *favoritesNavigationController = [[UINavigationController alloc] initWithRootViewController:favoritesController];

    self.tabBarController.viewControllers = @[homeNavigationController, searchNavigationController, favoritesNavigationController, settingsNavigationController];
	self.tabBarController.tabBar.translucent = NO;
    _window.rootViewController = self.tabBarController;
	[_window makeKeyAndVisible];
}
@end
