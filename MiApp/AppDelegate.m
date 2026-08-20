#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIColor *acento = [UIColor colorWithRed:0.2 green:1.0 blue:0.5 alpha:1.0];
    
    UINavigationBarAppearance *ap = [[UINavigationBarAppearance alloc] init];
    [ap configureWithOpaqueBackground];
    ap.backgroundColor = [UIColor blackColor];
    ap.shadowColor = [UIColor colorWithWhite:0.25 alpha:1.0];
    ap.titleTextAttributes = @{
        NSForegroundColorAttributeName: acento,
        NSFontAttributeName: [UIFont fontWithName:@"Menlo-Bold" size:17]
    };
    [[UINavigationBar appearance] setStandardAppearance:ap];
    [[UINavigationBar appearance] setScrollEdgeAppearance:ap];
    [[UINavigationBar appearance] setTintColor:acento];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self mostrarRaiz];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mostrarRaiz) name:@"KEY_ACTIVADA" object:nil];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)mostrarRaiz {
    BOOL activado = [[NSUserDefaults standardUserDefaults] boolForKey:@"activado"];
    UIViewController *root = activado ? (UIViewController *)[ViewController new] : (UIViewController *)[KeyVC new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:root];
    nav.navigationBarHidden = !activado;
    self.window.rootViewController = nav;
}

@end
