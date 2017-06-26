//
//  SearchVKFrendsViewController.m
//  FinanceProject
//
//  Created by Вадим Чистяков on 22.06.17.
//  Copyright © 2017 Вадим Чистяков. All rights reserved.
//

#import "SearchVKFrendsViewController.h"
#import "UserVKModel.h"
#import "ManagerServer.h"
#import "AppDelegate.h"
#import "FriendVK+CoreDataClass.h"



@interface SearchVKFrendsViewController () <UISearchBarDelegate, UITextFieldDelegate>

@property (assign, nonatomic) BOOL firstTimeAppear;
@property (assign, nonatomic) NSInteger numberOfUser;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray<UserVKModel*> *friends;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UITextField *textField;


@end

@implementation SearchVKFrendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.table.delegate = self;
    self.table.dataSource = self;
    self.searchBar.delegate = self;
    
    self.firstTimeAppear = YES;
    self.friends =[NSMutableArray new];
                   
    [self getFriendsFromVk];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.firstTimeAppear) {
        self.firstTimeAppear = NO;
        
    }
}

- (void)getFriendsFromVk {
    
    
}
#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (searchBar.text.length < 2) {
        return;
    }
    [self.friends removeAllObjects];
    [self.table reloadData];
    
    [searchBar resignFirstResponder];
    
   // NSString * query = @"Ab";
    
    [[ManagerServer sharedManager]
     authorizeUserWirhQuery:searchBar.text
                   andBlock:^(NSArray * friends) {
                       [self.friends removeAllObjects];
                       [self.friends addObjectsFromArray:friends];
                       [self.table reloadData];
    }];
    
}

#pragma mark - UITableViewDataSource, Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friends count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.numberOfUser = indexPath.row;
    NSLog(@"%ld",indexPath.row);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellSearch"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellSearch"];
    }
    UserVKModel *friend = self.friends[indexPath.row];
    cell.textLabel.text = friend.firstName;
    cell.detailTextLabel.text = friend.lastName;
    return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.textField]) {
        [textField resignFirstResponder];
    }
    return YES;
}


#pragma mark -

- (IBAction)didTapSaveButton:(id)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext * context = appDelegate.persistentContainer.viewContext;
    
    NSEntityDescription *friendDescription = [NSEntityDescription  entityForName:@"FriendVK" inManagedObjectContext:context];
    
    FriendVK * friend = [[FriendVK alloc] initWithEntity:friendDescription insertIntoManagedObjectContext:context];
    
    UserVKModel * selectFriend = [UserVKModel new];
    selectFriend = self.friends[self.numberOfUser];
    
    friend.firstName = selectFriend.firstName;
    friend.lastName = selectFriend.lastName;
    friend.urlImage = selectFriend.urlPhoto50;
    friend.isDebt = self.segmentControl.selectedSegmentIndex;
    friend.summ = self.textField.text;

    [appDelegate saveContext];

}
@end
