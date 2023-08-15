#import "ScopeFileViewController.h"

@implementation ScopeFileViewController
- (id)initWithPath:(NSString *)path title:(NSString *)title {
    self = [super init];
    if (self) {
        self.path = path;
        self.title = title;
    }
    return self;
}
- (void)loadView {
    [super loadView];
    self.navigationController.navigationBar.prefersLargeTitles = YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadTextView];
}
- (void)loadTextView {
    self.codeString = [ScopeCodeString new];
    self.codeString.string = [NSString stringWithContentsOfFile:self.path encoding:NSUTF8StringEncoding error:NULL];

    self.textStorage = [ScopeTextStorage new];
    self.textStorage.content = self.codeString;
    self.textStorage.font = [UIFont systemFontOfSize:16];

    ScopeLayoutManager *layoutManager = [ScopeLayoutManager new];
    layoutManager.lineHeight = 1.1;
    [self.textStorage addLayoutManager: layoutManager];

    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    textContainer.lineBreakMode = NSLineBreakByCharWrapping;
    [layoutManager addTextContainer:textContainer];

    self.textContainerScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.textContainerScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textContainerScrollView.bounces = NO;
    self.textContainerScrollView.backgroundColor = [UIColor systemBackgroundColor];
    [self.view addSubview:self.textContainerScrollView];

    self.textView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:textContainer];
    self.textView.editable = NO;
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.scrollEnabled = NO;
    [self.textContainerScrollView addSubview:self.textView];

    [NSLayoutConstraint activateConstraints:@[
        [self.textContainerScrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.textContainerScrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.textContainerScrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.textContainerScrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.textView.topAnchor constraintEqualToAnchor:self.textContainerScrollView.topAnchor],
        [self.textView.leadingAnchor constraintEqualToAnchor:self.textContainerScrollView.leadingAnchor],
        [self.textView.trailingAnchor constraintEqualToAnchor:self.textContainerScrollView.trailingAnchor],
        [self.textView.bottomAnchor constraintEqualToAnchor:self.textContainerScrollView.bottomAnchor],
    ]];
}
@end