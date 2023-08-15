#import "ScopeCodeString.h"

@implementation ScopeCodeString {
    NSMutableString *_string;
}
- (id)init {
    self = [super init];
    if (self) {
        _string = [NSMutableString new];
    }
    return self;
}
- (NSUInteger)length {
    return _string.length;
}
- (unichar)characterAtIndex:(NSUInteger)index {
    return [_string characterAtIndex: index];
}
- (void)getCharacters:(unichar *)buffer range:(NSRange)aRange {
    [_string getCharacters:buffer range:aRange];
}
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
    [_string replaceCharactersInRange:range withString:aString];
}
- (void)enumerateCodeInRange:(NSRange)range usingBlock:(void (^)(NSRange range, ScopeCodeType type))block {
    block(range, ScopeCodeTypeText);
    
    NSDictionary *components = [NSDictionary dictionaryWithContentsOfFile:@"/Applications/Scope.app/objc.plist"][@"components"];
    
    for (NSString *key in components) {
        NSDictionary *dict = components[key];
        if (dict) {
            /* NSRegularExpressionOptions options = 0;
            if (dict[@"options"]) {
                options = [dict[@"options"] intValue];
            } */
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:dict[@"regex"] options:0 error:nil];
            NSArray *matches = [regex matchesInString:self options:0 range:range];
            for (NSTextCheckingResult *match in matches) {
                NSRange finalRange = match.range;
                if ([key isEqual:@"keywords"]) {
                    block(finalRange, ScopeCodeTypeKeyword);
                } else if ([key isEqual:@"classes"]) {
                    block(finalRange, ScopeCodeTypeClass);
                } else if ([key isEqual:@"logos"]) {
                    block(finalRange, ScopeCodeTypeLogos);
                } else if ([key isEqual:@"preprocessors"]) {
                    block(finalRange, ScopeCodeTypePragma);
                } else if ([key isEqual:@"imports"]) {
                    block(finalRange, ScopeCodeTypeImport);
                } else if ([key isEqual:@"numbers"]) {
                    block(finalRange, ScopeCodeTypeNumber);
                } else if ([key isEqual:@"urls"]) {
                    block(finalRange, ScopeCodeTypeURL);
                } else if ([key isEqual:@"attributes"]) {
                    block(finalRange, ScopeCodeTypeAttribute);
                } else if ([key isEqual:@"foundation"]) {
                    block(finalRange, ScopeCodeTypeFoundation);
                } else if ([key isEqual:@"strings"]) {
                    block(finalRange, ScopeCodeTypeString);
                } else if ([key isEqual:@"characters"]) {
                    block(finalRange, ScopeCodeTypeCharacter);
                } else if ([key isEqual:@"comments"] || [key isEqual:@"documentation_markup"] || [key isEqual:@"documentation_markup_keywords"]) {
                    block(finalRange, ScopeCodeTypeComment);
                }
            }
        }
    }
}
@end