/*
 * Copyright (c) 2010-2019 Belledonne Communications SARL.
 *
 * This file is part of linphone-iphone
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#import "MasterView.h"
#import "DetailTableView.h"

#import "Log.h"
#include "TargetConditionals.h"
#include "linphonetester/liblinphone_tester.h"
#include "mediastreamer2/msutils.h"

@interface MasterView () {
	NSMutableArray *_objects;
	NSString *bundlePath;
	NSString *writablePath;
}
@end

@implementation MasterView

- (void)awakeFromNib {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		self.clearsSelectionOnViewWillAppear = NO;
		self.preferredContentSize = CGSizeMake(320.0, 600.0);
	}
	[super awakeFromNib];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.detailViewController =
		(DetailTableView *)[[self.splitViewController.viewControllers lastObject] topViewController];

	liblinphone_tester_init(NULL);
    [Log enableLogs:ORTP_DEBUG];
	liblinphone_tester_keep_accounts(TRUE);

	bundlePath = [NSString stringWithFormat:@"%@/liblinphone_tester/", [[NSBundle mainBundle] bundlePath]];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	writablePath = [paths objectAtIndex:0];
	
	// bc_tester_init(tester_logs_handler, ORTP_MESSAGE, ORTP_ERROR, "rcfiles");
	// liblinphone_tester_add_suites();

	bc_tester_set_resource_dir_prefix([bundlePath UTF8String]);
	bc_tester_set_writable_dir_prefix([writablePath UTF8String]);

	LOGI(@"Bundle path: %@", bundlePath);
	LOGI(@"Writable path: %@", writablePath);

	//liblinphonetester_ipv6 = true;

	int count = bc_tester_nb_suites();
	_objects = [[NSMutableArray alloc] initWithCapacity:count + 1];
	for (int i = 0; i < count; i++) {
		const char *suite = bc_tester_suite_name(i);
		[_objects addObject:[NSString stringWithUTF8String:suite]];
	}
	[_objects sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	[_objects insertObject:@"All" atIndex:0];
}

- (void)dealloc {
	liblinphone_tester_clear_accounts();
}

- (void)displayLogs {
	LOGI(@"Should display logs");
	[self.navigationController performSegueWithIdentifier:@"viewLogs" sender:self];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

	NSString *suite = _objects[indexPath.row];
	cell.textLabel.text = suite;
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return NO;
}

- (void)tableView:(UITableView *)tableView
	commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
	 forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[_objects removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table
		// view.
	}
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath
*)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Return NO if you do not want the item to be re-orderable.
	return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		NSString *object = _objects[indexPath.row];
		self.detailViewController.detailItem = object;
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"showDetail"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		NSString *object = _objects[indexPath.row];
		[[segue destinationViewController] setDetailItem:object];
	}
}

@end
