#import <UIKit/UIKit.h>
#import "../AppDelegate.h"

@interface ScopeSearchController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate>
@property (nonatomic, strong) NSMutableArray *headerResults;
@property (nonatomic, strong) NSMutableArray *frameworkResults;
@property (nonatomic, strong) UIActivityIndicatorView *progressView;
@property (nonatomic, strong) UIBarButtonItem *progressItem;
@property (nonatomic, assign) BOOL searching;
@property (nonatomic, strong) UISearchController *searchController;
@end