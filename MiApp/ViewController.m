#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"MiFilza";
    
    UILabel *mensaje = [[UILabel alloc] initWithFrame:CGRectMake(40, 200, self.view.bounds.size.width - 80, 60)];
    mensaje.text = @"✅ Key activada correctamente";
    mensaje.textAlignment = NSTextAlignmentCenter;
    mensaje.textColor = [UIColor colorWithRed:0.2 green:1.0 blue:0.5 alpha:1.0];
    mensaje.font = [UIFont fontWithName:@"Menlo-Bold" size:18];
    mensaje.numberOfLines = 0;
    [self.view addSubview:mensaje];
    
    NSString *key = [[NSUserDefaults standardUserDefaults] stringForKey:@"keyActivada"];
    UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 280, self.view.bounds.size.width - 80, 40)];
    keyLabel.text = [NSString stringWithFormat:@"Key: %@", key ?: @"N/A"];
    keyLabel.textAlignment = NSTextAlignmentCenter;
    keyLabel.textColor = [UIColor grayColor];
    keyLabel.font = [UIFont fontWithName:@"Menlo" size:12];
    [self.view addSubview:keyLabel];
    
    UIButton *cerrar = [UIButton buttonWithType:UIButtonTypeSystem];
    cerrar.frame = CGRectMake(40, 350, self.view.bounds.size.width - 80, 46);
    [cerrar setTitle:@"CERRAR SESIÓN" forState:UIControlStateNormal];
    [cerrar setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    cerrar.titleLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:14];
    cerrar.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1.0];
    cerrar.layer.cornerRadius = 10;
    [cerrar addTarget:self action:@selector(cerrarSesion) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cerrar];
}

- (void)cerrarSesion {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"activado"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"keyActivada"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KEY_ACTIVADA" object:nil];
}

@end
