#import "ViewController.h"
#import <CommonCrypto/CommonCrypto.h>

#pragma mark - KeyVC
@interface KeyVC () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *campo;
@property (nonatomic, strong) UIButton *boton;
@property (nonatomic, strong) UILabel *estado;
@end

@implementation KeyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat w = self.view.bounds.size.width;
    CGFloat y = 100;
    
    UIImageView *lock = [[UIImageView alloc] initWithImage:[[UIImage systemImageNamed:@"lock.shield.fill"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    lock.tintColor = [UIColor colorWithRed:0.2 green:1.0 blue:0.5 alpha:1.0];
    lock.frame = CGRectMake(0, y, w, 80);
    lock.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:lock];
    
    UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, y + 90, w, 40)];
    t.text = @"MiFilza";
    t.textAlignment = NSTextAlignmentCenter;
    t.textColor = [UIColor colorWithRed:0.2 green:1.0 blue:0.5 alpha:1.0];
    t.font = [UIFont fontWithName:@"Menlo-Bold" size:32];
    [self.view addSubview:t];
    
    UILabel *s = [[UILabel alloc] initWithFrame:CGRectMake(0, y + 135, w, 20)];
    s.text = @"Introduce tu key de acceso";
    s.textAlignment = NSTextAlignmentCenter;
    s.textColor = [UIColor grayColor];
    s.font = [UIFont fontWithName:@"Menlo" size:12];
    [self.view addSubview:s];
    
    self.campo = [[UITextField alloc] initWithFrame:CGRectMake(40, y + 175, w - 80, 46)];
    self.campo.placeholder = @"XXXX-XXXX-XXXX-XXXX";
    self.campo.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1.0];
    self.campo.layer.cornerRadius = 10;
    self.campo.layer.borderWidth = 1;
    self.campo.layer.borderColor = [UIColor colorWithWhite:0.25 alpha:1.0].CGColor;
    self.campo.textColor = [UIColor whiteColor];
    self.campo.font = [UIFont fontWithName:@"Menlo-Bold" size:16];
    self.campo.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.campo.autocorrectionType = UITextAutocorrectionTypeNo;
    self.campo.returnKeyType = UIReturnKeyGo;
    self.campo.delegate = self;
    self.campo.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.campo];
    
    self.boton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.boton.frame = CGRectMake(40, y + 235, w - 80, 46);
    [self.boton setTitle:@"ACTIVAR" forState:UIControlStateNormal];
    [self.boton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.boton.titleLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:16];
    self.boton.backgroundColor = [UIColor colorWithRed:0.2 green:1.0 blue:0.5 alpha:1.0];
    self.boton.layer.cornerRadius = 10;
    [self.boton addTarget:self action:@selector(activar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.boton];
    
    self.estado = [[UILabel alloc] initWithFrame:CGRectMake(40, y + 295, w - 80, 20)];
    self.estado.textAlignment = NSTextAlignmentCenter;
    self.estado.textColor = [UIColor redColor];
    self.estado.font = [UIFont fontWithName:@"Menlo" size:11];
    [self.view addSubview:self.estado];
}

- (BOOL)textField:(UITextField *)tf shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *texto = [tf.text stringByReplacingCharactersInRange:range withString:string];
    NSString *solo = [[texto componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
    solo = [solo uppercaseString];
    if (solo.length > 17) solo = [solo substringToIndex:17];
    
    NSMutableString *formateado = [NSMutableString new];
    for (int i = 0; i < solo.length; i++) {
        if (i > 0 && i % 4 == 0) [formateado appendString:@"-"];
        [formateado appendFormat:@"%C", [solo characterAtIndex:i]];
    }
    tf.text = formateado;
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)tf {
    [tf resignFirstResponder];
    [self activar];
    return YES;
}

- (void)activar {
    NSString *key = [self.campo.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (key.length < 4) {
        self.estado.textColor = [UIColor redColor];
        self.estado.text = @"Mínimo 4 caracteres.";
        return;
    }
    // ✅ TEMPORAL: Acepta cualquier key
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"activado"];
    [[NSUserDefaults standardUserDefaults] setObject:key forKey:@"keyActivada"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KEY_ACTIVADA" object:nil];
}

@end

#pragma mark - ViewController
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"MiFilza";
    
    UILabel *m = [[UILabel alloc] initWithFrame:CGRectMake(40, 200, self.view.bounds.size.width - 80, 60)];
    m.text = @"✅ Key activada";
    m.textAlignment = NSTextAlignmentCenter;
    m.textColor = [UIColor colorWithRed:0.2 green:1.0 blue:0.5 alpha:1.0];
    m.font = [UIFont fontWithName:@"Menlo-Bold" size:18];
    [self.view addSubview:m];
    
    UIButton *c = [UIButton buttonWithType:UIButtonTypeSystem];
    c.frame = CGRectMake(40, 300, self.view.bounds.size.width - 80, 46);
    [c setTitle:@"CERRAR SESIÓN" forState:UIControlStateNormal];
    [c setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    c.titleLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:14];
    c.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1.0];
    c.layer.cornerRadius = 10;
    [c addTarget:self action:@selector(cerrar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:c];
}

- (void)cerrar {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"activado"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"keyActivada"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KEY_ACTIVADA" object:nil];
}

@end
