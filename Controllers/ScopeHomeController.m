#import "ScopeHomeController.h"
#import "ScopePathController.h"

@interface ScopeHomeController ()
@property (nonatomic, strong) UITableView *table;
@end

@implementation ScopeHomeController
- (id)init {
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMainElements) name:@"ScopeReloadHome" object:nil];
	}
	return self;
}
- (void)loadView {
    [super loadView];

    self.title = @"Scope";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - 60) style:UITableViewStyleInsetGrouped];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
}
- (void)viewDidLoad {
	[super viewDidLoad];
	self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];

	self.selectorButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[self.selectorButton setTitle:@"Select SDK" forState:UIControlStateNormal];
	[self.selectorButton setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
	self.selectorButton.backgroundColor = [UIColor systemBlueColor];
	self.selectorButton.showsMenuAsPrimaryAction = YES;
    self.selectorButton.layer.cornerRadius = 10;
    self.selectorButton.layer.masksToBounds = YES;
	self.selectorButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self updateMainElements];

	/* self.warningLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	self.warningLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.warningLabel.textColor = [UIColor secondaryLabelColor];
	self.warningLabel.text = @"No SDKs found. Open the Settings page to download SDKs";
	self.warningLabel.numberOfLines = 2;
	self.warningLabel.textAlignment = NSTextAlignmentCenter;

	[self.view insertSubview:self.warningLabel aboveSubview:self.table]; */
	[self.headerView addSubview:self.selectorButton];

	[NSLayoutConstraint activateConstraints:@[
		[self.selectorButton.widthAnchor constraintEqualToConstant:100],
		[self.selectorButton.heightAnchor constraintEqualToConstant:40],
		[self.selectorButton.centerXAnchor constraintEqualToAnchor:self.headerView.centerXAnchor],
		[self.selectorButton.centerYAnchor constraintEqualToAnchor:self.headerView.centerYAnchor constant:10],
		/* [self.warningLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
		[self.warningLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
		[self.warningLabel.widthAnchor constraintEqualToConstant:300],
		[self.warningLabel.heightAnchor constraintEqualToConstant:60], */
	]];

	self.table.tableHeaderView = self.headerView;
}
- (void)updateMainElements {
	[self.table reloadData];
	NSArray *sdks = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:SDK_PATH error:nil];
	if (sdks != nil) {
		self.selectorButton.menu = [self sdkMenu];
		// self.warningLabel.hidden = NO;
	}
}
- (UIMenu *)sdkMenu {
	NSArray *sdks = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:SDK_PATH error:nil];
	NSMutableArray *menuItems = [[NSMutableArray alloc] init];
	for (int i = 0; i < [sdks count]; i++) {
		UIAction *item = [UIAction actionWithTitle:[sdks objectAtIndex:i] image:[UIImage systemImageNamed:@"chevron.left.forwardslash.chevron.right"] identifier:nil handler:^(__kindof UIAction *_Nonnull action) {
			[[NSUserDefaults standardUserDefaults] setObject:[sdks objectAtIndex:i] forKey:@"selectedSDK"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			[self.table reloadData];
		}];
		if ([item.title isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedSDK"]]) {
			item.state = UIMenuElementStateOn;
		} else {
			item.state = UIMenuElementStateOff;
		}
		[menuItems addObject:item];
	}

	UIMenu *menuActions = [UIMenu menuWithTitle:@"" children:menuItems];
	return menuActions;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *sdkRootPath = [NSString stringWithFormat:@"%@%@", SDK_PATH, [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedSDK"]];
	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *rootItems = [manager contentsOfDirectoryAtPath:sdkRootPath error:nil];
	return rootItems.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *sdkRootPath = [NSString stringWithFormat:@"%@%@", SDK_PATH, [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedSDK"]];
	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *rootItems = [manager contentsOfDirectoryAtPath:sdkRootPath error:nil];
	
	static NSString *CellIdentifier = @"homeCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}

	UIListContentConfiguration *content = [cell defaultContentConfiguration];
    [content setImage:[UIImage systemImageNamed:@"folder.fill"]];
    [content setText:[rootItems objectAtIndex:indexPath.row]];
    // [content setSecondaryText:item];
    [content.secondaryTextProperties setColor:[UIColor secondaryLabelColor]];
    [content.secondaryTextProperties setFont:[UIFont systemFontOfSize:12]];
    [cell setContentConfiguration:content];

	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	NSString *sdkRootPath = [NSString stringWithFormat:@"%@%@", SDK_PATH, [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedSDK"]];
	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *rootItems = [manager contentsOfDirectoryAtPath:sdkRootPath error:nil];

	ScopePathController *pathController = [[ScopePathController alloc] initWithPath:[NSString stringWithFormat:@"%@/%@", sdkRootPath, rootItems[indexPath.row]] title:[rootItems objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:pathController animated:YES];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
   	NSString *sdkRoot = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedSDK"];
	return sdkRoot ? [NSString stringWithFormat:@"iOS %@", sdkRoot] : @"";
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
- (void)pushPathControllerWithPath:(NSString *)path {
	ScopePathController *pathController = [[ScopePathController alloc] initWithPath:path title:path];
	[self.navigationController pushViewController:pathController animated:YES];
}
- (void)reloadTable {
	[_table reloadData];
	self.selectorButton.menu = [self sdkMenu];
}
@end
