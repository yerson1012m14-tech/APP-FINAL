#import "ViewController.h"
#import <CommonCrypto/CommonCrypto.h>

static NSString *kMasterKey = @"MIFILZA-MASTER-2026";

@interface KeyVC () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *campo;
@property (nonatomic, strong) UIButton *boton;
@property (nonatomic, strong) UILabel *estado;
@property (nonatomic, strong) UILabel *titulo;
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
    
    self.titulo = [[UILabel alloc] initWithFrame:CGRectMake(0, y + 90, w, 40)];
    self.titulo.text = @"MiFilza";
    self.titulo.textAlignment = NSTextAlignmentCenter;
    self.titulo.textColor = [UIColor colorWithRed:0.2 green:1.0 blue:0.5 alpha:1.0];
    self.titulo.font = [UIFont fontWithName:@"Menlo-Bold" size:32];
    [self.view addSubview:self.titulo];
    
    UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(0, y + 135, w, 20)];
    sub.text = @"Introduce tu key de acceso";
    sub.textAlignment = NSTextAlignmentCenter;
    sub.textColor = [UIColor grayColor];
    sub.font = [UIFont fontWithName:@"Menlo" size:12];
    [self.view addSubview:sub];
    
    self.campo = [[UITextField alloc] initWithFrame:CGRectMake(40, y + 175, w - 80, 46)];
    self.campo.placeholder = @"KEY-XXXX-0000";
    self.campo.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1.0];
    self.campo.layer.cornerRadius = 10;
    self.campo.layer.borderWidth = 1;
    self.campo.layer.borderColor = [UIColor colorWithWhite:0.25 alpha:1.0].CGColor;
    self.campo.textColor = [UIColor whiteColor];
    self.campo.font = [UIFont fontWithName:@"Menlo" size:14];
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

- (BOOL)textFieldShouldReturn:(UITextField *)tf {
    [tf resignFirstResponder];
    [self activar];
    return YES;
}

- (void)activar {
    NSString *key = [self.campo.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!key.length) {
        self.estado.textColor = [UIColor redColor];
        self.estado.text = @"Escribe una key.";
        return;
    }
    
    if ([self validarKey:key]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"activado"];
        [[NSUserDefaults standardUserDefaults] setObject:key forKey:@"keyActivada"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KEY_ACTIVADA" object:nil];
    } else {
        self.estado.textColor = [UIColor redColor];
        self.estado.text = @"Key invalida.";
    }
}

- (BOOL)validarKey:(NSString *)key {
    if ([key isEqualToString:kMasterKey]) return YES;
    
    if (key.length < 10) return NO;
    
    NSArray *partes = [key componentsSeparatedByString:@"-"];
    if (partes.count != 3) return NO;
    
    NSString *hash = [self sha256:key];
    NSString *check = [hash substringToIndex:4];
    NSString *ultima = [partes lastObject];
    
    return [check isEqualToString:ultima];
}

- (NSString *)sha256:(NSString *)input {
    const char *str = [input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG)strlen(str), result);
    NSMutableString *hex = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hex appendFormat:@"%02x", result[i]];
    }
    return hex;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

@end
