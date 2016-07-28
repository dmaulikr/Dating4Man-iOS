//
//  KKViewController.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"
#import "UIColor+RGB.h"

@interface KKViewController ()

@end

@implementation KKViewController
- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        [self initCustomParam];
    }
    
    return self;
}

- (void)dealloc {
    [self unInitCustomParam];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    NSString *nibNameOrNilReal = nibNameOrNil;
    
    BOOL bSupportiPad = NO;
    /*  应用是否支持iPad
     *  1:iPhone or iTouch
     *  2:iPad
     */
    NSArray *array = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIDeviceFamily"];
    for(NSNumber *deviceFamily in array) {
        if([deviceFamily integerValue] == 2) {
            bSupportiPad = YES;
            break;
        }
    }
    

    if(bSupportiPad) {
        // 应用支持iPad
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            // iPhone
        }
        else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // iPad
            if(nil == nibNameOrNil || nibNameOrNil.length == 0) {
                nibNameOrNil = NSStringFromClass([self class]);
            }
            nibNameOrNilReal = [NSString stringWithFormat:@"%@-iPad", nibNameOrNil];
        }
    }
    
    self = [super initWithNibName:nibNameOrNilReal bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initCustomParam];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initCustomParam];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated {
    if( !self.viewDidAppearEver ) {
        [UIView setAnimationsEnabled:YES];
        [self setupNavigationBar];
        [self setupContainView];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewDidAppearEver = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 横屏切换
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    //return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark － 界面布局
- (NSString *)backTitle {
    return self.navigationItem.backBarButtonItem.title;
}

- (void)setBackTitle:(NSString *)backTitle {
    UINavigationItem *item = self.navigationItem;
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithTitle:backTitle style:UIBarButtonItemStyleBordered target:self action:@selector(backAction:)];
    item.backBarButtonItem = barButtonItem;
}

- (void)initCustomParam {
    self.backTitle = NSLocalizedString(@"Back", nil);
}

- (void)unInitCustomParam {
    
}

- (void)setupNavigationBar {
    
}

- (void)setupContainView {

}

- (void)backAction:(id)sender {
}
@end
