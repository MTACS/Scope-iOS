#import "ScopeFileViewController.h"

NSUserDefaults *defaults;

@implementation ScopeFileViewController
- (id)initWithPath:(NSString *)path title:(NSString *)title {
    self = [super init];
    if (self) {
        self.path = path;
        self.title = title;

        defaults = [NSUserDefaults standardUserDefaults];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFont) name:@"ScopeReloadFont" object:nil];
    }
    return self;
}
- (void)loadView {
    [super loadView];
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    [self updateTitleButtons];
}
- (void)updateTitleButtons {
    BOOL isFavorite = [[defaults objectForKey:@"favoriteHeaders"] containsObject:self.path];

    UIButton *favorites = [[UIButton alloc] init];
    favorites.frame = CGRectMake(0, 0, 30, 30);
    [favorites addTarget:self action:@selector(toggleFavorite) forControlEvents:UIControlEventTouchUpInside];
    [favorites setBackgroundImage:(isFavorite ? [UIImage systemImageNamed:@"star.fill"] : [UIImage systemImageNamed:@"star"]) forState:UIControlStateNormal];
    [favorites setTitleColor:self.viewIfLoaded.tintColor forState:UIControlStateNormal];

    UIBarButtonItem *favoritesButton = [[UIBarButtonItem alloc] initWithCustomView:favorites];
    [favoritesButton setTintColor:self.viewIfLoaded.tintColor];
    self.navigationItem.rightBarButtonItems = @[favoritesButton];
}
- (void)toggleFavorite {
    NSMutableArray *favorites = [[defaults objectForKey:@"favoriteHeaders"] mutableCopy] ?: [NSMutableArray new];
    if ([favorites containsObject:self.path]) {
        [favorites removeObject:self.path];
    } else {
        [favorites insertObject:self.path atIndex:0];
    }
    [defaults setObject:favorites forKey:@"favoriteHeaders"];
    [defaults synchronize];
    [self updateTitleButtons];
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
    [self setFont];
    
    ScopeLayoutManager *layoutManager = [ScopeLayoutManager new];
    layoutManager.lineHeight = 1.1;
    [self.textStorage addLayoutManager:layoutManager];

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

    /* self.textView = [[ScopeTextView alloc] initWithFrame:self.view.frame textContainer:textContainer];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO; */
    [self.textContainerScrollView addSubview:self.textView];

    [NSLayoutConstraint activateConstraints:@[
        [self.textContainerScrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor ],
        [self.textContainerScrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.textContainerScrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.textContainerScrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.textView.topAnchor constraintEqualToAnchor:self.textContainerScrollView.topAnchor],
        [self.textView.leadingAnchor constraintEqualToAnchor:self.textContainerScrollView.leadingAnchor],
        [self.textView.trailingAnchor constraintEqualToAnchor:self.textContainerScrollView.trailingAnchor],
        [self.textView.bottomAnchor constraintEqualToAnchor:self.textContainerScrollView.bottomAnchor],
    ]];
}
- (void)setFont {
    NSInteger fontSize = [[[NSUserDefaults standardUserDefaults] objectForKey:@"fontSize"] integerValue] ?: 16;
    self.textStorage.font = [UIFont systemFontOfSize:fontSize];
}
@end