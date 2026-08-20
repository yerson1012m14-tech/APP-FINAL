#import <UIKit/UIKit.h>

@interface KeyVC : UIViewController
@end

@interface MainVC : UITableViewController
@end

@interface FilesVC : UITableViewController
@property (nonatomic, strong) NSString *currentPath;
@end
