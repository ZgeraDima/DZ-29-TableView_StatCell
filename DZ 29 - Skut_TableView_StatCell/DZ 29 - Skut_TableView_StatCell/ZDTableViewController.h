//
//  ZDTableViewController.h
//  DZ 29 - Skut_TableView_StatCell
//
//  Created by mac on 31.12.17.
//  Copyright © 2017 Dima Zgera. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
    
    ZDTextFieldFirstName,
    ZDTextFieldLastName,
    ZDTextFieldUsername,
    ZDTextFieldPassword,
    ZDTextFieldAge,
    ZDTextFieldEmail,
    ZDTextFieldPhoneNumber
    
}DZTextField;


@interface ZDTableViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *allFields;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *allLabels;
@property (weak, nonatomic) IBOutlet UISwitch *subscribeSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *receiveNewsControl;
@property (weak, nonatomic) IBOutlet UISlider *newsPerDaySlider;
@property (weak, nonatomic) IBOutlet UILabel *newsCountLabel;

@property (assign, nonatomic) BOOL atSymbolIsPossible;


- (IBAction)actionClearAllButton:(UIButton *)sender;

- (IBAction)actionEditingChanged:(UITextField *)sender;

- (IBAction)actionValueChanged:(id)sender;



@end
