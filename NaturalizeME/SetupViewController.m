//
//  SetupViewController.m
//  NaturalizeME
//
//  Created by James Carlson on 7/16/15.
//  Copyright (c) 2015 JC2 Dev. All rights reserved.
//

#import "SetupViewController.h"
#import "SetupInfo.h"
#import "SetupController.h"

@interface SetupViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *addressInput;

@property (strong, nonatomic) IBOutlet UILabel *governorLabel;

@property (strong, nonatomic) IBOutlet UILabel *senatorLabel;

@property (strong, nonatomic) IBOutlet UILabel *representativeLabel;

@property (strong) NSString *senatorOne;
@property (strong) NSString *senatorTwo;
@property (strong) NSString *representative;
@property (strong) NSString *governor;
@property (strong) NSString *stateCapital;



@end

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self notifications];
    
    [self loadData:self.civicsInfo];
}

-(void)loadData:(SetupInfo *)civicsInfo {

    self.governorLabel.text = [NSString stringWithFormat:@"Your Governor's name is %@", civicsInfo.governnor];
    self.senatorLabel.text = [NSString stringWithFormat:@"Your Senator's Name is %@", civicsInfo.senatorOne];
    self.representativeLabel.text = [NSString stringWithFormat:@"Your Representative's name is %@",civicsInfo.representative];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)notifications {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveData) name:@"infoCollected" object:nil];
}


- (IBAction)findRepresentative:(id)sender {
    
    [self getData];
    
}

- (IBAction)acceptData:(id)sender {
    
    [self saveData];
}

-(void)getData{
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    
    
    NSString *stringPrep = [self.addressInput.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *keyString = @"&key=AIzaSyCqdu1Nr-LcpjE3JZvm6gnGRXeirVkwuXU";
    
    NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/civicinfo/v2/representatives?address=%@%@", stringPrep, keyString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSLog(@"%@", dict);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.senatorOne = dict[@"officials"][0][@"name"];
            self.senatorTwo = dict[@"officials"][1][@"name"];
            self.representative = dict[@"officials"][4][@"name"];
            self.governor = dict[@"officials"][5][@"name"];
            self.stateCapital = dict[@"officials"][5][@"address"][0][@"city"];
            
            self.governorLabel.text = [NSString stringWithFormat:@"Your Governor's name is %@", self.governor];
            self.senatorLabel.text = [NSString stringWithFormat:@"Your Senator's Name is %@", self.senatorOne];
            self.representativeLabel.text = [NSString stringWithFormat:@"Your Representative's name is %@",self.representative];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"infoCollected" object:nil];
            
        });
        

    }];
    
    [task resume];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view reloadInputViews]; // this is only getting it to the main thread to process asyncronously. It should just go outside of this, and some other block of code such as to reload the tableview data - should go in there.
    });
    
}


-(void)saveData {
    
    if (self.civicsInfo) {
        self.civicsInfo.governnor = self.governor;
        self.civicsInfo.senatorOne = self.senatorOne;
        self.civicsInfo.senatorTwo = self.senatorTwo;
        self.civicsInfo.representative = self.representative;
    } else {
        self.civicsInfo = [[SetupController sharedInstance] storeCivicsInfo:self.governor senatorOneName:self.senatorOne senatorTwoName:self.senatorTwo repName:self.representative stateCapitalName:self.stateCapital];
    }
    
    [[SetupController sharedInstance]save];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
