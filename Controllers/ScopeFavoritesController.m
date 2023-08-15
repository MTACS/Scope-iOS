#import "ScopeFavoritesController.h"

@interface ScopeFavoritesController ()
@property (nonatomic, strong) UITableView *table;
@end

@implementation ScopeFavoritesController
- (void)loadView {
    [super loadView];

    self.title = @"Favorites";
    self.navigationController.navigationBar.prefersLargeTitles = YES;

    self.table = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleInsetGrouped];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *favorites = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteHeaders"];
	return (favorites != nil) ? favorites.count : 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	NSArray *favorites = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteHeaders"];
	NSString *item = [favorites objectAtIndex:indexPath.row];
	NSArray *components = [item pathComponents];

	UIListContentConfiguration *content = [cell defaultContentConfiguration];
    [content setImage:[UIImage systemImageNamed:@"doc.plaintext.fill"]];
    [content setText:[item lastPathComponent]];
    [content setSecondaryText:[NSString stringWithFormat:@"SDK: %@", [components objectAtIndex:(components.count - 5)]]];
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
@end