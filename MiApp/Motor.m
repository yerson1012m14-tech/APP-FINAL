#import "Motor.h"
#import <dlfcn.h>

@implementation Motor

+ (void)encender {
    @try {
        static BOOL on = NO;
        if (on) return;
        on = YES;
        void (*tweakInit)(void) = dlsym(RTLD_DEFAULT, "TweakInit");
        int (*start)(void) = dlsym(RTLD_DEFAULT, "MCMFilzaStart");
        void (*setUnres)(int) = dlsym(RTLD_DEFAULT, "MCMFilzaSetUnrestrictedFilesystem");
        if (tweakInit) tweakInit();
        if (start) start();
        if (setUnres) setUnres(1);
    } @catch (NSException *e) {}
}

+ (NSString *)rutaDeApp:(NSString *)bundleId {
    [self encender];
    @try {
        Class ws = NSClassFromString(@"LSApplicationWorkspace");
        if (ws) {
            id space = [ws performSelector:@selector(defaultWorkspace)];
            NSArray *apps = [space performSelector:@selector(allApplications)];
            for (id app in apps) {
                NSString *bid = [app performSelector:@selector(applicationIdentifier)];
                if ([bid isEqualToString:bundleId]) {
                    NSURL *url = [app performSelector:@selector(containerURL)];
                    if (url) return [url path]; //  ARREGLO: Convertir NSURL a NSString
                }
            }
        }
    } @catch (NSException *e) {}
    return nil;
}

+ (NSArray *)appsInstaladas {
    [self encender];
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
