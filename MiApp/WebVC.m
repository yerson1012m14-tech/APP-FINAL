#import "WebVC.h"
#import "Motor.h"
#import <WebKit/WebKit.h>

@interface WebVC () <WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *web;
@end

@implementation WebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    WKWebViewConfiguration *cfg = [WKWebViewConfiguration new];
    WKUserContentController *uc = cfg.userContentController;
    [uc addScriptMessageHandler:self name:@"motor"];
    
    self.web = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:cfg];
    self.web.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.web.backgroundColor = [UIColor blackColor];
    self.web.opaque = NO;
    [self.view addSubview:self.web];
    
    NSString *ruta = [[NSBundle mainBundle] pathForResource:@"ui" ofType:@"html"];
    if (ruta) {
        NSURL *url = [NSURL fileURLWithPath:ruta];
        NSURL *base = [url URLByDeletingLastPathComponent];
        [self.web loadFileURL:url allowingReadAccessToURL:base];
    } else {
        [self.web loadHTMLString:@"<h1 style='color:#22ff88'>Falta ui.html</h1>" baseURL:nil];
    }
}

- (void)userContentController:(WKUserContentController *)u didReceiveScriptMessage:(WKScriptMessage *)m {
    if (![m.name isEqualToString:@"motor"]) return;
    
    NSDictionary *msg = m.body;
    NSString *accion = msg[@"accion"] ?: @"";
    NSString *param = msg[@"param"] ?: @"";
    NSDictionary *resp = @{@"tipo": @"ok"};
    
    @try {
        if ([accion isEqualToString:@"apps"]) {
            NSArray *apps = [Motor appsInstaladas];
            resp = @{@"tipo": @"apps", @"datos": apps ?: @[]};
        }
        else if ([accion isEqualToString:@"ruta"]) {
            NSString *p = [Motor rutaDeApp:param];
            resp = @{@"tipo": @"ruta", @"datos": p ?: @"", @"app": param};
        }
        else if ([accion isEqualToString:@"listar"]) {
            resp = @{@"tipo": @"listar", @"datos": [self listar:param]};
        }
        else if ([accion isEqualToString:@"leer"]) {
            resp = @{@"tipo": @"leer", @"datos": [self leer:param]};
        }
        else if ([accion isEqualToString:@"estado"]) {
            [Motor encender];
            resp = @{@"tipo": @"estado", @"motor": @"ACTIVO"};
        }
        else if ([accion isEqualToString:@"cerrarSesion"]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"activado"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KEY_ACTIVADA" object:nil];
        }
    } @catch (NSException *e) {
        resp = @{@"tipo": @"error", @"msg": @"Motor no disponible"};
    }
    
    NSData *d = [NSJSONSerialization dataWithJSONObject:resp options:0 error:nil];
    NSString *json = d ? [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding] : @"{}";
    NSString *js = [NSString stringWithFormat:@"recibir(%@)", json];
    [self.web evaluateJavaScript:js completionHandler:nil];
}

- (NSArray *)listar:(NSString *)ruta {
    NSMutableArray *out = [NSMutableArray new];
    @try {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *all = [fm contentsOfDirectoryAtPath:ruta error:nil];
        for (NSString *n in [all sortedArrayUsingSelector:@selector(localizedStandardCompare:)]) {
            NSString *full = [ruta stringByAppendingPathComponent:n];
            BOOL isDir = NO;
            [fm fileExistsAtPath:full isDirectory:&isDir];
            unsigned long long size = 0;
            if (!isDir) size = [[fm attributesOfItemAtPath:full error:nil] fileSize];
            [out addObject:@{@"nombre": n, @"esDir": @(isDir), @"size": @(size)}];
        }
    } @catch (NSException *e) {}
    return out;
}

- (NSString *)leer:(NSString *)ruta {
    @try {
        unsigned long long size = [[NSFileManager defaultManager] attributesOfItemAtPath:ruta error:nil].fileSize;
        if (size > 2 * 1024 * 1024) return [NSString stringWithFormat:@"(demasiado grande: %llu bytes)", size];
        NSData *d = [NSData dataWithContentsOfFile:ruta];
        NSString *s = d ? [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding] : nil;
        return s ?: [NSString stringWithFormat:@"(binario: %llu bytes)", size];
    } @catch (NSException *e) {
        return @"(no se pudo leer)";
    }
}

@end
