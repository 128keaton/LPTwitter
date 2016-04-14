
#import "lockpages/LPPage-Protocol.h"
#import "MBProgressHUD.h"
@interface LPTwitterViewController : UITableViewController <LPPage, UITextFieldDelegate>
@property (nonatomic, retain) UIView *ibView;
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSString *username;
@end

