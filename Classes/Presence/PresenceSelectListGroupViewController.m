//
//  PresenceSelectListGroupViewController.m
//  NethCTI
//
//  Created by Marco on 02/02/22.
//

#import "PresenceSelectListGroupViewController.h"

@interface PresenceSelectListGroupViewController ()

@end

@implementation PresenceSelectListGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)ibaChiudi:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
