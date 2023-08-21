#import "ScopeSearchController.h"
#import <rootless.h>

#define SDK_PATH @"/var/mobile/Library/Preferences/Scope/"

@interface ScopeSearchController ()
@property (nonatomic, strong) UITableView *table;
@end

@implementation ScopeSearchController
- (id)init {
	self = [super init];
	if (self) {

		self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.navigationController];
		self.searchController.delegate = self;
		self.searchController.searchBar.showsCancelButton = NO;
		self.searchController.searchBar.delegate = self;
		self.searchController.hidesNavigationBarDuringPresentation = NO;
		
		self.navigationItem.searchController = self.searchController;
		self.navigationItem.hidesSearchBarWhenScrolling = NO;
	}
	return self;
}
- (void)loadView {
    [super loadView];

	// [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"com.mtac.scope"];

    self.title = @"Search";
   
	self.headerResults = [NSMutableArray new];
    self.frameworkResults = [NSMutableArray new];
	self.protocolResults = [NSMutableArray new];

	self.table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
	self.table.translatesAutoresizingMaskIntoConstraints = NO;
	self.table.delegate = self;
	self.table.dataSource = self;
	[self.view addSubview:self.table];

	UIView *segmentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];

	self.searchSegment = [[UISegmentedControl alloc] initWithItems:@[@"Headers", @"Frameworks", @"Protocols"]];
	self.searchSegment.translatesAutoresizingMaskIntoConstraints = NO;
	self.searchSegment.selectedSegmentIndex = 0;
	self.searchSegment.hidden = YES;
	[self.searchSegment addTarget:self action:@selector(reloadTable) forControlEvents:UIControlEventValueChanged];
	[segmentView addSubview:self.searchSegment];

	self.table.tableHeaderView = segmentView;

	[NSLayoutConstraint activateConstraints:@[
		[self.table.topAnchor constraintEqualToAnchor:self.view.topAnchor],
		[self.table.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
		[self.table.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
		[self.table.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
		[self.searchSegment.topAnchor constraintEqualToAnchor:segmentView.topAnchor constant:5],
		[self.searchSegment.leadingAnchor constraintEqualToAnchor:segmentView.leadingAnchor constant:16],
		[self.searchSegment.trailingAnchor constraintEqualToAnchor:segmentView.trailingAnchor constant:-16],
		[self.searchSegment.bottomAnchor constraintEqualToAnchor:segmentView.bottomAnchor constant:-10],
	]];

	UIButton *done = [[UIButton alloc] init];
	done.frame = CGRectMake(0, 0, 60, 30);
	[done addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
	[done setTitle:@"Done" forState:UIControlStateNormal];
	[done setTitleColor:self.viewIfLoaded.tintColor forState:UIControlStateNormal];

	self.doneButton = [[UIBarButtonItem alloc] initWithCustomView:done];
	[self.doneButton setTintColor:self.viewIfLoaded.tintColor];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	self.navigationController.navigationBar.prefersLargeTitles = YES;

	[self.navigationController.navigationItem.navigationBar sizeToFit];
	_table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}
- (void)reloadTable {
	if (self.headerResults.count != 0 || self.frameworkResults.count != 0 || self.protocolResults.count != 0) {
		self.searchSegment.hidden = NO;
		self.navigationItem.rightBarButtonItems = @[self.doneButton];
	} else {
		self.searchSegment.hidden = YES;
		self.navigationItem.rightBarButtonItems = nil;
	}
	[self.table reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
	switch (self.searchSegment.selectedSegmentIndex) {
		default:
		case 0:
            rows = self.headerResults.count ?: 0;
			break;
		case 1:
            rows = self.frameworkResults.count?: 0;
			break;
		case 2:
            rows = self.protocolResults.count?: 0;
			break;
	}
	return rows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

    NSString *cellTitle;
	NSString *cellSubtitle;
    UIImage *cellIcon;

	switch (self.searchSegment.selectedSegmentIndex) {
		default:
		case 0:
			cellTitle = [self.headerResults objectAtIndex:indexPath.row];
			cellIcon = [UIImage systemImageNamed:@"doc.plaintext.fill"];
			break;
		case 1:
            cellTitle = [self.frameworkResults objectAtIndex:indexPath.row];
			cellIcon = [UIImage systemImageNamed:@"shippingbox.fill"];
			break;
		case 2:
            cellTitle = [self.protocolResults objectAtIndex:indexPath.row];
			cellIcon = [UIImage systemImageNamed:@"doc.badge.gearshape.fill"];
			break;
	}

	for (NSString *component in cellTitle.pathComponents) {
		if ([component containsString:@".framework"]) {
			cellSubtitle = component;
		}
	}
	
    UIListContentConfiguration *content = [cell defaultContentConfiguration];
    [content setImage:cellIcon];
    [content setText:[cellTitle lastPathComponent]];
    [content setSecondaryText:cellSubtitle];
    [content.secondaryTextProperties setColor:[UIColor secondaryLabelColor]];
    [content.secondaryTextProperties setFont:[UIFont systemFontOfSize:12]];
    [cell setContentConfiguration:content];

	return cell;
}
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
	UISwipeActionsConfiguration *swipeActions;
	NSString *path;
	NSString *sdk = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedSDK"];
	if (indexPath.section == 0) {
		path = [NSString stringWithFormat:@"%@%@/%@", ROOT_PATH_NS(SDK_PATH), sdk, [self.headerResults objectAtIndex:indexPath.row]];
	} else if (indexPath.section == 2) {
		path = [NSString stringWithFormat:@"%@%@/%@", ROOT_PATH_NS(SDK_PATH), sdk, [self.protocolResults objectAtIndex:indexPath.row]];
	} else if (indexPath.section == 1) {
		return nil;
	}

	UIContextualAction *setAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
		NSMutableArray *favorites = [[[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteHeaders"] mutableCopy] ?: [NSMutableArray new];
		if (![favorites containsObject:path]) {
			[favorites insertObject:path atIndex:0];
			[[NSUserDefaults standardUserDefaults] setObject:favorites forKey:@"favoriteHeaders"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ScopeReloadFavorites" object:nil];
		}
		completionHandler(YES);
	}];

	setAction.backgroundColor = [UIColor tableCellGroupedBackgroundColor];
	setAction.image = [UIImage systemImageNamed:@"star.fill"];
	setAction.title = @"Add to favorites";

	swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[setAction]];
	swipeActions.performsFirstActionWithFullSwipe = YES;
	return swipeActions;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSString *path;
	NSString *sdk = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedSDK"];
	if (self.searchSegment.selectedSegmentIndex == 0) {
		path = [NSString stringWithFormat:@"%@%@/%@", ROOT_PATH_NS(SDK_PATH), sdk, [self.headerResults objectAtIndex:indexPath.row]];
		ScopeFileViewController *fileViewController = [[ScopeFileViewController alloc] initWithPath:path title:[path lastPathComponent]];
        [self.navigationController pushViewController:fileViewController animated:YES];
	} else if (self.searchSegment.selectedSegmentIndex == 1) {
		path = [NSString stringWithFormat:@"%@%@/%@", ROOT_PATH_NS(SDK_PATH), sdk, [self.frameworkResults objectAtIndex:indexPath.row]];
		[self.navigationController pushViewController:[ScopePathController pathControllerWithPath:path title:[[path lastPathComponent] stringByDeletingPathExtension]] animated:YES];
	} else if (self.searchSegment.selectedSegmentIndex == 2) {
		path = [NSString stringWithFormat:@"%@%@/%@", ROOT_PATH_NS(SDK_PATH), sdk, [self.protocolResults objectAtIndex:indexPath.row]];
		ScopeFileViewController *fileViewController = [[ScopeFileViewController alloc] initWithPath:path title:[path lastPathComponent]];
        [self.navigationController pushViewController:fileViewController animated:YES];
	}
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
   	NSInteger count = 0;
	NSString *title = @"";
	switch (self.searchSegment.selectedSegmentIndex) {
		case 0:
			count = [self.headerResults count];
			break;
		case 1:
            count = [self.frameworkResults count];
			break;
		case 2:
            count = [self.protocolResults count];
			break;
	}
	if ([self tableView:_table numberOfRowsInSection:0] == 0) {
		return title;
	} else {
		title = [NSString stringWithFormat:@"%ld Results", count];
	}
	return title;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
	titleLabel.textColor = [UIColor secondaryLabelColor];
	titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
	titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
	return titleLabel;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if ([self tableView:tableView titleForHeaderInSection:section] != nil) {
		return 40;
	}
	return 10;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	self.searching = YES;
	[self search:searchBar.text];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self cancelSearch];
}
- (void)search:(NSString *)query {
	[self.headerResults removeAllObjects];
    [self.frameworkResults removeAllObjects];
	[self.protocolResults removeAllObjects];
    NSMutableArray *headers = [NSMutableArray new];
	NSMutableArray *frameworks = [NSMutableArray new];
	NSMutableArray *protocols = [NSMutableArray new];

	if (![query isEqualToString:@""]) {
		NSString *basePath = [NSString stringWithFormat:@"%@/%@", ROOT_PATH_NS(SDK_PATH), [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedSDK"]];
		NSString *file;
		NSFileManager *manager = [[NSFileManager alloc] init];
		NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:basePath];

		while ((file = [enumerator nextObject])) {
			if ([[file pathExtension] isEqualToString:@"h"]) {
				if ([file.lowercaseString containsString:query.lowercaseString]) {
					if ([file.lowercaseString containsString:@"protocol"]) {
						[protocols addObject:file];
					} else {
						[headers addObject:file];
					}
				}
			} else if ([[file pathExtension] isEqualToString:@"framework"]) {
				if ([file.lowercaseString containsString:query.lowercaseString]) {
					[frameworks addObject:file];
				}
			}
		}
		
		self.headerResults = [[headers sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
		self.frameworkResults = [[frameworks sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
		self.protocolResults = [[protocols sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
		[self reloadTable];
	}
}
- (void)cancelSearch {
	self.searching = NO;
	[self.headerResults removeAllObjects];
    [self.frameworkResults removeAllObjects];
	[self.protocolResults removeAllObjects];
	[self reloadTable];
}
@end