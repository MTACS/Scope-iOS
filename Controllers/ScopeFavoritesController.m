#import "ScopeFavoritesController.h"
#import <rootless.h>

#define SDK_PATH @"/var/mobile/Library/Preferences/Scope/"

@interface ScopeFavoritesController ()
@property (nonatomic, strong) UITableView *table;
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

    self.table = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleInsetGrouped];
    self.table.delegate = self;
    self.table.dataSource = self;
	self.table.separatorColor = [UIColor clearColor];
    [self.view addSubview:self.table];
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
@end