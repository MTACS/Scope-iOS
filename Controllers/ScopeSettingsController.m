#import "ScopeSettingsController.h"
#import <rootless.h>
#define SDK_PATH @"/var/mobile/Library/Preferences/Scope/"

@import SafariServices;
NSFileManager *fileManager;
NSUserDefaults *defaults;

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

		fileManager = [NSFileManager defaultManager];
		defaults = [NSUserDefaults standardUserDefaults];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideProgressView) name:@"ScopeHideProgress" object:nil];
	}
	return self;
}
- (void)loadView {
    [super loadView];

	if (![defaults objectForKey:@"fontSize"]) {
		[defaults setObject:[NSNumber numberWithInt:16] forKey:@"fontSize"];
		[defaults synchronize];
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
- (void)hideProgressView {
	self.headerView.hidden = YES;
}
- (void)showBackgroundAlert {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Downloads will not continue if the app is in the background. Please keep the app open until the download/extraction is complete" preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		
	}];
	[alert addAction:dismiss];
	[self presentViewController:alert animated:YES completion:nil];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
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
            rows = 1;
            break;
		case 4:
			rows = 3;
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

		BOOL exists = [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@%@", ROOT_PATH_NS(SDK_PATH), [self.saveURLS[indexPath.row] stringByDeletingPathExtension]]];

		UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[downloadButton setFrame:CGRectMake(0, 0, 30, 30)];
		[downloadButton setBackgroundImage:(exists ? [UIImage systemImageNamed:@"checkmark.circle.fill"] : [UIImage systemImageNamed:@"arrow.down.circle.fill"]) forState:UIControlStateNormal];
		[downloadButton addTarget:self action:@selector(downloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		cell.accessoryView = downloadButton;

		cell.tag = indexPath.row;

		cellImage = [UIImage systemImageNamed:@"shippingbox.fill"];
	} else if (indexPath.section == 1) {
		NSInteger fontSize = [[defaults objectForKey:@"fontSize"] integerValue];
		
		title = [NSString stringWithFormat:@"Font Size: %ld", fontSize];
		subtitle = @"Swipe left to reset";
		
		UIStepper *fontStepper = [[UIStepper alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
		fontStepper.value = fontSize;
		fontStepper.maximumValue = 80;
		fontStepper.minimumValue = 10;
		[fontStepper addTarget:self action:@selector(fontSizeChanged:) forControlEvents:UIControlEventValueChanged];  
		cell.accessoryView = fontStepper;

		cellImage = [UIImage systemImageNamed:@"textformat"];
	} else if (indexPath.section == 2) {
		title = @"Reset";
		subtitle = @"Restore all settings";
		cellImage = [UIImage systemImageNamed:@"arrow.clockwise.circle.fill"];
	} else if (indexPath.section == 3) {
		if (indexPath.row == 0) {
			title = @"D.F. (MTAC)";
			subtitle = @"https://twitter.com/mtac8";
			cellImage = [UIImage systemImageNamed:@"person.circle.fill"];
		}
	} else if (indexPath.section == 4) {
		if (indexPath.row == 0) {
			title = @"Source Code";
			subtitle = @"https://github.com/MTACS/Scope-iOS";
			cellImage = [UIImage systemImageNamed:@"safari.fill"];
		} else if (indexPath.row == 1) {
			title = @"Syntax Highlighting";
			subtitle = @"https://github.com/Skittyblock/FilzaPlus";
			cellImage = [UIImage systemImageNamed:@"paintbrush.pointed.fill"];
		} else if (indexPath.row == 2) {
			title = @"Unarchiving";
			subtitle = @"https://github.com/ZipArchive/ZipArchive";
			cellImage = [UIImage systemImageNamed:@"doc.plaintext.fill"];
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
		NSString *sdkIndex = [NSString stringWithFormat:@"%@%@", ROOT_PATH_NS(SDK_PATH), [self.saveURLS[indexPath.row] stringByDeletingPathExtension]];
		BOOL exists = [fileManager fileExistsAtPath:sdkIndex];

		UIContextualAction *removeAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
			[fileManager removeItemAtPath:sdkIndex error:nil];
			[defaults removeObjectForKey:@"selectedSDK"];
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
			[defaults setObject:[NSNumber numberWithInt:16] forKey:@"fontSize"];
			[defaults synchronize];
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
	BOOL exists = [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@%@", ROOT_PATH_NS(SDK_PATH), [self.saveURLS[index] stringByDeletingPathExtension]]];
	[self showBackgroundAlert];
    if (!exists) {
		[self downloadItem:cell.tag destination:[self.saveURLS objectAtIndex:index]];
	}
}
- (void)cancelDownload {
	[_session invalidateAndCancel];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ScopeHideProgress" object:nil];

	NSArray *pathItems = [fileManager contentsOfDirectoryAtPath:ROOT_PATH_NS(SDK_PATH) error:nil];
	for (NSString *pathItem in pathItems) {
		if ([pathItem.pathExtension isEqualToString:@"zip"]) {
			[fileManager removeItemAtPath:[ROOT_PATH_NS(SDK_PATH) stringByAppendingPathComponent:pathItem] error:nil];
		}
	}
}
- (void)fontSizeChanged:(UIStepper *)stepper {
    [defaults setObject:[NSNumber numberWithInt:(int)stepper.value] forKey:@"fontSize"];
	[_table reloadData];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ScopeReloadFont" object:nil];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			[defaults removePersistentDomainForName:@"com.mtac.scope"];
			[defaults synchronize];
			UIApplication *app = [UIApplication sharedApplication];
            [app performSelector:@selector(suspend)];
			exit(0);
		}
	} else if (indexPath.section == 3) {
		if (indexPath.row == 0) {
			[[NSBundle bundleWithPath:ROOT_PATH_NS(@"/System/Library/Frameworks/SafariServices.framework")] load];
			if ([SFSafariViewController class] != nil) {
				SFSafariViewController *safariView = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://twitter.com/mtac8"]];
				[self.navigationController presentViewController:safariView animated:YES completion:nil];
			}
		}
	} else if (indexPath.section == 4) {
		[[NSBundle bundleWithPath:ROOT_PATH_NS(@"/System/Library/Frameworks/SafariServices.framework")] load];
		SFSafariViewController *safariView;
		if (indexPath.row == 0) {
			safariView = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://github.com/MTACS/Scope-iOS"]];
		} else if (indexPath.row == 1) {
			safariView = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://github.com/Skittyblock/FilzaPlus"]];
		} else if (indexPath.row == 2) {
			safariView = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://github.com/ZipArchive/ZipArchive"]];
		}
		[self.navigationController presentViewController:safariView animated:YES completion:nil];
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
			title = @"About";
			break;
		case 4:
            title = @"Source Code";
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
	NSArray *pathItems = [fileManager contentsOfDirectoryAtPath:ROOT_PATH_NS(SDK_PATH) error:nil];
	for (NSString *pathItem in pathItems) {
		if ([pathItem.pathExtension isEqualToString:@"zip"]) {
			[fileManager removeItemAtPath:[ROOT_PATH_NS(SDK_PATH) stringByAppendingPathComponent:pathItem] error:nil];
		}
	}

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
    NSString *finalPath = [NSString stringWithFormat:@"%@%@", ROOT_PATH_NS(SDK_PATH), self.downloadPath];
    [fileManager copyItemAtURL:location toURL:[NSURL fileURLWithPath:finalPath] error:&err];
    if (err) {
        [self.headerLabel setText:@"Download Error"];
    } else {
		[self.headerLabel setText:@"Unzipping SDK"];
        [self unzipItem:finalPath];
    }
}
- (void)unzipItem:(NSString *)path {
    [SSZipArchive unzipFileAtPath:path toDestination:ROOT_PATH_NS(SDK_PATH) delegate:self];
}
- (void)zipArchiveProgressEvent:(unsigned long long)loaded total:(unsigned long long)total {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
		double progress = (double)loaded / (double)total;
	
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[self.progressView setProgress:progress animated:YES];
			[self.headerLabel setText:[NSString stringWithFormat:@"Extracting: %2.f%%", progress * 100]];
			if (progress == 1.0) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"ScopeHideProgress" object:nil];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"ScopeReloadHome" object:nil];
			}
		});
	});
}
- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath {
    [fileManager removeItemAtPath:path error:nil];
}
@end