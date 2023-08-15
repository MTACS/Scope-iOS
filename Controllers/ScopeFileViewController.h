#import <UIKit/UIKit.h>
#import "../Classes/ScopeTextStorage.h"
#import "../Classes/ScopeLayoutManager.h"

@interface ScopeFileViewController : UIViewController
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, retain) ScopeCodeString *codeString;
@property (nonatomic, retain) ScopeTextStorage *textStorage;
@property (nonatomic, retain) UIScrollView *textContainerScrollView;
- (id)initWithPath:(NSString *)path title:(NSString *)title;
@end
