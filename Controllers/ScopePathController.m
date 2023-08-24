#import "ScopePathController.h"

#define SDK_PATH @"/var/mobile/Library/Preferences/Scope/"

@interface ScopePathController ()
@property (nonatomic, strong) UITableView *table;
@end

@implementation ScopePathController
- (id)initWithPath:(NSString *)path title:(NSString *)title {
    self = [super init];
    if (self) {
        self.fileManager = [NSFileManager defaultManager];
        self.title = title;
        self.path = path;
        self.searchResults = [NSMutableArray new];

        self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.navigationController];
		self.searchController.delegate = self;
		self.searchController.searchBar.delegate = self;
		self.searchController.hidesNavigationBarDuringPresentation = YES;
        self.searchController.obscuresBackgroundDuringPresentation = NO;
		
		self.navigationItem.searchController = self.searchController;

        if ([self.path.pathExtension isEqualToString:@"framework"] || [self.path.pathExtension isEqualToString:@"bundle"]) {
            self.framework = YES;
            [self loadHeaders];
        } else {
            self.framework = NO;
            self.pathDictionary = [NSMutableDictionary new];
            self.pathDictionaryKeys = [NSMutableArray new];
            [self loadFrameworks];
        }
    }
    return self;
}
- (void)loadHeaders {
    NSDirectoryEnumerator *enumerator = [self.fileManager enumeratorAtPath:self.path];
    NSMutableArray *headerArray = [NSMutableArray new];
    NSString *file;
    while ((file = [enumerator nextObject])) {
        if ([[file pathExtension] isEqualToString:@"h"]) {
            [headerArray addObject:file];
        }
    }
    self.headers = [headerArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}
- (void)loadFrameworks {
    NSMutableArray *pathItems = [[self.fileManager contentsOfDirectoryAtPath:self.path error:nil] mutableCopy];
    for (NSString *item in pathItems) {
        NSString *firstCharacter = [[item substringWithRange:NSMakeRange(0, 1)] uppercaseString];
        NSMutableArray *characterItems = [self.pathDictionary objectForKey:firstCharacter] ?: [NSMutableArray new];
        [characterItems addObject:item];
        [self.pathDictionary setObject:characterItems forKey:firstCharacter];
        self.allFrameworks = [[pathItems sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    }

    self.pathDictionaryKeys = [[self.pathDictionary.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    if ([self.pathDictionaryKeys containsObject:@"_"]) {
        NSInteger dashIndex = [self.pathDictionaryKeys indexOfObject:@"_"];
        [self.pathDictionaryKeys removeObjectAtIndex:dashIndex];
        [self.pathDictionaryKeys addObject:@"_"];
    }

    for (NSString *key in self.pathDictionaryKeys) {
        NSMutableArray *itemArray = [[self.pathDictionary objectForKey:key] copy];
        NSMutableArray *sortedItems = [[itemArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
        [self.pathDictionary setObject:sortedItems forKey:key];
    }
}
- (void)loadView {
    [super loadView];

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
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (self.framework || self.searching) ? 1 : [[self.pathDictionary allKeys] count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (self.searching) {
        rows = [self.searchResults count];
    } else {
        NSString *sectionName = self.pathDictionaryKeys[section];
        NSMutableArray *sectionItems = [self.pathDictionary objectForKey:sectionName];
        rows = (self.framework) ? self.headers.count : sectionItems.count;
    }
    return rows;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.framework ? 60 : 70;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *item;
    NSString *cellTitle;
    UIImage *cellIcon;

    static NSString *CellIdentifier = @"pathCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (self.searching) {
        item = [self.searchResults objectAtIndex:indexPath.row];
        cellTitle = self.framework ? [item lastPathComponent] : item;
        if ([item.pathExtension isEqualToString:@"h"]) {
            cellIcon = [UIImage systemImageNamed:@"doc.plaintext.fill"];
        } else if ([item.pathExtension isEqualToString:@"framework"]) {
            cellIcon = [UIImage systemImageNamed:@"shippingbox.fill"];
            cellTitle = [item stringByReplacingOccurrencesOfString:@".framework" withString:@""];
        } else cellIcon = [UIImage systemImageNamed:@"folder.fill"];
    } else {
        if (self.framework) {
            item = [self.headers objectAtIndex:indexPath.row];
        } else {
            NSString *sectionName = [self.pathDictionaryKeys objectAtIndex:indexPath.section];
            NSMutableArray *sectionItems = [self.pathDictionary objectForKey:sectionName];
            item = [sectionItems objectAtIndex:indexPath.row];
        }

        cellTitle = self.framework ? [item lastPathComponent] : item;
        if ([item.pathExtension isEqualToString:@"h"]) {
            cellIcon = [UIImage systemImageNamed:@"doc.plaintext.fill"];
        } else if ([item.pathExtension isEqualToString:@"framework"]) {
            cellIcon = [UIImage systemImageNamed:@"shippingbox.fill"];
            cellTitle = [item stringByReplacingOccurrencesOfString:@".framework" withString:@""];
        } else cellIcon = [UIImage systemImageNamed:@"folder.fill"];
    }
    UIListContentConfiguration *content = [cell defaultContentConfiguration];
    [content setImage:cellIcon];
    [content setText:cellTitle];
    [content setSecondaryText:self.framework ? nil : item];
    [content.secondaryTextProperties setColor:[UIColor secondaryLabelColor]];
    [content.secondaryTextProperties setFont:[UIFont systemFontOfSize:12]];
    [cell setContentConfiguration:content];

	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *path;
    if (self.searching) {
        if (self.framework) {
            path = [NSString stringWithFormat:@"%@/%@", self.path, self.searchResults[indexPath.row]];
            ScopeFileViewController *fileViewController = [[ScopeFileViewController alloc] initWithPath:path title:[path lastPathComponent]];
            [self.navigationController pushViewController:fileViewController animated:YES];
        } else {
            path = [NSString stringWithFormat:@"%@/%@", self.path, self.searchResults[indexPath.row]];
            [self.navigationController pushViewController:[ScopePathController pathControllerWithPath:path title:[self.searchResults[indexPath.row] stringByDeletingPathExtension]] animated:YES];
        }
    } else {
        if (self.framework) {
            path = [NSString stringWithFormat:@"%@/%@", self.path, self.headers[indexPath.row]];
            ScopeFileViewController *fileViewController = [[ScopeFileViewController alloc] initWithPath:path title:[path lastPathComponent]];
            [self.navigationController pushViewController:fileViewController animated:YES];
        } else {
            NSString *sectionName = [self.pathDictionaryKeys objectAtIndex:indexPath.section];
            NSMutableArray *sectionItems = [self.pathDictionary objectForKey:sectionName];
            path = [NSString stringWithFormat:@"%@/%@", self.path, [sectionItems objectAtIndex:indexPath.row]];
            [self.navigationController pushViewController:[ScopePathController pathControllerWithPath:path title:[[sectionItems objectAtIndex:indexPath.row] stringByDeletingPathExtension]] animated:YES];
        }
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!self.framework && !self.searching) {
        return [self.pathDictionaryKeys objectAtIndex:section];
    }
    return nil;
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (!self.framework && !self.searching) {
        return self.pathDictionaryKeys;
    }
    return nil;
}
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
	UISwipeActionsConfiguration *swipeActions;
	if (self.framework) {
        UIContextualAction *setAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
			NSString *path = [NSString stringWithFormat:@"%@/%@", self.path, self.headers[indexPath.row]];
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
    return nil;
}
+ (ScopePathController *)pathControllerWithPath:(NSString *)path title:(NSString *)title {
    return [[self.class alloc] initWithPath:path title:title];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[self search:searchBar.text];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self search:searchText];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	if ([searchBar.text isEqualToString:@""]) {
		[self cancelSearch];
	}
}
- (void)search:(NSString *)query {
	[self.searchResults removeAllObjects];
    NSMutableArray *results = [NSMutableArray new];
	if (self.framework) {
        for (NSString *item in self.headers) {
            if ([item.lowercaseString containsString:query.lowercaseString]) {
                [results addObject:item];
            }
        }
    } else {
        for (NSString *framework in self.allFrameworks) {
            if ([framework.lowercaseString containsString:query.lowercaseString]) {
                [results addObject:framework];
            }
        }
    }
    self.searchResults = [[results sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];

	self.searching = YES;
	[_table reloadData];
    [self updateTitleButtons];
}
- (void)cancelSearch {
	self.searching = NO;
	[_table reloadData];
	[self.searchResults removeAllObjects];
    [self updateTitleButtons];
}
- (void)updateTitleButtons {
	if (self.searching) {
		UIButton *done = [[UIButton alloc] init];
		done.frame = CGRectMake(0, 0, 60, 30);
		[done addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
		[done setTitle:@"Done" forState:UIControlStateNormal];
		[done setTitleColor:self.viewIfLoaded.tintColor forState:UIControlStateNormal];

		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:done];
		[doneButton setTintColor:self.viewIfLoaded.tintColor];
		self.navigationItem.rightBarButtonItems = @[doneButton];
	} else {
        self.navigationItem.rightBarButtonItems = nil;
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.hidesSearchBarWhenScrolling = YES;
	_table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController].tabBar.translucent = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController].tabBar.translucent = NO;
}
@end