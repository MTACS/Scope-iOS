#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ScopeCodeTypeKeyword,
    ScopeCodeTypeClass,
    ScopeCodeTypePragma,
    ScopeCodeTypeNumber,
    ScopeCodeTypeURL,
    ScopeCodeTypeAttribute,
    ScopeCodeTypeString,
    ScopeCodeTypeComment,
    ScopeCodeTypeText,
    ScopeCodeTypeFoundation,
    ScopeCodeTypeCharacter,
    ScopeCodeTypeLogos,
    ScopeCodeTypeImport
} ScopeCodeType;

@interface ScopeCodeString : NSMutableString
- (void)enumerateCodeInRange:(NSRange)range usingBlock:(void (^)(NSRange range, ScopeCodeType type))block;
@end