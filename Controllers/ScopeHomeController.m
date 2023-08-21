#import "ScopeHomeController.h"
#import "ScopePathController.h"
#import <rootless.h>

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

	[self.headerView addSubview:self.selectorButton];

	[NSLayoutConstraint activateConstraints:@[
		[self.selectorButton.widthAnchor constraintEqualToConstant:100],
		[self.selectorButton.heightAnchor constraintEqualToConstant:40],
		[self.selectorButton.centerXAnchor constraintEqualToAnchor:self.headerView.centerXAnchor],
		[self.selectorButton.centerYAnchor constraintEqualToAnchor:self.headerView.centerYAnchor constant:10],
	]];

	self.table.tableHeaderView = self.headerView;

	NSArray *sdks = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:ROOT_PATH_NS(SDK_PATH) error:nil];
	if (sdks.count == 0) {
		[self performSelector:@selector(showSDKWarning) withObject:nil afterDelay:1];
	} 
}
- (void)updateMainElements {
	[self.table reloadData];
	NSArray *sdks = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:ROOT_PATH_NS(SDK_PATH) error:nil];
	if (sdks.count != 0) {
		self.selectorButton.menu = [self sdkMenu];
	}
}
- (UIMenu *)sdkMenu {
	NSArray *sdkItems = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:ROOT_PATH_NS(SDK_PATH) error:nil] copy];
	NSArray *sdks = [sdkItems sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
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
- (void)showSDKWarning {
	self.warningController = [[OBWelcomeController alloc] initWithTitle:@"Scope" detailText:@"" icon:[UIImage imageWithContentsOfFile:ROOT_PATH_NS(@"/Applications/Scope.app/AppIcon-Rounded.png")]];
	[self.warningController addBulletedListItemWithTitle:@"No SDKs Found" description:@"Open settings to download SDKs" image:[UIImage systemImageNamed:@"shippingbox.fill"]];
    
	OBTrayButton *confirm = [OBTrayButton buttonWithType:0];
	[confirm addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
	[confirm setTitle:@"Open Settings" forState:UIControlStateNormal];
	[confirm setClipsToBounds:YES];
	[confirm setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
	[confirm setBackgroundColor:[UIColor systemBlueColor]];
	[confirm.layer setCornerRadius:12];
	[self.warningController.buttonTray addButton:confirm];

	self.warningController.buttonTray.effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
    UIVisualEffectView *effectWelcomeView = [[UIVisualEffectView alloc] initWithFrame:self.warningController.viewIfLoaded.bounds];
    effectWelcomeView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
    
	[self.warningController.viewIfLoaded insertSubview:effectWelcomeView atIndex:0];
    self.warningController.viewIfLoaded.backgroundColor = [UIColor clearColor];
    self.warningController.modalPresentationStyle = UIModalPresentationPageSheet;
    self.warningController.modalInPresentation = NO;
	self.warningController._shouldInlineButtontray = NO;
    [self presentViewController:self.warningController animated:YES completion:nil];
}
- (void)openSettings {
	UITabBarController *tabBarController = (UITabBarController *)[[UIApplication sharedApplication].keyWindow rootViewController];
	[tabBarController setSelectedIndex:3];
	[self.warningController dismissViewControllerAnimated:YES completion:nil];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *sdkRootPath = [NSString stringWithFormat:@"%@%@", ROOT_PATH_NS(SDK_PATH), [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedSDK"]];
	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *rootItems = [manager contentsOfDirectoryAtPath:sdkRootPath error:nil];
	return rootItems.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *sdkRootPath = [NSString stringWithFormat:@"%@%@", ROOT_PATH_NS(SDK_PATH), [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedSDK"]];
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

	NSString *sdkRootPath = [NSString stringWithFormat:@"%@%@", ROOT_PATH_NS(SDK_PATH), [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedSDK"]];
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
