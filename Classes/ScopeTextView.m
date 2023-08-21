#import "ScopeTextView.h"

#define INSETS 8.0 
#define GAP   4.0

@interface ScopeTextView() <UITextViewDelegate>
@end

@implementation ScopeTextView {
    UITextView *_textView;
}
- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTextView:textContainer];
    }
    return self;
}
- (void)setupTextView:(NSTextContainer *)textContainer {
    [self setContentMode:UIViewContentModeRedraw];

    self.textContainerScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.textContainerScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textContainerScrollView.bounces = NO;
    self.textContainerScrollView.backgroundColor = [UIColor systemBackgroundColor];

    _textView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:textContainer];
    _textView.translatesAutoresizingMaskIntoConstraints = NO;
    _textView.delegate = self;
    _textView.editable = NO;
    _textView.scrollEnabled = NO;
    
    [self addSubview:self.textContainerScrollView];
    [self.textContainerScrollView addSubview:_textView];

    [NSLayoutConstraint activateConstraints:@[
        [self.textContainerScrollView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.textContainerScrollView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.textContainerScrollView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:[self numberWidth]],
        [self.textContainerScrollView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_textView.topAnchor constraintEqualToAnchor:self.textContainerScrollView.topAnchor],
        [_textView.leadingAnchor constraintEqualToAnchor:self.textContainerScrollView.leadingAnchor],
        [_textView.trailingAnchor constraintEqualToAnchor:self.textContainerScrollView.trailingAnchor],
        [_textView.bottomAnchor constraintEqualToAnchor:self.textContainerScrollView.bottomAnchor],
    ]];
}
- (CGFloat)numberWidth {
    if (_textView.font) {
        float width = [@"8" sizeWithAttributes:@{NSFontAttributeName:_textView.font}].width;
        return 4 * width + GAP * 2;
    }
    return 30;
}
- (UITextView *)textView {
    return _textView;
}
- (void)setText:(NSString *)text {
    _textView.text = text;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    // _textView.frame = CGRectMake([self numberWidth], 0, CGRectGetWidth(self.frame) - [self numberWidth], CGRectGetHeight(self.frame));
}
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    
    CGContextSetFillColorWithColor(ctx, [UIColor systemBackgroundColor].CGColor);
    CGRect numberBackground = CGRectMake(0, 0, [self numberWidth], self.textContainerScrollView.frame.size.height);
    CGContextFillRect(ctx, numberBackground);
    
    [[_textView textColor] set];
    CGFloat xOrigin, yOrigin, width;
    CGFloat height = _textView.font.lineHeight * 1.1;
    int lines = 0;
    if (height > 0) lines = (_textView.contentSize.height - 2 * INSETS) / height;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentRight;
    
    for (int x = 0; x < lines; ++x) {
        NSString *lineNumber = [NSString stringWithFormat:@"%d", x + 1];
        xOrigin = _textView.contentOffset.x;
        
        yOrigin = (height * x) + INSETS - _textView.contentOffset.y;
        if (yOrigin < -height || yOrigin > self.textContainerScrollView.frame.size.height + height) {
            continue;
        }
        
        width = [lineNumber sizeWithAttributes:@{NSFontAttributeName:_textView.font}].width;
        [lineNumber drawInRect:CGRectMake(xOrigin, yOrigin, [self numberWidth] - GAP, height) withAttributes:@{NSFontAttributeName:_textView.font, NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName:[UIColor secondaryLabelColor]}];
    }
    UIGraphicsPopContext();
}
- (void)textViewDidChange:(UITextView *)textView {
    [self setNeedsDisplay];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self setNeedsDisplay];
}
@end