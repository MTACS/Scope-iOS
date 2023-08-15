#import "ScopeSearchController.h"

#define SDK_PATH @"/Library/Application Support/Scope/sdks/"

@interface ScopeSearchController ()
@property (nonatomic, strong) UITableView *table;
@end

@implementation ScopeSearchController
- (void)loadView {
    [super loadView];

    self.title = @"Search";
    self.navigationController.navigationBar.prefersLargeTitles = YES;

    self.table = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleInsetGrouped];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];

	self.searchResults = [NSMutableArray new];

	self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.navigationController];
	self.searchController.delegate = self;
	self.searchController.searchBar.delegate = self;
	self.searchController.hidesNavigationBarDuringPresentation = NO;
	
	self.navigationItem.searchController = self.searchController;

	self.progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
	self.progressItem = [[UIBarButtonItem alloc] initWithCustomView:self.progressView];
	
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	cell.textLabel.text = @"test";
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    NSMutableArray *headers = [NSMutableArray new];
	NSMutableArray *frameworks = [NSMutableArray new];

	NSString *basePath = [NSString stringWithFormat:@"%@/%@", SDK_PATH, [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedSDK"]];
	NSString *file;
	NSFileManager *manager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:basePath];

	while ((file = [enumerator nextObject])) {
		if ([[file pathExtension] isEqualToString:@"h"]) {
			if ([file.lowercaseString containsString:string.lowercaseString]) {
				[headers addObject:file];
			}
		} else if ([[file pathExtension] isEqualToString:@"framework"]) {
			if ([file.lowercaseString containsString:string.lowercaseString]) {
				[frameworks addObject:file];
			}
		}
	}
    
	self.headerResults = [[headers sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
	self.frameworkResults = [[frameworks sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];

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
}
@end