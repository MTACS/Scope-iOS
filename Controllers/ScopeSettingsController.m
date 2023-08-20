#import "ScopeSettingsController.h"

#define SDK_PATH @"/var/mobile/Library/Preferences/Scope/"

@interface ScopeSettingsController ()
@property (nonatomic, strong) UITableView *table;
@end

@implementation ScopeSettingsController {
	NSURLSession *_session;
    NSURLSessionDownloadTask *_downloadTask;
}
- (id)init {
	self = [super init];
	if (self) {
		self.downloadURLS = @[
            [NSURL URLWithString:@"https://mtac.app/scope/sdks/14.8.zip"], 
            [NSURL URLWithString:@"https://mtac.app/scope/sdks/15.0.zip"], 
            [NSURL URLWithString:@"https://mtac.app/scope/sdks/16.0.zip"]
        ];

		self.saveURLS = @[
			@"14.8.zip",
			@"15.0.zip",
			@"16.0.zip"
		];
	}
	return self;
}
- (void)loadView {
    [super loadView];

	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"fontSize"]) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:16] forKey:@"fontSize"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}

    self.title = @"Settings";
    self.navigationController.navigationBar.prefersLargeTitles = YES;

    self.table = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - 60) style:UITableViewStyleInsetGrouped];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];

	self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
	
	self.headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.headerLabel.textColor = [UIColor secondaryLabelColor];
	
	self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	self.progressView.translatesAutoresizingMaskIntoConstraints = NO;

	UIButton *cancelDownload = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelDownload.translatesAutoresizingMaskIntoConstraints = NO;
	[cancelDownload addTarget:self action:@selector(cancelDownload) forControlEvents:UIControlEventTouchUpInside];
	[cancelDownload setBackgroundImage:[UIImage systemImageNamed:@"xmark.circle.fill"] forState:UIControlStateNormal];
	[cancelDownload setTintColor:[UIColor secondaryLabelColor]];

	UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
	backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
	backgroundView.backgroundColor = [UIColor tableCellGroupedBackgroundColor];
	backgroundView.layer.masksToBounds = YES;
	backgroundView.layer.cornerRadius = 8;
	backgroundView.layer.continuousCorners = YES;

    [self.headerView addSubview:backgroundView];
	[self.headerView addSubview:self.headerLabel];
	[self.headerView addSubview:self.progressView];
	[self.headerView addSubview:cancelDownload];

	[NSLayoutConstraint activateConstraints:@[
		[backgroundView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor],
		[backgroundView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor constant:-16],
		[backgroundView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor constant:16],
		[backgroundView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
		[self.headerLabel.topAnchor constraintEqualToAnchor:self.headerView.topAnchor constant:5],
		[self.headerLabel.leadingAnchor constraintEqualToAnchor:backgroundView.leadingAnchor constant:16],
		[self.headerLabel.trailingAnchor constraintEqualToAnchor:backgroundView.trailingAnchor constant:-64],
		[self.headerLabel.heightAnchor constraintEqualToConstant:30],
		[self.progressView.topAnchor constraintEqualToAnchor:self.headerLabel.bottomAnchor constant:5],
		[self.progressView.leadingAnchor constraintEqualToAnchor:backgroundView.leadingAnchor constant:16],
		[self.progressView.trailingAnchor constraintEqualToAnchor:backgroundView.trailingAnchor constant:-64],
		[cancelDownload.trailingAnchor constraintEqualToAnchor:backgroundView.trailingAnchor constant:-16],
		[cancelDownload.centerYAnchor constraintEqualToAnchor:self.headerView.centerYAnchor],
		[cancelDownload.widthAnchor constraintEqualToConstant:32],
		[cancelDownload.heightAnchor constraintEqualToConstant:32],
	]];

    self.headerView.hidden = YES;
	self.table.tableHeaderView = self.headerView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
	switch (section) {
		case 0:
			rows = 3;
			break;
		case 1:
			rows = 1;
			break;
		case 2:
			rows = 1;
			break;
		case 3:
			rows = 2;
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

	NSString *title;
	NSString *subtitle;
	UIImage *cellImage;

	if (indexPath.section == 0) {
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

		BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@", SDK_PATH, [self.saveURLS[indexPath.row] stringByDeletingPathExtension]]];

		UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[downloadButton setFrame:CGRectMake(0, 0, 30, 30)];
		[downloadButton setBackgroundImage:(exists ? [UIImage systemImageNamed:@"checkmark.circle.fill"] : [UIImage systemImageNamed:@"arrow.down.circle.fill"]) forState:UIControlStateNormal];
		[downloadButton addTarget:self action:@selector(downloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		cell.accessoryView = downloadButton;

		cell.tag = indexPath.row;

		cellImage = [UIImage systemImageNamed:@"shippingbox.fill"];
	} else if (indexPath.section == 1) {
		NSInteger fontSize = [[[NSUserDefaults standardUserDefaults] objectForKey:@"fontSize"] integerValue];
		
		title = [NSString stringWithFormat:@"Font Size: %ld", fontSize];
		subtitle = @"Swipe left to reset";
		
		UIStepper *fontStepper = [[UIStepper alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
		fontStepper.value = fontSize;
		fontStepper.maximumValue = 80;
		fontStepper.minimumValue = 10;
		[fontStepper addTarget:self action:@selector(fontSizeChanged:) forControlEvents:UIControlEventValueChanged];  
		cell.accessoryView = fontStepper;

		cellImage = [UIImage systemImageNamed:@"doc.plaintext.fill"];
	} else if (indexPath.section == 2) {
		title = @"Reset";
		subtitle = @"Restore all settings";
		cellImage = [UIImage systemImageNamed:@"arrow.clockwise.circle.fill"];
	} else if (indexPath.section == 3) {
		if (indexPath.row == 0) {
			title = @"Syntax Highlighting";
			subtitle = @"https://github.com/Skittyblock/FilzaPlus";
			cellImage = [UIImage systemImageNamed:@"link"];
		} else if (indexPath.row == 1) {
			title = @"Unarchiving";
			subtitle = @"https://github.com/ZipArchive/ZipArchive";
			cellImage = [UIImage systemImageNamed:@"link"];
		}
	}

	UIListContentConfiguration *content = [cell defaultContentConfiguration];
    [content setImage:cellImage];
    [content setText:title];
    [content setSecondaryText:subtitle];
    [content.secondaryTextProperties setColor:[UIColor secondaryLabelColor]];
    [content.secondaryTextProperties setFont:[UIFont systemFontOfSize:12]];
    [cell setContentConfiguration:content];

	return cell;
}
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
	UISwipeActionsConfiguration *swipeActions;
	if (indexPath.section == 0) {
		NSString *sdkIndex = [NSString stringWithFormat:@"%@%@", SDK_PATH, [self.saveURLS[indexPath.row] stringByDeletingPathExtension]];
		BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:sdkIndex];

		UIContextualAction *removeAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
			[[NSFileManager defaultManager] removeItemAtPath:sdkIndex error:nil];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"selectedSDK"];
			[self.table reloadData];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ScopeReloadHome" object:nil];
			completionHandler(YES);
        }];

		removeAction.backgroundColor = [UIColor systemRedColor];
		removeAction.image = [UIImage systemImageNamed:@"xmark.circle.fill"];
        removeAction.title = @"Remove";

		swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[removeAction]];
		swipeActions.performsFirstActionWithFullSwipe = YES;
		return exists ? swipeActions : nil;
	} else if (indexPath.section == 1) {
        UIContextualAction *resetAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:16] forKey:@"fontSize"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			[_table reloadData];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ScopeReloadFont" object:nil];
            completionHandler(YES);
        }];

		resetAction.backgroundColor = [UIColor tableCellGroupedBackgroundColor];
		resetAction.image = [UIImage systemImageNamed:@"arrow.triangle.2.circlepath"];
        resetAction.title = @"Reset";

		swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[resetAction]];
		swipeActions.performsFirstActionWithFullSwipe = YES;
		return swipeActions;
    }
    return nil;
}
- (void)downloadButtonClicked:(UIButton *)sender {
	UITableViewCell *cell = (UITableViewCell *)sender.superview;
    NSInteger index = cell.tag;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@", SDK_PATH, [self.saveURLS[index] stringByDeletingPathExtension]]];

    if (!exists) {
		[self downloadItem:cell.tag destination:[self.saveURLS objectAtIndex:index]];
	}
}
- (void)cancelDownload {
	[_session invalidateAndCancel];
	self.headerView.hidden = YES;
}
- (void)fontSizeChanged:(UIStepper *)stepper {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)stepper.value] forKey:@"fontSize"];
	[_table reloadData];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ScopeReloadFont" object:nil];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"com.mtac.scope"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			UIApplication *app = [UIApplication sharedApplication];
            [app performSelector:@selector(suspend)];
			exit(0);
		}
	}
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
	switch (section) {
		case 0:
            title = @"Download SDKs";
            break;
        case 1:
            title = @"Editor";
            break;
        case 2:
            title = @"Reset";
            break;
        case 3:
			title = @"Libraries";
			break;
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
- (void)downloadItem:(NSInteger)index destination:(NSString *)path {
    self.downloadPath = path;
   	NSURL *source;
    switch (index) {
        case 0:
            source = self.downloadURLS[0];
            break;
        case 1:
            source = self.downloadURLS[1];
            break;
        case 2:
            source = self.downloadURLS[2];
            break;
    }

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    _downloadTask = [_session downloadTaskWithURL:source];
    [_downloadTask resume];

	self.headerView.hidden = NO;
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
		CGFloat percentDone = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[self.progressView setProgress:percentDone animated:YES];
			[self.headerLabel setText:[NSString stringWithFormat:@"Downloading: %2.f%%", percentDone * 100]];
		});
	});
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {

}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {

}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSError *err;
    NSString *finalPath = [NSString stringWithFormat:@"%@%@", SDK_PATH, self.downloadPath];
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:[NSURL fileURLWithPath:finalPath] error:&err];
    if (err) {
        [self.headerLabel setText:@"Download Error"];
    } else {
		[self.headerLabel setText:@"Unzipping SDK"];
        [self unzipItem:finalPath];
    }
}
- (void)unzipItem:(NSString *)path {
    [SSZipArchive unzipFileAtPath:path toDestination:SDK_PATH delegate:self];
}
- (void)zipArchiveProgressEvent:(unsigned long long)loaded total:(unsigned long long)total {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
		double progress = (double)loaded / (double)total;
	
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[self.progressView setProgress:progress animated:YES];
			[self.headerLabel setText:[NSString stringWithFormat:@"Extracting: %2.f%%", progress * 100]];
		});
	});
}
- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath {
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	self.headerView.hidden = YES;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ScopeReloadHome" object:nil];
}

@end