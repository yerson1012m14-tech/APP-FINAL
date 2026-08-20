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
    t.text = @" Introduce tu Key"; t.textColor = ACCENT; t.font = [UIFont boldSystemFontOfSize:22]; t.textAlignment = 1;
    [self.view addSubview:t];
    
    self.campo = [[UITextField alloc] initWithFrame:CGRectMake(30, 160, self.view.bounds.size.width-60, 44)];
    self.campo.placeholder = @"XXXX-XXXX-XXXX-XXXX";
    self.campo.backgroundColor = CELL; self.campo.textColor = [UIColor whiteColor];
    self.campo.layer.cornerRadius = 8; self.campo.textAlignment = 1;
    self.campo.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.campo.delegate = self;
    [self.view addSubview:self.campo];
    
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = CGRectMake(30, 220, self.view.bounds.size.width-60, 44);
    [b setTitle:@"ACTIVAR" forState:UIControlStateNormal];
    b.backgroundColor = ACCENT; b.layer.cornerRadius = 8; b.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [b setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [b addTarget:self action:@selector(activar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:b];
}
- (BOOL)textField:(UITextField *)tf shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *t = [tf.text stringByReplacingCharactersInRange:range withString:string];
    NSString *s = [[t componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
    s = [s uppercaseString]; if (s.length > 16) s = [s substringToIndex:16];
    NSMutableString *f = [NSMutableString new];
    for (int i=0; i<s.length; i++) { if (i>0 && i%4==0) [f appendString:@"-"]; [f appendFormat:@"%C", [s characterAtIndex:i]]; }
    tf.text = f; return NO;
}
- (void)activar {
    if (self.campo.text.length < 4) { UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Mínimo 4 caracteres" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [a show]; return; }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"activado"];
    [[NSUserDefaults standardUserDefaults] setObject:self.campo.text forKey:@"keyActivada"];
    [self.navigationController pushViewController:[MainVC new] animated:YES];
}
@end

#pragma mark - MainVC
@implementation MainVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MiFilza"; self.view.backgroundColor = BG;
    self.tableView.backgroundColor = BG; self.tableView.separatorColor = [UIColor darkGrayColor];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv { return 3; }
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s {
    if (s==0) return 3; if (s==1) { @try { return [[Motor appsInstaladas] count]; } @catch(...) { return 0; } } return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip {
    UITableViewCell *c = [tv dequeueReusableCellWithIdentifier:@"c"];
    if (!c) c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"c"];
    c.backgroundColor = CELL; c.textLabel.textColor = [UIColor whiteColor]; c.detailTextLabel.textColor = [UIColor grayColor];
    if (ip.section==0) {
        NSArray *tit = @[@"Raíz del Sistema", @"Documentos", @"Preferencias"];
        NSArray *sub = @[@"/", @"/var/mobile/Documents", @"/var/mobile/Library/Preferences"];
        c.textLabel.text = tit[ip.row]; c.detailTextLabel.text = sub[ip.row];
    } else if (ip.section==1) {
        @try { c.textLabel.text = [[Motor appsInstaladas] objectAtIndex:ip.row]; c.detailTextLabel.text = @"Bundle ID"; } @catch(...) {}
    } else {
        NSArray *tit = @[@" HWID", @"⚙️ Ajustes", @"🛡️ Anti-Captura", @"🚪 Cerrar Sesión"];
        c.textLabel.text = tit[ip.row];
    }
    return c;
}
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)ip {
    [tv deselectRowAtIndexPath:ip animated:YES];
    if (ip.section==0) {
        NSArray *paths = @[@"/", @"/var/mobile/Documents", @"/var/mobile/Library/Preferences"];
        FilesVC *f = [FilesVC new]; f.currentPath = paths[ip.row]; f.title = [tv cellForRowAtIndexPath:ip].textLabel.text;
        [self.navigationController pushViewController:f animated:YES];
    } else if (ip.section==1) {
        @try {
            NSString *bid = [[Motor appsInstaladas] objectAtIndex:ip.row];
            NSString *ruta = [Motor rutaDeApp:bid];
            if (ruta) { FilesVC *f = [FilesVC new]; f.currentPath = ruta; f.title = bid; [self.navigationController pushViewController:f animated:YES]; }
            else { UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No se pudo obtener la ruta" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [a show]; }
        } @catch(...) {}
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
    self.view.backgroundColor = BG; self.tableView.backgroundColor = BG; self.tableView.separatorColor = [UIColor darkGrayColor];
}
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s {
    @try { return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.currentPath error:nil].count; } @catch(...) { return 0; }
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip {
    UITableViewCell *c = [tv dequeueReusableCellWithIdentifier:@"f"];
    if (!c) c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"f"];
    c.backgroundColor = CELL; c.textLabel.textColor = [UIColor whiteColor]; c.detailTextLabel.textColor = [UIColor grayColor];
    @try {
        NSString *name = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.currentPath error:nil][ip.row];
        NSString *full = [self.currentPath stringByAppendingPathComponent:name];
        BOOL isDir = NO; [[NSFileManager defaultManager] fileExistsAtPath:full isDirectory:&isDir];
        c.textLabel.text = isDir ? [@"📁 " stringByAppendingString:name] : [@"📄 " stringByAppendingString:name];
        c.detailTextLabel.text = isDir ? @"Carpeta" : @"Archivo";
    } @catch(...) {}
    return c;
}
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)ip {
    [tv deselectRowAtIndexPath:ip animated:YES];
    @try {
        NSString *name = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.currentPath error:nil][ip.row];
        NSString *full = [self.currentPath stringByAppendingPathComponent:name];
        BOOL isDir = NO; [[NSFileManager defaultManager] fileExistsAtPath:full isDirectory:&isDir];
        if (isDir) { FilesVC *f = [FilesVC new]; f.currentPath = full; f.title = name; [self.navigationController pushViewController:f animated:YES]; }
    } @catch(...) {}
}
@end
