#import "lockpages/LPPage-Protocol.h"
#import "MBProgressHUD.h"
#import "EventKit/EventKit.h"
@interface LockMinderViewController : UITableViewController <LPPage, UITextFieldDelegate>
@property (nonatomic, retain) UIView *ibView;
@property (strong, nonatomic) MBProgressHUD *hud;
// The database with calendar events and reminders
@property (strong, nonatomic) EKEventStore *eventStore;

// Indicates whether app has access to event store.
@property (nonatomic) BOOL isAccessToEventStoreGranted;

// The data source for the table view
@property (strong, nonatomic) NSMutableArray *todoItems;

@property (strong, nonatomic) EKCalendar *calendar;

@property (copy, nonatomic) NSArray *reminders;

@end

