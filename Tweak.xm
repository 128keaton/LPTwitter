#import <lockpages/LPPage-Protocol.h>
#import <lockpages/LPPageController.h>
#import "LockMinderViewController.h"

%ctor {
	LockMinderViewController *_examplePage = [[LockMinderViewController alloc] init];
	[[LPPageController sharedInstance] addPage:_examplePage];
}