
#import "lockpages/LPPage-Protocol.h"

@interface LPTwitterViewController : UITableViewController <LPPage>
@property (nonatomic, retain) UIView *ibView;
@property (strong, nonatomic) NSArray *dataSource;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

