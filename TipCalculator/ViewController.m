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
    self.adjustTipPercentage.value = 0;
}



-(void)calculate:(NSString*)tipAmountString totalBill:(NSString*)bill{
    NSDecimalNumber *billAmount = [[NSDecimalNumber alloc]initWithString:bill];
    
    if (!([tipAmountString isEqualToString:@""])) {
        float tip = [bill floatValue] * ([tipAmountString floatValue]/100);
        self.tipAmount = [[NSDecimalNumber alloc]initWithFloat:tip];
    }
    else if (self.adjustTipPercentage.value){
        float tip = [billAmount floatValue] * (self.adjustTipPercentage.value/100);
        self.tipAmount = [[NSDecimalNumber alloc]initWithFloat:tip];
    }
    else{
        float defaultTip = [billAmount floatValue] *0.15;
        self.tipAmount = [[NSDecimalNumber alloc]initWithFloat:defaultTip];
    }
    
    
}

#pragma mark - Interface Controls
- (IBAction)calculateTip:(id)sender {
    [self calculate:@"" totalBill:@""];
}

- (IBAction)adjustSlider:(id)sender {
    self.sliderTip.text = [NSString stringWithFormat:@"%2.0f", self.adjustTipPercentage.value];
    [self calculate:@"" totalBill:self.billAmountTextField.text];
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc]init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    self.tipAmountLabel.text = [NSString stringWithFormat:@"Tip: %@", [currencyFormatter stringFromNumber:self.tipAmount]];
}

#pragma mark - Utility methods

- (IBAction)resignFirstResponder:(id)sender {
    [self.billAmountTextField resignFirstResponder];
    [self.tipPercentageField resignFirstResponder];
}

#pragma mark - KeyBoard Related
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


#pragma mark - TextField Delegate Methods

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([self.tipPercentageField isFirstResponder]) {
        NSString *tipTextFieldText = self.tipPercentageField.text;
        BOOL isDeleting = range.length == 1;
        if (isDeleting) {
            tipTextFieldText = [tipTextFieldText substringToIndex:range.location];
        }
        else{
            tipTextFieldText = [self.tipPercentageField.text stringByAppendingString:string];
        }
        [self calculate:tipTextFieldText totalBill:self.billAmountTextField.text];
        self.tipAmountLabel.text = @"";
        
        NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc]init];
        [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        self.tipAmountLabel.text = [NSString stringWithFormat:@"Tip: %@", [currencyFormatter stringFromNumber:self.tipAmount]];
    }
    
    else if ([self.billAmountTextField isFirstResponder]){
        NSString *billTextFieldText = self.billAmountTextField.text;
        BOOL isDeleting = range.length == 1;
        if (isDeleting) {
            billTextFieldText = [billTextFieldText substringToIndex:range.location];
        }
        else{
            billTextFieldText = [self.billAmountTextField.text stringByAppendingString:string];
        }
        [self calculate:self.tipPercentageField.text totalBill:billTextFieldText];
        
        NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc]init];
        [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        self.tipAmountLabel.text = [NSString stringWithFormat:@"Tip: %@", [currencyFormatter stringFromNumber:self.tipAmount]];
        
    }
    return YES;
}



@end
