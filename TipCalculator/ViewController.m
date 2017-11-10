//
//  ViewController.m
//  TipCalculator
//
//  Created by Javier Xing on 2017-11-10.
//  Copyright © 2017 Javier Xing. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *billAmountTextField;
@property (weak, nonatomic) IBOutlet UILabel *tipAmountLabel;
@property (weak, nonatomic) IBOutlet UITextField *tipPercentageField;
@property (nonatomic, strong) NSDecimalNumber *tipAmount;
@property (weak, nonatomic) IBOutlet UISlider *adjustTipPercentage;
@property (weak, nonatomic) IBOutlet UILabel *sliderTip;
@property (nonatomic, strong) NSString* calculationValue;

@end

@implementation ViewController

- (void)viewDidLoad {
    self.billAmountTextField.delegate = self;
    self.tipPercentageField.delegate = self;
}


-(void)calculate:(NSString*)tipAmountString{
    NSDecimalNumber *bill = [[NSDecimalNumber alloc]initWithString:self.billAmountTextField.text];
    
    if (![self.tipPercentageField.text isEqualToString:@""]) {
        float tip = [bill floatValue] * ([tipAmountString floatValue]/100);
        self.tipAmount = [[NSDecimalNumber alloc]initWithFloat:tip];
    }
    else if (!(self.adjustTipPercentage.value == 0)){
        float tip = [bill floatValue] * (self.adjustTipPercentage.value/100);
        self.tipAmount = [[NSDecimalNumber alloc]initWithFloat:tip];
    }
    else{
        float defaultTip = [bill floatValue] *0.15;
        self.tipAmount = [[NSDecimalNumber alloc]initWithFloat:defaultTip];
    }
    
    
}

- (IBAction)calculateTip:(id)sender {
    [self calculate:@""];
    
}

- (IBAction)resignFirstResponder:(id)sender {
    [self.billAmountTextField resignFirstResponder];
    [self.tipPercentageField resignFirstResponder];
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    return YES;
}

-(void)keyBoardDidShow:(NSNotification*)notification{
    CGSize keyBoardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect newBounds = CGRectMake(self.view.bounds.origin.x, keyBoardSize.height, self.view.bounds.size.width, self.view.bounds.size.height);
                         self.view.bounds = newBounds;
                     }];
}

-(void)keyBoardDidHide:(NSNotification*)notification{
    [UIView animateWithDuration:0.5
                     animations:^{
                      self.view.bounds = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height);
                     }];
}
- (IBAction)adjustSlider:(id)sender {
        self.sliderTip.text = [NSString stringWithFormat:@"%2.0f", self.adjustTipPercentage.value];
    [self calculate:@""];
}


#pragma mark - TextField Delegate Methods

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *tipTextFieldText = self.tipPercentageField.text;
    BOOL isDeleting = range.length == 1;
    if (isDeleting) {
        tipTextFieldText = [tipTextFieldText substringToIndex:range.location];
    }
    else{
    tipTextFieldText = [self.tipPercentageField.text stringByAppendingString:string];
    }
        [self calculate:tipTextFieldText];
        self.tipAmountLabel.text = @"";
    
        NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc]init];
        [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        self.tipAmountLabel.text = [NSString stringWithFormat:@"Tip: %@", [currencyFormatter stringFromNumber:self.tipAmount]];
    return YES;
}

//-(void)




@end
