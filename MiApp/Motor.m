#import "Motor.h"
#import <dlfcn.h>

@implementation Motor

+ (void)encender {
    static BOOL on = NO;
    if (on) return;
    on = YES;
    void (*tweakInit)(void) = dlsym(RTLD_DEFAULT, "TweakInit");
    int (*start)(void) = dlsym(RTLD_DEFAULT, "MCMFilzaStart");
    void (*setUnres)(int) = dlsym(RTLD_DEFAULT, "MCMFilzaSetUnrestrictedFilesystem");
    if (tweakInit) tweakInit();
    if (start) start();
    if (setUnres) setUnres(1);
}

+ (NSString *)rutaDeApp:(NSString *)bundleId {
    [self encender];
    NSString *(*dataPath)(NSString *) = dlsym(RTLD_DEFAULT, "MCMFilzaDataContainerPath");
    if (!dataPath) return nil;
    NSString *p = nil;
    @try { p = dataPath(bundleId); } @catch (NSException *e) { p = nil; }
    return p;
}

+ (NSArray *)appsInstaladas {
    NSMutableArray *out = [NSMutableArray new];
    @try {
        Class ws = NSClassFromString(@"LSApplicationWorkspace");
        if (ws) {
            id space = [ws performSelector:@selector(defaultWorkspace)];
            NSArray *apps = [space performSelector:@selector(allApplications)];
            for (id app in apps) {
                NSString *bid = [app performSelector:@selector(applicationIdentifier)];
                if (bid) [out addObject:bid];
            }
        }
    } @catch (NSException *e) {}
    return [out sortedArrayUsingSelector:@selector(compare:)];
}

@end
