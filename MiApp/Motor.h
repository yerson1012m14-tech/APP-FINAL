#import <Foundation/Foundation.h>

@interface Motor : NSObject
+ (void)encender;
+ (NSString *)rutaDeApp:(NSString *)bundleId;
+ (NSArray *)appsInstaladas;
@end
