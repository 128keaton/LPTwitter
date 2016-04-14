#import <lockpages/LPPage-Protocol.h>
#import <lockpages/LPPageController.h>
#import "LPTwitterViewController.h"

%ctor {
	LPTwitterViewController *_examplePage = [[LPTwitterViewController alloc] init];
	[[LPPageController sharedInstance] addPage:_examplePage];
}