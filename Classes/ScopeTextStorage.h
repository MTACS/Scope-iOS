#import <UIKit/UIKit.h>
#import "ScopeCodeString.h"

@interface ScopeTextStorage : NSTextStorage
@property (nonatomic, retain) ScopeCodeString *content;
@property (nonatomic, retain) UIFont *font;
@end