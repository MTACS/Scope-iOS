#import <UIKit/UIKit.h>
#import "../AppDelegate.h"
#import "../ZipArchive/SSZipArchive/SSZipArchive.h"

@interface ScopeSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSURLSessionDownloadDelegate, SSZipArchiveDelegate>
@property (nonatomic, strong) NSArray *downloadURLS;
@property (nonatomic, strong) NSArray *saveURLS;
@property (nonatomic, strong) NSString *downloadPath;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UIProgressView *progressView;
- (void)hideProgressView;
@end

@interface UIColor (Scope) 
+ (id)tableCellGroupedBackgroundColor;
@end

@interface CALayer (Scope)
@property (nonatomic, retain) NSString *compositingFilter;
@property (nonatomic, assign) BOOL allowsGroupOpacity;
@property (nonatomic, assign) BOOL allowsGroupBlending;
@property (copy) NSString *cornerCurve;
@property (assign) BOOL continuousCorners;
@end