#import "ViewController.h"
#import "Motor.h"

#define ACCENT [UIColor colorWithRed:0.2 green:1.0 blue:0.5 alpha:1.0]
#define BG [UIColor blackColor]
#define CELL [UIColor colorWithRed:0.05 green:0.07 blue:0.06 alpha:1.0]

#pragma mark - KeyVC
@interface KeyVC () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *campo;
@end

@implementation KeyVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BG;
    self.title = @"MiFilza";
    
    UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width-40, 40)];
    t.text = @" Introduce tu Key";
    t.textColor = ACCENT;
    t.font = [UIFont boldSystemFontOfSize:22];
    t.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:t];
    
    self.campo = [[UITextField alloc] initWithFrame:CGRectMake(30, 160, self.view.bounds.size.width-60, 44)];
    self.campo.placeholder = @"XXXX-XXXX-XXXX-XXXX";
    self.campo.backgroundColor = CELL;
    self.campo.textColor = [UIColor whiteColor];
    self.campo.layer.cornerRadius = 8;
    self.campo.textAlignment = NSTextAlignmentCenter;
    self.campo.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.campo.delegate = self;
    [self.view addSubview:self.campo];
    
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = CGRectMake(30, 220, self.view.bounds.size.width-60, 44);
    [b setTitle:@"ACTIVAR" forState:UIControlStateNormal];
    b.backgroundColor = ACCENT;
    b.layer.cornerRadius = 8;
    b.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [b setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [b addTarget:self action:@selector(activar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:b];
}

- (BOOL)textField:(UITextField *)tf shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *t = [tf.text stringByReplacingCharactersInRange:range withString:string];
    NSString *s = [[t componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
    s = [s uppercaseString];
    if (s.length > 16) s = [s substringToIndex:16];
    NSMutableString *f = [NSMutableString new];
    for (int i=0; i<s.length; i++) {
        if (i>0 && i%4==0) [f appendString:@"-"];
        [f appendFormat:@"%C", [s characterAtIndex:i]];
    }
    tf.text = f;
    return NO;
}

- (void)activar {
    if (self.campo.text.length < 4) {
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Mínimo 4 caracteres" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [a show];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"activado"];
    [[NSUserDefaults standardUserDefaults] setObject:self.campo.text forKey:@"keyActivada"];
    
    MainVC *main = [[MainVC alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:main animated:YES];
}
@end

#pragma mark - MainVC
@interface MainVC () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *bundleField;
@end

@implementation MainVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MiFilza";
    self.view.backgroundColor = BG;
    
    CGFloat w = self.view.bounds.size.width;
    
    UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, w-40, 30)];
    t.text = @"Bundle ID de la App";
    t.textColor = ACCENT;
    t.font = [UIFont boldSystemFontOfSize:18];
    t.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:t];
    
    self.bundleField = [[UITextField alloc] initWithFrame:CGRectMake(30, 130, w-60, 44)];
    self.bundleField.placeholder = @"com.ejemplo.app";
    self.bundleField.backgroundColor = CELL;
    self.bundleField.textColor = [UIColor whiteColor];
    self.bundleField.layer.cornerRadius = 8;
    self.bundleField.textAlignment = NSTextAlignmentCenter;
    self.bundleField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.bundleField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.bundleField.delegate = self;
    [self.view addSubview:self.bundleField];
    
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = CGRectMake(30, 190, w-60, 44);
    [b setTitle:@"ABRIR APP" forState:UIControlStateNormal];
    b.backgroundColor = ACCENT;
    b.layer.cornerRadius = 8;
    b.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [b setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [b addTarget:self action:@selector(abrirApp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:b];
    
    UIButton *logout = [UIButton buttonWithType:UIButtonTypeSystem];
    logout.frame = CGRectMake(30, 260, w-60, 44);
    [logout setTitle:@"Cerrar Sesión" forState:UIControlStateNormal];
    logout.backgroundColor = [UIColor redColor];
    logout.layer.cornerRadius = 8;
    [logout setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logout addTarget:self action:@selector(cerrarSesion) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logout];
}

- (BOOL)textFieldShouldReturn:(UITextField *)tf {
    [tf resignFirstResponder];
    [self abrirApp];
    return YES;
}

- (void)abrirApp {
    NSString *bid = [self.bundleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (bid.length == 0) {
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Escribe un Bundle ID" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [a show];
        return;
    }
    
    NSString *ruta = [Motor rutaDeApp:bid];
    if (ruta && ruta.length > 0) {
        FilesVC *f = [[FilesVC alloc] initWithStyle:UITableViewStylePlain];
        f.currentPath = ruta;
        f.title = bid;
        [self.navigationController pushViewController:f animated:YES];
    } else {
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"No encontrado" message:[NSString stringWithFormat:@"No se pudo obtener la ruta de:\n%@", bid] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [a show];
    }
}

- (void)cerrarSesion {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"activado"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"keyActivada"];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end

#pragma mark - FilesVC
@implementation FilesVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BG;
    self.tableView.backgroundColor = BG;
    self.tableView.separatorColor = [UIColor darkGrayColor];
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s {
    @try {
        NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.currentPath error:nil];
        return items ? items.count : 0;
    } @catch(...) { return 0; }
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip {
    UITableViewCell *c = [tv dequeueReusableCellWithIdentifier:@"f"];
    if (!c) c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"f"];
    c.backgroundColor = CELL;
    c.textLabel.textColor = [UIColor whiteColor];
    c.detailTextLabel.textColor = [UIColor grayColor];
    
    @try {
        NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.currentPath error:nil];
        if (items && ip.row < items.count) {
            NSString *name = items[ip.row];
            NSString *full = [self.currentPath stringByAppendingPathComponent:name];
            BOOL isDir = NO;
            [[NSFileManager defaultManager] fileExistsAtPath:full isDirectory:&isDir];
            c.textLabel.text = isDir ? [@" " stringByAppendingString:name] : [@"📄 " stringByAppendingString:name];
            c.detailTextLabel.text = isDir ? @"Carpeta" : @"Archivo";
        }
    } @catch(...) {}
    return c;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)ip {
    [tv deselectRowAtIndexPath:ip animated:YES];
    @try {
        NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.currentPath error:nil];
        if (items && ip.row < items.count) {
            NSString *name = items[ip.row];
            NSString *full = [self.currentPath stringByAppendingPathComponent:name];
            BOOL isDir = NO;
            [[NSFileManager defaultManager] fileExistsAtPath:full isDirectory:&isDir];
            if (isDir) {
                FilesVC *f = [[FilesVC alloc] initWithStyle:UITableViewStylePlain];
                f.currentPath = full;
                f.title = name;
                [self.navigationController pushViewController:f animated:YES];
            }
        }
    } @catch(...) {}
}
@end
