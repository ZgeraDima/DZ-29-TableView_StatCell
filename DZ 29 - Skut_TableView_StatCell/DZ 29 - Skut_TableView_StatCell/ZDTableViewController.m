//
//  ZDTableViewController.m
//  DZ 29 - Skut_TableView_StatCell
//
//  Created by mac on 31.12.17.
//  Copyright © 2017 Dima Zgera. All rights reserved.
//

#import "ZDTableViewController.h"

@interface ZDTableViewController ()

@end

// TextFields Keys

static NSString *kFirstName =       @"kFirstName";
static NSString *kLastName =        @"kLastName";
static NSString *kUserName =        @"kUserName";
static NSString *kPassword =        @"kPassword";
static NSString *kAge =             @"kAge";
static NSString *kEmail =           @"kEmail";
static NSString *kPhoneNumber =     @"kPhoneNumber";

// Subscription info Keys

static NSString *kSubscribe =       @"kSubscribe";
static NSString *kReceiveNews =     @"kReceiveNews";
static NSString *kNewsPerDay =      @"kNewsPerDay";
static NSString *kNewsCountLabel =  @"kNewsCountLabel";

@implementation ZDTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UITextField *field in self.allFields) {
        field.delegate = self;
    }
    self.atSymbolIsPossible = YES;
    [self loadValues];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)actionClearAllButton:(UIButton *)sender {
    
    for (UITextField *field in self.allFields) {
        field.text = @"";
    }
    
    for (UILabel *label in self.allLabels) {
        label.text = @"";
    }
    
}

- (IBAction)actionEditingChanged:(UITextField *)sender {
    
    UILabel *label = [self.allLabels objectAtIndex:[self.allFields indexOfObject:sender]];
    label.text = sender.text;
    [self saveValues];
}

- (IBAction)actionValueChanged:(id)sender {
    
    if ([sender isEqual:self.newsPerDaySlider]) {
        
        self.newsCountLabel.text = [NSString stringWithFormat:@"%1.0f", ((UISlider*)sender).value];
    }
    
    [self saveValues];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL changeOrNo = YES;
    
    if (textField.tag == ZDTextFieldPhoneNumber) {
        
        changeOrNo = [self checkPhoneNumber:textField shouldChangeCharactersInRange:range replacementString:string];
        
    } else if (textField.tag == ZDTextFieldAge) {
        
        changeOrNo = [self checkAge:textField shouldChangeCharactersInRange:range replacementString:string];
        
    } else if (textField.tag == ZDTextFieldEmail) {
        
        changeOrNo = [self checkEmail:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    
    return changeOrNo;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSInteger currentFieldIndex = [self.allFields indexOfObject:textField];
    NSInteger lastFieldIndex = [self.allFields indexOfObject:[self.allFields lastObject]];
    
    if (currentFieldIndex != lastFieldIndex) {
        UITextField *nextField = [self.allFields objectAtIndex:++currentFieldIndex];
        [nextField becomeFirstResponder];
    } else {
        UITextField *lastField = [self.allFields lastObject];
        [lastField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL) textFieldShouldClear:(UITextField *)textField {
    
    if (textField.tag == ZDTextFieldEmail) {
        self.atSymbolIsPossible = YES;
    }
    [self saveValues];
    return YES;
}

#pragma mark - Methods for Changing Characters in Range

- (BOOL) checkPhoneNumber:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
    
    NSCharacterSet *validationSet = [[NSCharacterSet decimalDigitCharacterSet]invertedSet];
    NSArray *components = [string componentsSeparatedByCharactersInSet:validationSet];
    
    if ([components count] > 1) {
        return NO;
    }
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSLog(@"newString = %@", newString);
    
    NSArray *validComponents = [newString componentsSeparatedByCharactersInSet:validationSet];
    newString = [validComponents componentsJoinedByString:@""];
    
    static const int localNumberMaxLength = 7;
    static const int areaCodeMaxLength = 3;
    static const int countryCodeMaxLength = 3;
    
    if ([newString length] > localNumberMaxLength + areaCodeMaxLength + countryCodeMaxLength) {
        return NO;
    }
    
    NSMutableString *resultString = [NSMutableString string];
    
    NSInteger localNumberLength = MIN([newString length], localNumberMaxLength);
    
    if (localNumberLength > 0) {
        
        NSString *localNumber = [newString substringFromIndex:[newString length] - localNumberLength];
        
        [resultString appendString:localNumber];
        if ([resultString length] > 3) {
            [resultString insertString:@"-" atIndex:3];
        }
    }
    
    if ([newString length] > localNumberMaxLength) {
        
        NSInteger areaCodeLength = MIN([newString length] - localNumberMaxLength, areaCodeMaxLength);
        
        NSRange areaRange = NSMakeRange([newString length] - localNumberMaxLength - areaCodeLength, areaCodeLength);
        
        NSString * area = [newString substringWithRange:areaRange];
        
        area = [NSString stringWithFormat:@"(%@)", area];
        
        [resultString insertString:area atIndex:0];
    }
    
    if ([newString length] > localNumberMaxLength + areaCodeMaxLength) {
        
        NSInteger countryCodeLength = MIN([newString length] - localNumberMaxLength - areaCodeMaxLength, countryCodeMaxLength);
        
        NSRange countryRange = NSMakeRange(0, countryCodeLength);
        
        NSString *country = [newString substringWithRange:countryRange];
        
        country = [NSString stringWithFormat:@"+%@", country];
        
        [resultString insertString:country atIndex:0];
    }
    
    textField.text = resultString;
    UILabel *phoneLabel = [self.allLabels objectAtIndex:[self.allFields indexOfObject:textField]];
    phoneLabel.text = textField.text;
    return NO;
}

- (BOOL) checkAge:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
    
    NSCharacterSet *validationSet = [[NSCharacterSet decimalDigitCharacterSet]invertedSet];
    NSArray *components = [string componentsSeparatedByCharactersInSet:validationSet];
    
    if ([components count] > 1) {
        return NO;
    }
    
    NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    return [resultString length] <= 3;
}

- (BOOL) checkEmail:(UITextField*) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
    
    NSMutableString *badString = [NSMutableString stringWithString:@",!#$%^&*()+=~`[]\{}|/';:"];
    NSCharacterSet *validationSet = [NSCharacterSet characterSetWithCharactersInString:badString];
    NSArray *components = [string componentsSeparatedByCharactersInSet:validationSet];
    
    if ([components count] > 1) {
        return NO;
        
    } else if (textField.text.length == 0 && [string isEqualToString: @"@"]) {
        return NO;
        
    } else if ([string isEqualToString:@"@"] && self.atSymbolIsPossible) {
        self.atSymbolIsPossible = NO;
        
    } else if ([string isEqualToString:@"@"] && !self.atSymbolIsPossible) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Save and Load values

- (void) saveValues {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Textfields text Saving
    for (UITextField *textField in self.allFields) {
        
        if (textField.tag == ZDTextFieldFirstName) {
            [userDefaults setObject:textField.text forKey:kFirstName];
            
        } else if (textField.tag == ZDTextFieldLastName) {
            [userDefaults setObject:textField.text forKey:kLastName];
            
        } else if (textField.tag == ZDTextFieldUsername) {
            [userDefaults setObject:textField.text forKey:kUserName];
            
        } else if (textField.tag == ZDTextFieldPassword) {
            [userDefaults setObject:textField.text forKey:kPassword];
            
        } else if (textField.tag == ZDTextFieldAge) {
            [userDefaults setObject:textField.text forKey:kAge];
            
        } else if (textField.tag == ZDTextFieldEmail) {
            [userDefaults setObject:textField.text forKey:kEmail];
            
        } else if (textField.tag == ZDTextFieldPhoneNumber) {
            [userDefaults setObject:textField.text forKey:kPhoneNumber];
            
        }
    }
    
    //Subscription info Saving
    [userDefaults setBool:self.subscribeSwitch.isOn forKey:kSubscribe];
    [userDefaults setInteger:self.receiveNewsControl.selectedSegmentIndex forKey:kReceiveNews];
    [userDefaults setDouble:self.newsPerDaySlider.value forKey:kNewsPerDay];
    [userDefaults setObject:self.newsCountLabel.text forKey:kNewsCountLabel];
    
    [userDefaults synchronize];
}

- (void) loadValues {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Textfields text Loading
    for (UITextField *textField in self.allFields) {
        
        if (textField.tag == ZDTextFieldFirstName) {
            textField.text = [userDefaults objectForKey:kFirstName];
            
        } else if (textField.tag == ZDTextFieldLastName) {
            textField.text = [userDefaults objectForKey:kLastName];
            
        } else if (textField.tag == ZDTextFieldUsername) {
            textField.text = [userDefaults objectForKey:kUserName];
            
        } else if (textField.tag == ZDTextFieldPassword) {
            textField.text = [userDefaults objectForKey:kPassword];
            
        } else if (textField.tag == ZDTextFieldAge) {
            textField.text = [userDefaults objectForKey:kAge];
            
        } else if (textField.tag == ZDTextFieldEmail) {
            textField.text = [userDefaults objectForKey:kEmail];
            
        } else if (textField.tag == ZDTextFieldPhoneNumber) {
            textField.text = [userDefaults objectForKey:kPhoneNumber];
        }
    }
    
    //Labels text Loading
    for (UILabel *label in self.allLabels) {
        
        if (label.tag == ZDTextFieldFirstName) {
            label.text = [userDefaults objectForKey:kFirstName];
            
        } else if (label.tag == ZDTextFieldLastName) {
            label.text = [userDefaults objectForKey:kLastName];
            
        } else if (label.tag == ZDTextFieldUsername) {
            label.text = [userDefaults objectForKey:kUserName];
            
        } else if (label.tag == ZDTextFieldPassword) {
            label.text = [userDefaults objectForKey:kPassword];
            
        } else if (label.tag == ZDTextFieldAge) {
            label.text = [userDefaults objectForKey:kAge];
            
        } else if (label.tag == ZDTextFieldEmail) {
            label.text = [userDefaults objectForKey:kEmail];
            
        } else if (label.tag == ZDTextFieldPhoneNumber) {
            label.text = [userDefaults objectForKey:kPhoneNumber];
        }
    }
    
    //Subscription info Loading
    self.subscribeSwitch.on = [userDefaults boolForKey:kSubscribe];
    self.receiveNewsControl.selectedSegmentIndex = [userDefaults integerForKey:kReceiveNews];
    self.newsPerDaySlider.value = [userDefaults doubleForKey:kNewsPerDay];
    self.newsCountLabel.text = [userDefaults objectForKey:kNewsCountLabel];
    
    [userDefaults synchronize];
}


@end
