#import "ScopeSettingsController.h"

@interface ScopeSettingsController ()
@property (nonatomic, strong) UITableView *table;
@end

@implementation ScopeSettingsController
- (void)loadView {
    [super loadView];

    self.title = @"Settings";
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
	return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	NSString *title;
	NSString *subtitle;
	switch (indexPath.row) {
        case 0:
			title = @"14.8";
			subtitle = @"iPhoneOS14.8.sdk";
			break;
		case 1:
			title = @"15.0";
			subtitle = @"iPhoneOS15.0.sdk";
			break;
		case 2:
			title = @"16.0";
			subtitle = @"iPhoneOS16.0.sdk";
			break;
	}

	UIListContentConfiguration *content = [cell defaultContentConfiguration];
    [content setImage:[UIImage systemImageNamed:@"shippingbox.fill"]];
    [content setText:title];
    [content setSecondaryText:subtitle];
    [content.secondaryTextProperties setColor:[UIColor secondaryLabelColor]];
    [content.secondaryTextProperties setFont:[UIFont systemFontOfSize:12]];
    [cell setContentConfiguration:content];

	UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[downloadButton setFrame:CGRectMake(0, 0, 60, 60)];
	[downloadButton setImage:[UIImage systemImageNamed:@"arrow.down.circle.fill"] forState:UIControlStateNormal];
	cell.accessoryView = downloadButton;

	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Download SDKs";
}
@end