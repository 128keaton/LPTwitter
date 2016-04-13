#import "LPTwitterViewController.h"
#include "Accounts/Accounts.h"
#import "Social/Social.h"
#define NSLog(LogContents, ...) NSLog((@"LPInterfaceBuilderExample: %s:%d " LogContents), __FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation LPTwitterViewController
-(id) init {
	self = [super init];
	if (self) {
		_ibView = [[[NSBundle bundleWithPath:@"/Library/Application Support/LPInterfaceBuilderExample"] loadNibNamed:@"LPTwitterView" owner:self options:nil] objectAtIndex:0];
		[self setView:_ibView];
        _tweetCell = [[[NSBundle bundleWithPath:@"/Library/Application Support/LPInterfaceBuilderExample"] loadNibNamed:@"TweetCell" owner:self options:nil] objectAtIndex:0];
	}
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/edent/status/%@", tweet[@"id"]]]];
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
