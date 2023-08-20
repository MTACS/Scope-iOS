#import <UIKit/UIKit.h>
#import "../AppDelegate.h"
#import "ScopeFileViewController.h"
#import "ScopePathController.h"

@interface UINavigationItem (Scope)
@property (assign ,nonatomic) UINavigationBar *navigationBar;       
@end

@interface ScopeSearchController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate>
@property (nonatomic, strong) NSMutableArray *headerResults;
@property (nonatomic, strong) NSMutableArray *frameworkResults;
@property (nonatomic, strong) NSMutableArray *protocolResults;
@property (nonatomic, assign) BOOL searching;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, retain) UISegmentedControl *searchSegment;
@property (nonatomic, retain) UIBarButtonItem *doneButton;
@end

@interface UIColor (Scope) 
+ (id)tableCellGroupedBackgroundColor;
@end