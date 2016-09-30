//
//  ViewController.m
//  Range Slider
//
//  Created by Max on 27/9/16.
//  Copyright © 2016 Schneider Electric (Australia) Pty Ltd. All rights reserved.
//

#import "ViewController.h"
#import "SERangeSlider.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet SERangeSlider *rangeSlider;
@property (weak, nonatomic) IBOutlet UILabel *lowerLabel;
@property (weak, nonatomic) IBOutlet UILabel *upperLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self updateRangeValues];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rangeSliderValueChagned:(id)sender {

    [self updateRangeValues];
}

- (void)updateRangeValues {
    
    self.lowerLabel.text = [NSString stringWithFormat:@"Lower: %f", self.rangeSlider.lowerValue];
    self.upperLabel.text = [NSString stringWithFormat:@"Upper: %f", self.rangeSlider.upperValue];
}

@end
