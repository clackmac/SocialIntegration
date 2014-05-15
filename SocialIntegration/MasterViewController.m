//
//  MasterViewController.m
//  SocialIntegration
//
//  Created by Omer Hagopian on 5/13/14.
//  Copyright (c) 2014 Omer Hagopian. All rights reserved.
//

#import "MasterViewController.h"
#import "FacebookViewController.h"
#import "TwitterViewController.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _objects = [NSMutableArray new];
    [_objects addObject:@"Facebook"];
    [_objects addObject:@"Twitter"];
    [_objects addObject:@"Instagram"];
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

    cell.textLabel.text = _objects[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *service = [_objects objectAtIndex:indexPath.row];
    UIViewController *vc = nil;
    if ([service isEqualToString:@"Facebook"]) {
        vc = [FacebookViewController new];
    }
    else if ([service isEqualToString:@"Twitter"]) {
        vc = [TwitterViewController new];
    }
    
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
