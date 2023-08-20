#import <UIKit/UIKit.h>

#define SDK_PATH @"/var/mobile/Library/Preferences/Scope/"

@interface ScopeHomeController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UILabel *warningLabel;
@property (nonatomic, retain) UIButton *selectorButton;
- (void)pushPathControllerWithPath:(NSString *)path;
@end
