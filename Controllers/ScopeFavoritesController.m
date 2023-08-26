#import "ScopeFavoritesController.h"
#import <rootless.h>

#define SDK_PATH @"/var/mobile/Library/Preferences/Scope/"

@interface OBButtonTray : UIView
@property (nonatomic, retain) UIVisualEffectView *effectView;
- (void)addButton:(id)arg1;
- (void)addCaptionText:(id)arg1;;
@end

@interface OBTrayButton : UIButton
+ (id)buttonWithType:(long long)arg1 ;
+ (double)standardHeight;
- (CGSize)intrinsicContentSize;
- (void)setTitle:(id)arg1 forState:(unsigned long long)arg2 ;
- (void)traitCollectionDidChange:(id)arg1 ;
- (void)layoutSubviews;
- (id)_fontTextStyle;
@end

@interface OBBoldTrayButton : UIButton
- (void)setTitle:(id)arg1 forState:(unsigned long long)arg2;
+ (id)buttonWithType:(long long)arg1;
@end

@interface OBWelcomeController : UIViewController
@property (nonatomic, retain) UIView *viewIfLoaded;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (assign, nonatomic) BOOL _shouldInlineButtontray;   
- (BOOL)_shouldInlineButtontray;
- (OBButtonTray *)buttonTray;
- (id)initWithTitle:(id)arg1 detailText:(id)arg2 icon:(id)arg3;
- (void)addBulletedListItemWithTitle:(id)arg1 description:(id)arg2 image:(id)arg3;
@end

@interface ScopeFavoritesController ()
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, retain) OBWelcomeController *infoController;
@end

@implementation ScopeFavoritesController
- (id)init {
	self = [super init];
    if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"ScopeReloadFavorites" object:nil];
	}
	return self;
}
- (void)loadView {
    [super loadView];

    self.title = @"Favorites";
    self.navigationController.navigationBar.prefersLargeTitles = YES;

    self.table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.table.translatesAutoresizingMaskIntoConstraints = NO;
	self.table.delegate = self;
    self.table.dataSource = self;
	self.table.separatorColor = [UIColor clearColor];
    [self.view addSubview:self.table];

	[NSLayoutConstraint activateConstraints:@[
		[self.table.topAnchor constraintEqualToAnchor:self.view.topAnchor],
		[self.table.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
		[self.table.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
		[self.table.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
	]];

	UIButton *info = [[UIButton alloc] init];
    info.frame = CGRectMake(0, 0, 30, 30);
    [info addTarget:self action:@selector(showInfoController) forControlEvents:UIControlEventTouchUpInside];
    [info setBackgroundImage:[UIImage systemImageNamed:@"info.circle.fill"] forState:UIControlStateNormal];
    [info setTitleColor:self.viewIfLoaded.tintColor forState:UIControlStateNormal];

    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithCustomView:info];
    [infoButton setTintColor:self.viewIfLoaded.tintColor];
    self.navigationItem.rightBarButtonItems = @[infoButton];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *favorites = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteHeaders"];
	return favorites.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	NSArray *favorites = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteHeaders"];
	NSString *item = [favorites objectAtIndex:indexPath.row];
	NSArray *components = [[item stringByReplacingOccurrencesOfString:ROOT_PATH_NS(SDK_PATH) withString:@""] componentsSeparatedByString:@"/"];

	UIListContentConfiguration *content = [cell defaultContentConfiguration];
    [content setImage:[UIImage systemImageNamed:@"doc.plaintext.fill"]];
    [content setText:[item lastPathComponent]];
    [content setSecondaryText:[NSString stringWithFormat:@"SDK: %@", [components firstObject]]];
    [content.secondaryTextProperties setColor:[UIColor secondaryLabelColor]];
    [content.secondaryTextProperties setFont:[UIFont systemFontOfSize:12]];
    [cell setContentConfiguration:content];

	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	NSArray *favorites = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteHeaders"];
	NSString *path = [favorites objectAtIndex:indexPath.row];
	ScopeFileViewController *fileViewController = [[ScopeFileViewController alloc] initWithPath:path title:[path lastPathComponent]];
    [self.navigationController pushViewController:fileViewController animated:YES];
}
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
	UISwipeActionsConfiguration *swipeActions;
	UIContextualAction *removeAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
		NSMutableArray *favorites = [[[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteHeaders"] mutableCopy];
		[favorites removeObjectAtIndex:indexPath.row];
		[[NSUserDefaults standardUserDefaults] setObject:favorites forKey:@"favoriteHeaders"];
		[_table reloadData];
		completionHandler(YES);
	}];

	removeAction.backgroundColor = [UIColor systemRedColor];
	removeAction.image = [UIImage systemImageNamed:@"xmark.circle.fill"];
	removeAction.title = @"Remove from favorites";

	swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[removeAction]];
	swipeActions.performsFirstActionWithFullSwipe = YES;
	return swipeActions;
}
- (void)reloadTable {
	[_table reloadData];
}
- (void)showInfoController {
	self.infoController = [[OBWelcomeController alloc] initWithTitle:@"Favorites" detailText:@"" icon:[UIImage imageWithContentsOfFile:ROOT_PATH_NS(@"/Applications/Scope.app/AppIcon-Rounded.png")]];
	[self.infoController addBulletedListItemWithTitle:nil description:@"• Swipe left on header cells to add to favorites, or tap the star icon when view a header file." image:[UIImage systemImageNamed:@"arrow.left.circle.fill"]];
	[self.infoController addBulletedListItemWithTitle:nil description:@"• To remove a favorite, swipe left on a header cell in the favorites page." image:[UIImage systemImageNamed:@"xmark.circle.fill"]];

	OBTrayButton *confirm = [OBTrayButton buttonWithType:0];
	[confirm addTarget:self action:@selector(dismissInfoController) forControlEvents:UIControlEventTouchUpInside];
	[confirm setTitle:@"Dismiss" forState:UIControlStateNormal];
	[confirm setClipsToBounds:YES];
	[confirm setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
	[confirm setBackgroundColor:[UIColor systemBlueColor]];
	[confirm.layer setCornerRadius:12];
	[self.infoController.buttonTray addButton:confirm];

	self.infoController.buttonTray.effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
    UIVisualEffectView *effectWelcomeView = [[UIVisualEffectView alloc] initWithFrame:self.infoController.viewIfLoaded.bounds];
    effectWelcomeView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
    
	[self.infoController.viewIfLoaded insertSubview:effectWelcomeView atIndex:0];
    self.infoController.viewIfLoaded.backgroundColor = [UIColor clearColor];
    self.infoController.modalPresentationStyle = UIModalPresentationPageSheet;
    self.infoController.modalInPresentation = NO;
	self.infoController._shouldInlineButtontray = NO;
    [self presentViewController:self.infoController animated:YES completion:nil];
}
- (void)dismissInfoController {
	[self.infoController dismissViewControllerAnimated:YES completion:nil];
}
@end