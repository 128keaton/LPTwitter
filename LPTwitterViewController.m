#import "LPTwitterViewController.h"
#include "Accounts/Accounts.h"
#import "Social/Social.h"
#import "MBProgressHUD.h"
#define NSLog(LogContents, ...) NSLog((@"LPInterfaceBuilderExample: %s:%d " LogContents), __FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation LPTwitterViewController

-(id) init {
	self = [super init];
	if (self) {
		_ibView = [[[NSBundle bundleWithPath:@"/Library/Application Support/LPInterfaceBuilderExample"] loadNibNamed:@"LPTwitterView" owner:self options:nil] objectAtIndex:0];
		[self setView:_ibView];
       
	}
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(getTimeLine)
                  forControlEvents:UIControlEventValueChanged];
    
	return self;
}

-(void) pageWillPresent {
	NSLog(@"pageWillPresent called!");
     [self getTimeLine];
   
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    NSDictionary *tweet = _dataSource[[indexPath row]];
    NSDictionary *user = tweet[@"user"];

    NSLog(@"Twat: %@", tweet);
    cell.textLabel.text =[NSString stringWithFormat: @"%@ - %@", tweet[@"text"],  user[@"name"]];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.numberOfLines = 0;
       return cell;
}
-(void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        NSDictionary *tweet = _dataSource[[indexPath row]];
    
    [self favoriteTweet:tweet[@"id"]];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Set the custom view mode to show any view.
    self.hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    UIImage *image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/LPTwitter/Contents/Resources/heart.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView =  [[UIImageView alloc] initWithImage:image];
    [imageView setTintColor:[UIColor redColor]];
    self.hud.customView = imageView;
   
    // Looks a bit nicer if we make it square.
   
    // Optional label text.
    self.hud.labelText = NSLocalizedString(@"Favorited!", @"HUD done title");
    
   [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return UITableViewAutomaticDimension;
}
- (void)getTimeLine {
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account
                                  accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType
                                     options:nil completion:^(BOOL granted, NSError *error)
     {
         if (granted == YES)
         {
             NSArray *arrayOfAccounts = [account
                                         accountsWithAccountType:accountType];
             
             if ([arrayOfAccounts count] > 0)
             {
                 NSLog(@"has account");
                 
                 ACAccount *twitterAccount =
                 [arrayOfAccounts lastObject];
                 
                 NSURL *requestURL = [NSURL URLWithString:
                                      @"https://api.twitter.com/1.1/statuses/home_timeline.json"];
                 
                 NSDictionary *parameters =
                 @{@"exclude_replies" : @"true",
                   @"count" : @"20"};
                 
                 SLRequest *postRequest = [SLRequest
                                           requestForServiceType:SLServiceTypeTwitter
                                           requestMethod:SLRequestMethodGET
                                           URL:requestURL parameters:parameters];
                 
                 postRequest.account = twitterAccount;
                 
                 [postRequest performRequestWithHandler:
                  ^(NSData *responseData, NSHTTPURLResponse
                    *urlResponse, NSError *error)
                  {
                      self.dataSource = [NSJSONSerialization
                                         JSONObjectWithData:responseData
                                         options:NSJSONReadingMutableLeaves
                                         error:&error];
                      
                      if (self.dataSource.count != 0) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                
                              
                              [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                              [self.refreshControl endRefreshing];
                          });
                      }
                  }];
                 
             }
         } else {
             // Handle failure to get account access
         }
     }];
}

-(void) pageDidPresent {
	NSLog(@"pageDidPresent called!");
   
    
}
-(void)favoriteTweet:(NSString *)ident{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account
                                  accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType
                                     options:nil completion:^(BOOL granted, NSError *error)
     {
         if (granted == YES)
         {
             NSArray *arrayOfAccounts = [account
                                         accountsWithAccountType:accountType];
             
             if ([arrayOfAccounts count] > 0)
             {
                 NSLog(@"has account");
                 NSLog(@"The darn id: %@", ident);
                 ACAccount *twitterAccount =
                 [arrayOfAccounts lastObject];
                 
                 NSURL *requestURL = [NSURL URLWithString:
                                      @"https://api.twitter.com/1.1/favorites/create.json"];
                 NSString *idD = [NSString stringWithFormat:@"%@", ident];
                 NSDictionary *parameters = @{@"id" : idD};
                 NSLog(@"The request %@", parameters);
                 
                 SLRequest *postRequest = [SLRequest
                                           requestForServiceType:SLServiceTypeTwitter
                                           requestMethod:SLRequestMethodPOST
                                           URL:requestURL parameters:parameters];
                 
                 postRequest.account = twitterAccount;
                 __block NSHTTPURLResponse *respyTheJinglePup = nil;
                [postRequest performRequestWithHandler:^(NSData *responseData,
                                                          NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      NSLog(@"Twitter HTTP response: %li", (long)[urlResponse
                                                           statusCode]);
                   dispatch_async(dispatch_get_main_queue(), ^{
                       [self.hud hide:true afterDelay:0.0f];
                       self.hud.removeFromSuperViewOnHide = true;
                   });
                      respyTheJinglePup = urlResponse;
                      
                      
                      
                  }];
                 NSLog(@"Twitter HTTP response: %li", (long)[respyTheJinglePup
                                                             statusCode]);
                 
             }
         } else {
             // Handle failure to get account access
             NSLog(@"failure");
         }
     }];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
-(void) pageWillDismiss {
	NSLog(@"pageWillDismiss called!");
}

-(void) pageDidDismiss {
	NSLog(@"pageDidDismiss called!");
}

-(CGFloat) idleTimerInterval {
	return 60;
}

-(BOOL) isTimeEnabled {
	return 1;
}

-(CGFloat) backgroundAlpha {
	return 0.6;
}

-(NSInteger) priority {
	return 10;
}
@end
