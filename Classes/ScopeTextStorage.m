#import "ScopeTextStorage.h"

@implementation ScopeTextStorage {
  NSMutableAttributedString *_cache;
}
- (id)init {
    self = [super init];
    if (self) {
        _cache = [NSMutableAttributedString new];
    }
    return self;
}
- (void)setContent:(ScopeCodeString *)content {
    _content = content;
    [self beginEditing];

    NSInteger oldLength = _cache.length;
    [_cache replaceCharactersInRange:NSMakeRange(0, oldLength) withString:_content];
    [self edited:NSTextStorageEditedCharacters range:NSMakeRange(0, oldLength) changeInLength:(NSInteger)_content.length - oldLength];
    [self updateAttributesForChangedRange: NSMakeRange(0, _content.length)];
    [self endEditing];
}
- (void)setFont:(UIFont *)font {
    _font = font;
    [self beginEditing];
    [self updateAttributesForChangedRange: NSMakeRange(0, self.content.length)];
    [self endEditing];
}
- (NSString *)string {
    return _cache.string;
}
- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
    return [_cache attributesAtIndex:location effectiveRange:range];
}
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    [self.content replaceCharactersInRange:range withString:str];
    [_cache replaceCharactersInRange:range withString:str];

    [self edited:NSTextStorageEditedCharacters range:range changeInLength:(NSInteger)str.length - (NSInteger)range.length];
}
- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range {
    [_cache setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}
- (void)processEditing {
    [self updateAttributesForChangedRange: self.editedRange];
    [super processEditing];
}
- (UIColor *)textColorForCodeType:(ScopeCodeType)type {
    switch (type) {
        default:
        case ScopeCodeTypeText:
            return [UIColor labelColor];

        case ScopeCodeTypeKeyword:
            return [UIColor systemRedColor];

        case ScopeCodeTypeClass:
            return [UIColor systemPinkColor];

        case ScopeCodeTypePragma:
            return [UIColor systemBlueColor];

        case ScopeCodeTypeNumber:
            return [UIColor systemTealColor];

        case ScopeCodeTypeURL:
            return [UIColor systemPurpleColor];

        case ScopeCodeTypeAttribute:
            return [UIColor systemBlueColor];

        case ScopeCodeTypeString:
            return [UIColor systemTealColor];

        case ScopeCodeTypeComment:
            return [UIColor systemGrayColor];
            
        case ScopeCodeTypeCharacter:
            return [UIColor systemYellowColor];
        
        case ScopeCodeTypeFoundation:
            return [UIColor orangeColor];
            
        case ScopeCodeTypeLogos:
            return [UIColor systemTealColor];
            
        case ScopeCodeTypeImport:
            return [UIColor systemGreenColor];
    }
}
- (void)updateAttributesForChangedRange:(NSRange)range {
    range = [self.content paragraphRangeForRange:range];
    [self setAttributes:@{} range:range];

    if (self.font) {
        [self addAttribute:NSFontAttributeName value:self.font range:range];
    }

    [self.content enumerateCodeInRange:range usingBlock:^(NSRange range, ScopeCodeType type) {
        [self addAttribute:NSForegroundColorAttributeName value:[self textColorForCodeType: type] range:range];
    }];
}
@end