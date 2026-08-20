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
@interface MainVC ()
@property (nonatomic, strong) NSArray *appsCache;
@property (nonatomic, assign) BOOL appsLoaded;
@end

@implementation MainVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MiFilza";
    self.view.backgroundColor = BG;
    self.tableView.backgroundColor = BG;
    self.tableView.separatorColor = [UIColor darkGrayColor];
    self.appsCache = @[];
    self.appsLoaded = NO;
    
    // Botón para cargar apps manualmente (NO automático)
    UIBarButtonItem *loadBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cargar Apps" style:UIBarButtonItemStylePlain target:self action:@selector(cargarApps)];
    loadBtn.tintColor = ACCENT;
    self.navigationItem.rightBarButtonItem = loadBtn;
}

- (void)cargarApps {
    // Solo se ejecuta cuando TÚ lo pides
    self.appsCache = [Motor appsInstaladas];
    if (!self.appsCache) self.appsCache = @[];
    self.appsLoaded = YES;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv { return 3; }

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s {
    if (s==0) return 3;
    if (s==1) return self.appsLoaded ? self.appsCache.count : 1;
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip {
    UITableViewCell *c = [tv dequeueReusableCellWithIdentifier:@"c"];
    if (!c) c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"c"];
    c.backgroundColor = CELL;
    c.textLabel.textColor = [UIColor whiteColor];
    c.detailTextLabel.textColor = [UIColor grayColor];
    
    if (ip.section==0) {
        NSArray *tit = @[@"🛸 Raíz del Sistema", @"📂 Documentos", @"️ Preferencias"];
        NSArray *sub = @[@"/", @"/var/mobile/Documents", @"/var/mobile/Library/Preferences"];
        c.textLabel.text = tit[ip.row];
        c.detailTextLabel.text = sub[ip.row];
    } else if (ip.section==1) {
        if (!self.appsLoaded) {
            c.textLabel.text = @"Toca 'Cargar Apps' arriba";
            c.detailTextLabel.text = @"para ver la lista";
        } else if (self.appsCache.count == 0) {
            c.textLabel.text = @"Sin apps (Sandbox activo)";
            c.detailTextLabel.text = @"El motor no está inyectado";
        } else {
            c.textLabel.text = self.appsCache[ip.row];
            c.detailTextLabel.text = @"Bundle ID";
        }
    } else {
        NSArray *tit = @[@"📱 HWID", @"⚙️ Ajustes", @"🛡️ Anti-Captura", @" Cerrar Sesión"];
        c.textLabel.text = tit[ip.row];
        if (ip.row == 3) c.textLabel.textColor = [UIColor redColor];
    }
    return c;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)ip {
    [tv deselectRowAtIndexPath:ip animated:YES];
    if (ip.section==0) {
        NSArray *paths = @[@"/", @"/var/mobile/Documents", @"/var/mobile/Library/Preferences"];
        FilesVC *f = [[FilesVC alloc] initWithStyle:UITableViewStylePlain];
        f.currentPath = paths[ip.row];
        f.title = [tv cellForRowAtIndexPath:ip].textLabel.text;
        [self.navigationController pushViewController:f animated:YES];
    } else if (ip.section==1 && self.appsLoaded && ip.row < self.appsCache.count) {
        NSString *bid = self.appsCache[ip.row];
        NSString *ruta = [Motor rutaDeApp:bid];
        if (ruta && ruta.length > 0) {
            FilesVC *f = [[FilesVC alloc] initWithStyle:UITableViewStylePlain];
            f.currentPath = ruta;
            f.title = bid;
            [self.navigationController pushViewController:f animated:YES];
        } else {
            UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Aviso" message:@"Ruta no disponible" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [a show];
        }
    } else if (ip.section==2 && ip.row==3) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"activado"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
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
            c.textLabel.text = isDir ? [@"📁 " stringByAppendingString:name] : [@"📄 " stringByAppendingString:name];
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
