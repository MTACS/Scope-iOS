#import "ScopeHomeController.h"

@interface ScopeHomeController ()
@property (nonatomic, strong) UITableView *table;
@end

@implementation ScopeHomeController
- (void)loadView {
    [super loadView];

    self.title = @"Scope";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.table = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleInsetGrouped];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];

	[self setupMenu];
}
- (void)setupMenu {
	NSArray *sdks = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:SDK_PATH error:nil];
	NSMutableArray *menuItems = [[NSMutableArray alloc] init];
	for (int i = 0; i < [sdks count]; i++) {
		UIAction *item = [UIAction actionWithTitle:[sdks objectAtIndex:i] image:[UIImage systemImageNamed:@"chevron.left.forwardslash.chevron.right"] identifier:nil handler:^(__kindof UIAction *_Nonnull action) {
			
		}];
		[menuItems addObject:item];
	}

	UIMenu *menuActions = [UIMenu menuWithTitle:@"" children:menuItems];
	UIBarButtonItem *sdkItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"gearshape.fill"] menu:menuActions];
	self.navigationItem.rightBarButtonItems = @[sdkItem];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *sdkRoot = [NSString stringWithFormat:@"%@14.8/", SDK_PATH];
	NSArray *rootItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sdkRoot error:nil];
	return rootItems.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *sdkRoot = [NSString stringWithFormat:@"%@14.8/", SDK_PATH];
	NSArray *rootItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sdkRoot error:nil];
	
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	cell.textLabel.text = [rootItems objectAtIndex:indexPath.row];
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section {
    return @"14.8";
}
@end
