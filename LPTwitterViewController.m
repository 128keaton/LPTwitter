#include "Accounts/Accounts.h"
#import "LPTwitterViewController.h"
#import "MBProgressHUD.h"
#import "Social/Social.h"
#define NSLog(LogContents, ...)                                                \
  NSLog((@"LPInterfaceBuilderExample: %s:%d " LogContents), __FUNCTION__,      \
        __LINE__, ##__VA_ARGS__)

@implementation LPTwitterViewController

NSString *userPlaceHolder;

- (id)init {
  self = [super init];
  if (self) {
    _ibView = [[
        [NSBundle bundleWithPath:
                      @"/Library/Application Support/LPInterfaceBuilderExample"]
        loadNibNamed:@"LPTwitterView"
               owner:self
             options:nil] objectAtIndex:0];
    [self setView:_ibView];
  }
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.delegate = self;
   UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
  refreshControl.backgroundColor = [UIColor clearColor];
  refreshControl.tintColor = [UIColor whiteColor];
  [refreshControl addTarget:self
                     action:@selector(getTimeLine)
           forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];

  return self;
}

- (void)pageWillPresent {
  NSLog(@"pageWillPresent called!");
  [self getTimeLine];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell =
      [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:@"Cell"];
  }
  NSDictionary *tweet = _dataSource[[indexPath row]];
  NSDictionary *user = tweet[@"user"];

  NSLog(@"Twat: %@", tweet);
  cell.textLabel.text =
      [NSString stringWithFormat:@"%@ - %@", tweet[@"text"], user[@"name"]];
  cell.backgroundColor = [UIColor clearColor];
  cell.textLabel.textColor = [UIColor whiteColor];
  cell.textLabel.numberOfLines = 0;
  return cell;
}
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *tweet = _dataSource[[indexPath row]];

  UIAlertController *controller = [UIAlertController
      alertControllerWithTitle:@"What do you want to do?"
                       message:@""
                preferredStyle:UIAlertControllerStyleActionSheet];

  UIAlertAction *favorite = [UIAlertAction
      actionWithTitle:@"Favorite"
                style:UIAlertActionStyleDestructive
              handler:^(UIAlertAction *action) {
                [self favoriteTweet:tweet[@"id"]];
                self.hud =
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

                // Set the custom view mode to show any view.
                self.hud.mode = MBProgressHUDModeCustomView;
                // Set an image view with a checkmark.
                UIImage *image = [[UIImage
                    imageWithContentsOfFile:@"/Library/Application "
                                            @"Support/LPTwitter/Contents/"
                                            @"Resources/heart.png"]
                    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                UIImageView *imageView =
                    [[UIImageView alloc] initWithImage:image];
                [imageView setTintColor:[UIColor redColor]];
                self.hud.customView = imageView;
                self.hud.labelText =
                    NSLocalizedString(@"Favorited!", @"HUD done title");
              }];

  [controller addAction:favorite];

  UIAlertAction *reply = [UIAlertAction
      actionWithTitle:@"Reply"
                style:UIAlertActionStyleDestructive
              handler:^(UIAlertAction *action) {
                NSDictionary *user = tweet[@"user"];
                  userPlaceHolder = user[@"screen_name"];
                NSString *replyTitle = [NSString
                    stringWithFormat:@"Replying to: %@", user[@"screen_name"]];
                UIAlertController *alertController = [UIAlertController
                    alertControllerWithTitle:replyTitle
                                     message:@""
                              preferredStyle:UIAlertControllerStyleAlert];
                  

                [alertController addTextFieldWithConfigurationHandler:^(
                                     UITextField *textField) {
                  textField.placeholder = NSLocalizedString(@"Reply", @"Reply");
                    [textField addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
                    textField.delegate = self;
                }];
                UIAlertAction *ok = [UIAlertAction
                    actionWithTitle:@"Reply"
                              style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction *action) {

                                [self reply:tweet status:alertController.textFields.firstObject.text];
                              self.hud = [MBProgressHUD showHUDAddedTo:self.view
                                                              animated:YES];

                              // Set the custom view mode to show any view.
                              self.hud.mode = MBProgressHUDModeCustomView;
                              // Set an image view with a checkmark.
                              UIImage *image = [[UIImage
                                  imageWithContentsOfFile:@"/Library/"
                                                          @"Application "
                                                          @"Support/LPTwitter/"
                                                          @"Contents/"
                                                          @"Resources/"
                                                          @"reply.png"]
                                  imageWithRenderingMode:
                                      UIImageRenderingModeAlwaysTemplate];
                              UIImageView *imageView =
                                  [[UIImageView alloc] initWithImage:image];
                              [imageView setTintColor:[UIColor whiteColor]];
                              imageView.frame = CGRectMake(0, 0, 100, 100);
                              self.hud.customView = imageView;
                              self.hud.labelText = NSLocalizedString(
                                  @"Replied!", @"HUD done title");

                            }];

                UIAlertAction *cancel = [UIAlertAction
                    actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction *action) {

                              [alertController
                                  dismissViewControllerAnimated:YES
                                                     completion:nil];

                            }];
              
                [alertController addAction:cancel];
                [alertController addAction:ok];

                [self presentViewController:alertController
                                   animated:YES
                                 completion:nil];

              }];
  [controller addAction:reply];

  UIAlertAction *retweet = [UIAlertAction
      actionWithTitle:@"Retweet"
                style:UIAlertActionStyleDestructive
              handler:^(UIAlertAction *action) {
                [self reTweet:tweet[@"id"]];
                self.hud =
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

                // Set the custom view mode to show any view.
                self.hud.mode = MBProgressHUDModeCustomView;
                // Set an image view with a checkmark.
                UIImage *image = [[UIImage
                    imageWithContentsOfFile:@"/Library/Application "
                                            @"Support/LPTwitter/Contents/"
                                            @"Resources/retweet.png"]
                    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                UIImageView *imageView =
                    [[UIImageView alloc] initWithImage:image];
                imageView.frame = CGRectMake(0, 0, 100, 100);
                [imageView setTintColor:[UIColor whiteColor]];
                self.hud.customView = imageView;
                self.hud.labelText =
                    NSLocalizedString(@"Retweeted!", @"HUD done title");
              }];
  [controller addAction:retweet];
  [self presentViewController:controller animated:YES completion:nil];

  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger MAXLENGTH = 140 - userPlaceHolder.length;
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= MAXLENGTH || returnKey;
}

- (IBAction)editingChanged:(id)sender
{
    UITextField *textField = sender;
    
    UITextRange *textRange = textField.markedTextRange;
    
    if (!textRange.start || !textRange.end) {
        if (textField.text.length > 140) {
            textField.text = [textField.text substringToIndex:140];
        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView
    estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
  // minimum size of your cell, it should be single line of label if you are not
  // clear min. then return UITableViewAutomaticDimension;
  return UITableViewAutomaticDimension;
}
- (void)getTimeLine {
  ACAccountStore *account = [[ACAccountStore alloc] init];
  ACAccountType *accountType = [account
      accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

  [account
      requestAccessToAccountsWithType:accountType
                              options:nil
                           completion:^(BOOL granted, NSError *error) {
                             if (granted == YES) {
                               NSArray *arrayOfAccounts = [account
                                   accountsWithAccountType:accountType];

                               if ([arrayOfAccounts count] > 0) {
                                 NSLog(@"has account");

                                 ACAccount *twitterAccount =
                                     [arrayOfAccounts lastObject];

                                 NSURL *requestURL = [NSURL
                                     URLWithString:@"https://api.twitter.com/"
                                                   @"1.1/statuses/"
                                                   @"home_timeline.json"];

                                 NSDictionary *parameters = @{
                                   @"exclude_replies" : @"true",
                                   @"count" : @"20"
                                 };

                                 SLRequest *postRequest = [SLRequest
                                     requestForServiceType:SLServiceTypeTwitter
                                             requestMethod:SLRequestMethodGET
                                                       URL:requestURL
                                                parameters:parameters];

                                 postRequest.account = twitterAccount;

                                 [postRequest performRequestWithHandler:^(
                                                  NSData *responseData,
                                                  NSHTTPURLResponse
                                                      *urlResponse,
                                                  NSError *error) {
                                   self.dataSource = [NSJSONSerialization
                                       JSONObjectWithData:responseData
                                                  options:
                                                      NSJSONReadingMutableLeaves
                                                    error:&error];

                                   if (self.dataSource.count != 0) {
                                     dispatch_async(dispatch_get_main_queue(), ^{

                                       [self.tableView
                                             reloadSections:
                                                 [NSIndexSet
                                                     indexSetWithIndex:0]
                                           withRowAnimation:
                                               UITableViewRowAnimationAutomatic];
                                         self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                                       [self.refreshControl endRefreshing];
                                     });
                                   }else{
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                       UILabel *label = [[UILabel alloc]initWithFrame:self.view.frame];
                                       label.text = @"Error fetching data";
                                       label.textColor = [UIColor whiteColor];
                                       self.tableView.backgroundView = label;
                                       self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                                            });
                                   }
                                 }];
                               }
                             } else {
                               // Handle failure to get account access
                             }
                           }];
}

- (void)pageDidPresent {
  NSLog(@"pageDidPresent called!");
}
- (void)favoriteTweet:(NSString *)ident {
  ACAccountStore *account = [[ACAccountStore alloc] init];
  ACAccountType *accountType = [account
      accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

  [account
      requestAccessToAccountsWithType:accountType
                              options:nil
                           completion:^(BOOL granted, NSError *error) {
                             if (granted == YES) {
                               NSArray *arrayOfAccounts = [account
                                   accountsWithAccountType:accountType];

                               if ([arrayOfAccounts count] > 0) {
                                 NSLog(@"has account");
                                 NSLog(@"The darn id: %@", ident);
                                 ACAccount *twitterAccount =
                                     [arrayOfAccounts lastObject];

                                 NSURL *requestURL = [NSURL
                                     URLWithString:@"https://api.twitter.com/"
                                                   @"1.1/favorites/"
                                                   @"create.json"];
                                 NSString *idD =
                                     [NSString stringWithFormat:@"%@", ident];
                                 NSDictionary *parameters = @{ @"id" : idD };
                                 NSLog(@"The request %@", parameters);

                                 SLRequest *postRequest = [SLRequest
                                     requestForServiceType:SLServiceTypeTwitter
                                             requestMethod:SLRequestMethodPOST
                                                       URL:requestURL
                                                parameters:parameters];

                                 postRequest.account = twitterAccount;
                                 __block NSHTTPURLResponse *respyTheJinglePup =
                                     nil;
                                 [postRequest performRequestWithHandler:^(
                                                  NSData *responseData,
                                                  NSHTTPURLResponse
                                                      *urlResponse,
                                                  NSError *error) {
                                   NSLog(@"Twitter HTTP response: %li",
                                         (long)[urlResponse statusCode]);
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                     [self.hud hide:true afterDelay:1.0f];
                                     self.hud.removeFromSuperViewOnHide = true;
                                   });
                                   respyTheJinglePup = urlResponse;

                                 }];
                                 NSLog(@"Twitter HTTP response: %li",
                                       (long)[respyTheJinglePup statusCode]);
                               }
                             } else {
                               // Handle failure to get account access
                               NSLog(@"failure");
                             }
                           }];
}

- (void)reTweet:(NSString *)ident {
  ACAccountStore *account = [[ACAccountStore alloc] init];
  ACAccountType *accountType = [account
      accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

  [account
      requestAccessToAccountsWithType:accountType
                              options:nil
                           completion:^(BOOL granted, NSError *error) {
                             if (granted == YES) {
                               NSArray *arrayOfAccounts = [account
                                   accountsWithAccountType:accountType];

                               if ([arrayOfAccounts count] > 0) {
                                 NSLog(@"has account");
                                 NSLog(@"The darn id: %@", ident);
                                 ACAccount *twitterAccount =
                                     [arrayOfAccounts lastObject];
                                 NSString *idD =
                                     [NSString stringWithFormat:@"%@", ident];
                                 NSURL *requestURL = [NSURL
                                     URLWithString:[NSString
                                                       stringWithFormat:
                                                           @"https://"
                                                           @"api.twitter.com/"
                                                           @"1.1/statuses/"
                                                           @"retweet/%@.json",
                                                           idD]];

                                 SLRequest *postRequest = [SLRequest
                                     requestForServiceType:SLServiceTypeTwitter
                                             requestMethod:SLRequestMethodPOST
                                                       URL:requestURL
                                                parameters:nil];

                                 postRequest.account = twitterAccount;
                                 __block NSHTTPURLResponse *respyTheJinglePup =
                                     nil;
                                 [postRequest performRequestWithHandler:^(
                                                  NSData *responseData,
                                                  NSHTTPURLResponse
                                                      *urlResponse,
                                                  NSError *error) {
                                   NSLog(@"Twitter HTTP response: %li",
                                         (long)[urlResponse statusCode]);
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                     [self.hud hide:true afterDelay:1.0f];
                                     self.hud.removeFromSuperViewOnHide = true;
                                   });
                                   respyTheJinglePup = urlResponse;

                                 }];
                                 NSLog(@"Twitter HTTP response: %li",
                                       (long)[respyTheJinglePup statusCode]);
                               }
                             } else {
                               // Handle failure to get account access
                               NSLog(@"failure");
                             }
                           }];
}

- (void)reply:(NSDictionary *)fullTweet status:(NSString *)status{
  ACAccountStore *account = [[ACAccountStore alloc] init];
  ACAccountType *accountType = [account
      accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

  [account
      requestAccessToAccountsWithType:accountType
                              options:nil
                           completion:^(BOOL granted, NSError *error) {
                             if (granted == YES) {
                               NSArray *arrayOfAccounts = [account
                                   accountsWithAccountType:accountType];

                               if ([arrayOfAccounts count] > 0) {
                                 NSLog(@"has account");
                                 NSLog(@"The darn id: %@", fullTweet[@"id"]);
                                   NSDictionary *user = fullTweet[@"user"];
                                 ACAccount *twitterAccount =
                                     [arrayOfAccounts lastObject];
                                 NSString *includedStatusUsername = [NSString
                                     stringWithFormat:@"@%@ %@", user[@"screen_name"],
                                                      status];
                                 NSURL *requestURL = [NSURL
                                     URLWithString:@"https://api.twitter.com/"
                                                   @"1.1/statuses/"
                                                   @"update.json"];

                                 NSDictionary *parameters = @{
                                   @"status" : includedStatusUsername,
                                   @"in_reply_to_status_id" : fullTweet[@"id"]
                                 };
                                 NSLog(@"The request %@", parameters);

                                 SLRequest *postRequest = [SLRequest
                                     requestForServiceType:SLServiceTypeTwitter
                                             requestMethod:SLRequestMethodPOST
                                                       URL:requestURL
                                                parameters:parameters];

                                 postRequest.account = twitterAccount;
                                 __block NSHTTPURLResponse *respyTheJinglePup =
                                     nil;
                                 [postRequest performRequestWithHandler:^(
                                                  NSData *responseData,
                                                  NSHTTPURLResponse
                                                      *urlResponse,
                                                  NSError *error) {

                                   dispatch_async(dispatch_get_main_queue(), ^{
                                     [self.hud hide:true afterDelay:1.0f];
                                     self.hud.removeFromSuperViewOnHide = true;
                                   });
                                   respyTheJinglePup = urlResponse;

                                 }];
                                 NSLog(@"Twitter HTTP response: %li",
                                       (long)[respyTheJinglePup statusCode]);
                               }
                             } else {
                               // Handle failure to get account access
                               NSLog(@"failure");
                             }
                           }];
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewAutomaticDimension;
}
- (void)pageWillDismiss {
  NSLog(@"pageWillDismiss called!");
}

- (void)pageDidDismiss {
  NSLog(@"pageDidDismiss called!");
}

- (CGFloat)idleTimerInterval {
  return 60;
}

- (BOOL)isTimeEnabled {
  return 1;
}

- (CGFloat)backgroundAlpha {
  return 0.6;
}

- (NSInteger)priority {
  return 10;
}
@end
