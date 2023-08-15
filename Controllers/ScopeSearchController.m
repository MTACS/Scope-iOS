#import "ScopeSearchController.h"

#define SDK_PATH @"/Library/Application Support/Scope/sdks/"

@interface ScopeSearchController ()
@property (nonatomic, strong) UITableView *table;
@end

@implementation ScopeSearchController
@synthesize progressView;
@synthesize progressItem;
- (void)loadView {
    [super loadView];

    self.title = @"Search";
    self.navigationController.navigationBar.prefersLargeTitles = YES;

    self.table = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleInsetGrouped];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];

	self.headerResults = [NSMutableArray new];
      self.frameworkResults = [NSMutableArray new];

	self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.navigationController];
	self.searchController.delegate = self;
	self.searchController.searchBar.delegate = self;
	self.searchController.hidesNavigationBarDuringPresentation = YES;
	
	self.navigationItem.searchController = self.searchController;

	self.progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
	self.progressItem = [[UIBarButtonItem alloc] initWithCustomView:self.progressView];
      [self.progressView startAnimating];
	self.navigationItem.rightBarButtonItems = @[progressItem];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2:
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
      NSInteger rows = 0;
      if (self.searching) {
            if (section == 0) {
                  rows = self.headerResults.count;
            } else if (section == 1) {
                  rows = self.frameworkResults.count;
            }
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
      UIImage *cellIcon;
	
      UIListContentConfiguration *content = [cell defaultContentConfiguration];
    [content setImage:cellIcon];
    [content setText:cellTitle];
    [content setSecondaryText:@"Test"];
    [content.secondaryTextProperties setColor:[UIColor secondaryLabelColor]];
    [content.secondaryTextProperties setFont:[UIFont systemFontOfSize:12]];
    [cell setContentConfiguration:content];

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
	[self.headerResults removeAllObjects];
      [self.frameworkResults removeAllObjects];
    NSMutableArray *headers = [NSMutableArray new];
	NSMutableArray *frameworks = [NSMutableArray new];

	NSString *basePath = [NSString stringWithFormat:@"%@/%@", SDK_PATH, [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedSDK"]];
	NSString *file;
	NSFileManager *manager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:basePath];

	while ((file = [enumerator nextObject])) {
		if ([[file pathExtension] isEqualToString:@"h"]) {
			if ([file.lowercaseString containsString:query.lowercaseString]) {
				[headers addObject:file];
			}
		} else if ([[file pathExtension] isEqualToString:@"framework"]) {
			if ([file.lowercaseString containsString:query.lowercaseString]) {
				[frameworks addObject:file];
			}
		}
	}
    
	self.headerResults = [[headers sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
	self.frameworkResults = [[frameworks sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];

	self.searching = YES;
	[_table reloadData];
    // [self updateTitleButtons];
}
- (void)cancelSearch {
	self.searching = NO;
	[_table reloadData];
	[self.headerResults removeAllObjects];
      [self.frameworkResults removeAllObjects];
    // [self updateTitleButtons];
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