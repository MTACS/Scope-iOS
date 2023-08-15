#import <UIKit/UIKit.h>
#import "ScopeFileViewController.h"
#import "../AppDelegate.h"

@interface ScopePathController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate>
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSArray *headers;
@property (nonatomic, strong) NSMutableArray *pathDictionaryKeys;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) NSMutableArray *allFrameworks;
@property (nonatomic, strong) NSMutableDictionary *pathDictionary;
@property (nonatomic, assign) BOOL framework;
@property (nonatomic, assign) BOOL searching;
@property (nonatomic, strong) UISearchController *searchController;
- (id)initWithPath:(NSString *)path title:(NSString *)title;
+ (instancetype)pathControllerWithPath:(NSString *)path title:(NSString *)title;
@end

@interface UIColor (Scope) 
+ (id)tableCellGroupedBackgroundColor;
@end