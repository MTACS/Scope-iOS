#import <UIKit/UIKit.h>

@interface ScopeTextView : UIView
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIScrollView *textContainerScrollView;
- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer;
@end