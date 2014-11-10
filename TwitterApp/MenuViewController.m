//
//  MenuViewController.m
//  TwitterApp
//
//  Created by Rishit Shroff on 11/8/14.
//  Copyright (c) 2014 Rishit Shroff. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuOptionTableViewCell.h"
#import "ProfileViewController.h"
#import "TweetsViewController.h"
#import "HamburgerViewController.h"
#import "LoginViewController.h"
#import "User.h"
#import "TwitterClient.h"
#import "UIImageView+AFNetworking.h"

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;

@property (weak, nonatomic) IBOutlet UITableView *menuTable;
@property (strong, nonatomic) NSMutableDictionary *options;
@property (strong, nonatomic) NSArray *optionLabels;
@property (strong, nonatomic) HamburgerViewController *hvc;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;

    
    // Set the Background Color
    [self.navigationController.navigationBar setBarTintColor:[TwitterClient getTwitterColor]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.view setBackgroundColor:[TwitterClient getTwitterColor]];
    
    self.menuTable.delegate = self;
    self.menuTable.dataSource = self;
    
    [self.menuTable registerNib:[UINib nibWithNibName:@"MenuOptionTableViewCell" bundle:nil] forCellReuseIdentifier:@"MenuOptionTableViewCell"];
    self.menuTable.rowHeight = UITableViewAutomaticDimension;
    
    self.hvc = [HamburgerViewController controller];
    
    self.optionLabels = @[@"Home",
                          @"Profile",
                          @"Mentions",
                          @"Logout"];
    
    self.options = [NSMutableDictionary dictionary];
    
    TweetsViewController *tvc = [[TweetsViewController alloc] init];
    tvc.isMentions = false;
    [self.options setObject:[[UINavigationController alloc] initWithRootViewController:tvc] forKey:@"Home"];
    [self.options setObject:[[UINavigationController alloc] initWithRootViewController:[[ProfileViewController alloc] init]] forKey:@"Profile"];
    
    TweetsViewController *mentionsController = [[TweetsViewController alloc] init];
    mentionsController.isMentions = true;
    
    [self.options setObject:[[UINavigationController alloc] initWithRootViewController:mentionsController] forKey:@"Mentions"];
    
    [self.options setObject:[[LoginViewController alloc] init] forKey:@"Logout"];
    
    User *user = [User currentUser];
    
    if (user == nil) {
        [self.hvc addContentViewController:
         (UIViewController *)[self.options objectForKey:@"Logout"]];        
    } else {
        [self.hvc addContentViewController:
         (UIViewController *)[self.options objectForKey:@"Home"]];
        [self.profilePic setImageWithURL:[NSURL URLWithString:user.profilePicURL]];
        self.profilePic.layer.borderWidth = 0.4f;
        self.profilePic.layer.borderColor = [UIColor grayColor].CGColor;
        self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2;
        self.profilePic.clipsToBounds = YES;
    }

    self.menuTable.layer.borderWidth = 0.0f;
    self.menuTable.separatorColor = [UIColor clearColor];
    self.menuTable.backgroundColor = [TwitterClient getTwitterColor];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    MenuOptionTableViewCell *cell = [self.menuTable dequeueReusableCellWithIdentifier:@"MenuOptionTableViewCell" forIndexPath:indexPath];
    [cell.menuText setText:self.optionLabels[indexPath.row]];

    [cell setBackgroundColor:[TwitterClient getTwitterColor]];
    [cell.menuText setTextColor:[UIColor whiteColor]];
    cell.layer.borderWidth = 0.0f;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIViewController *vc = (UIViewController *)[self.options objectForKey:self.optionLabels[indexPath.row]];
    
    if ([self.optionLabels[indexPath.row] isEqualToString:@"Logout"]) {
        [User setCurrentUser:nil];
        [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
    }
    
    [self.hvc addContentViewController:vc];
}

- (void) showHomePage {
    User *user = [User currentUser];
    
    if (user == nil) {
        [self.hvc addContentViewController:
         (UIViewController *)[self.options objectForKey:@"Logout"]];
    } else {
        [self.hvc addContentViewController:
         (UIViewController *)[self.options objectForKey:@"Home"]];
    }
}

- (IBAction)onProfileTapped:(UITapGestureRecognizer *)sender {
    [self.hvc addContentViewController:(UIViewController *)[self.options objectForKey:@"Profile"]];
}
@end
