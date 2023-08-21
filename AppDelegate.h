#import <UIKit/UIKit.h>

@interface UITabBarButton : UIControl
@end

@interface UITabBarItem (Scope)
- (id)view;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *rootViewController;
@end
