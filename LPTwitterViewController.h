
#import "lockpages/LPPage-Protocol.h"
#import "TweetCell.h"
@interface LPTwitterViewController : UITableViewController <LPPage>
@property (nonatomic, retain) UIView *ibView;
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) TweetCell *tweetCell;
@end

