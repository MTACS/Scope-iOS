#import <UIKit/UIKit.h>

#define SDK_PATH @"/Library/Application Support/Scope/sdks/"

@interface ScopeHomeController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UIButton *selectorButton;
- (void)pushPathControllerWithPath:(NSString *)path;
@end
