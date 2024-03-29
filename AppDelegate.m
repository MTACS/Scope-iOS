#import "AppDelegate.h"
#import <rootless.h>
#import "./Controllers/ScopeHomeController.h"
#import "./Controllers/ScopeSettingsController.h"
#import "./Controllers/ScopeSearchController.h"
#import "./Controllers/ScopeFavoritesController.h"

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {
    [self createDirectories];
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    self.tabBarController = [[UITabBarController alloc] init];

    ScopeHomeController *homeController = [[ScopeHomeController alloc] init];
    homeController.title = @"Home";
    homeController.tabBarItem.image = [UIImage systemImageNamed:@"house.fill"];
    homeController.tabBarItem.title = @"";
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:homeController];

    ScopeSearchController *searchController = [[ScopeSearchController alloc] init];
    searchController.title = @"Search";
    searchController.tabBarItem.image = [UIImage systemImageNamed:@"magnifyingglass.circle.fill"];
    searchController.tabBarItem.title = @"";
    UINavigationController *searchNavigationController = [[UINavigationController alloc] initWithRootViewController:searchController];

    ScopeFavoritesController *favoritesController = [[ScopeFavoritesController alloc] init];
    favoritesController.title = @"Favorites";
    favoritesController.tabBarItem.image = [UIImage systemImageNamed:@"star.fill"];
    favoritesController.tabBarItem.title = @"";
    UINavigationController *favoritesNavigationController = [[UINavigationController alloc] initWithRootViewController:favoritesController];

    ScopeSettingsController *settingsController = [[ScopeSettingsController alloc] init];
    settingsController.title = @"Settings";
    settingsController.tabBarItem.image = [UIImage systemImageNamed:@"gearshape.fill"];
    settingsController.tabBarItem.title = @"";
    UINavigationController *settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsController];
    
    self.tabBarController.viewControllers = @[homeNavigationController, searchNavigationController, favoritesNavigationController, settingsNavigationController];
	self.tabBarController.tabBar.translucent = NO;

    _window.rootViewController = self.tabBarController;
	[_window makeKeyAndVisible];
}
- (void)createDirectories {
    BOOL isDir;
    NSString *directory = ROOT_PATH_NS(@"/var/mobile/Library/Preferences/Scope");
	NSFileManager *fileManager = [NSFileManager defaultManager]; 
	if (![fileManager fileExistsAtPath:directory isDirectory:&isDir]) {
		[fileManager createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:nil];	
	}
}
@end
