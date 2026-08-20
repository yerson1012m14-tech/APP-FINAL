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
    [cfg.userContentController addScriptMessageHandler:self name:@"motor"];
    
    self.web = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:cfg];
    self.web.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.web.backgroundColor = [UIColor blackColor];
    self.web.opaque = NO;
    [self.view addSubview:self.web];
    
    NSString *ruta = [[NSBundle mainBundle] pathForResource:@"ui" ofType:@"html"];
    [self.web loadFileURL:[NSURL fileURLWithPath:ruta]
  allowingReadAccessToURL:[NSURL fileURLWithPath:[ruta stringByDeletingLastPathComponent]]];
}

- (void)userContentController:(WKUserContentController *)u didReceiveScriptMessage:(WKScriptMessage *)m {
    if (![m.name isEqualToString:@"motor"]) return;
    NSDictionary *msg = m.body;
    NSString *accion = msg[@"accion"];
    NSString *param = msg[@"param"];
    NSDictionary *resp = @{@"tipo": @"ok"};
    
    if ([accion isEqualToString:@"apps"]) {
        resp = @{@"tipo": @"apps", @"datos": [Motor appsInstaladas]};
    }
    else if ([accion isEqualToString:@"ruta"]) {
        NSString *p = [Motor rutaDeApp:param];
        resp = @{@"tipo": @"ruta", @"datos": p ?: [NSNull null], @"app": param};
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
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"keyActivada"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KEY_ACTIVADA" object:nil];
    }
    
    NSData *d = [NSJSONSerialization dataWithJSONObject:resp options:0 error:nil];
    NSString *json = d ? [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding] : @"{}";
    [self.web evaluateJavaScript:[NSString stringWithFormat:@"recibir(%@)", json] completionHandler:nil];
}

- (NSArray *)listar:(NSString *)ruta {
    NSMutableArray *out = [NSMutableArray new];
    NSArray *all = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:ruta error:nil];
    for (NSString *n in [all sortedArrayUsingSelector:@selector(localizedStandardCompare:)]) {
        NSString *full = [ruta stringByAppendingPathComponent:n];
        BOOL isDir = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:full isDirectory:&isDir];
        unsigned long long size = 0;
        if (!isDir) size = [[[NSFileManager defaultManager] attributesOfItemAtPath:full error:nil] fileSize];
        [out addObject:@{@"nombre": n, @"esDir": @(isDir), @"size": @(size)}];
    }
    return out;
}

- (NSString *)leer:(NSString *)ruta {
    unsigned long long size = [[[NSFileManager defaultManager] attributesOfItemAtPath:ruta error:nil] fileSize];
    if (size > 2 * 1024 * 1024) return [NSString stringWithFormat:@"(demasiado grande: %llu bytes)", size];
    NSData *d = [NSData dataWithContentsOfFile:ruta];
    NSString *s = d ? [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding] : nil;
    return s ?: [NSString stringWithFormat:@"(binario: %llu bytes)", size];
}

@end
