//------------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//------------------------------------------------------------------------------

#import "MSALTestAppAcquireTokenViewController.h"
#import "MSALTestAppSettings.h"
#import "MSALTestAppAcquireLayoutBuilder.h"
#import "MSALTestAppProfileViewController.h"

@interface MSALTestAppAcquireTokenViewController () <UITextFieldDelegate>

@end

@implementation MSALTestAppAcquireTokenViewController
{
    UIView* _acquireSettingsView;
    UITextField* _userIdField;
    
    UISegmentedControl* _uiBehavior;
    
    UIButton* _profileButton;

    UISegmentedControl* _validateAuthority;
    
    UITextView* _resultView;
    
    NSLayoutConstraint* _bottomConstraint;
    NSLayoutConstraint* _bottomConstraint2;
    
    BOOL _userIdEdited;
}

- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    UITabBarItem* tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Acquire" image:nil tag:0];
    [self setTabBarItem:tabBarItem];
    
    [self setEdgesForExtendedLayout:UIRectEdgeTop];
    
    return self;
}

- (UIView*)createTwoItemLayoutView:(UIView*)item1
                             item2:(UIView*)item2
{
    item1.translatesAutoresizingMaskIntoConstraints = NO;
    item2.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView* view = [[UIView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:item1];
    [view addSubview:item2];
    
    NSDictionary* views = @{@"item1" : item1, @"item2" : item2 };
    NSArray* verticalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[item1(20)]|" options:0 metrics:NULL views:views];
    NSArray* verticalConstraints2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[item2(20)]|" options:0 metrics:NULL views:views];
    NSArray* horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[item1]-[item2]|" options:0 metrics:NULL views:views];
    
    [view addConstraints:verticalConstraints1];
    [view addConstraints:verticalConstraints2];
    [view addConstraints:horizontalConstraints];
    
    return view;
}

- (UIView*)createSettingsAndResultView
{
    CGRect screenFrame = UIScreen.mainScreen.bounds;
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:screenFrame];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.scrollEnabled = YES;
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.userInteractionEnabled = YES;
    MSALTestAppAcquireLayoutBuilder* layout = [MSALTestAppAcquireLayoutBuilder new];
    
    _userIdField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 400, 20)];
    _userIdField.borderStyle = UITextBorderStyleRoundedRect;
    _userIdField.delegate = self;
    [layout addControl:_userIdField title:@"userId"];
    
    _uiBehavior = [[UISegmentedControl alloc] initWithItems:@[@"Select", @"Login", @"Consent"]];
    _uiBehavior.selectedSegmentIndex = 0;
    [layout addControl:_uiBehavior title:@"behavior"];
    
    _profileButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_profileButton setTitle:MSALTestAppSettings.currentProfileTitle forState:UIControlStateNormal];
    [_profileButton addTarget:self action:@selector(changeProfile:) forControlEvents:UIControlEventTouchUpInside];
    _profileButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [layout addControl:_profileButton title:@"profile"];
    
    _validateAuthority = [[UISegmentedControl alloc] initWithItems:@[@"Yes", @"No"]];
    [layout addControl:_validateAuthority title:@"valAuth"];
    
    UIButton* clearCache = [UIButton buttonWithType:UIButtonTypeSystem];
    [clearCache setTitle:@"Clear Cache" forState:UIControlStateNormal];
    [clearCache addTarget:self action:@selector(clearCache:) forControlEvents:UIControlEventTouchUpInside];

    [layout addCenteredView:clearCache key:@"clearCache"];
    
    _resultView = [[UITextView alloc] init];
    _resultView.layer.borderWidth = 1.0f;
    _resultView.layer.borderColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f].CGColor;
    _resultView.layer.cornerRadius = 8.0f;
    _resultView.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.0f];
    _resultView.editable = NO;
    [layout addView:_resultView key:@"result"];
    
    UIView* contentView = [layout contentView];
    [scrollView addSubview:contentView];
    
    NSDictionary* views = @{ @"contentView" : contentView, @"scrollView" : scrollView };
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[contentView(==scrollView)]" options:0 metrics:nil views:views]];
    
    return scrollView;
}

- (UIView *)createAcquireButtonsView
{
    UIButton* acquireButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [acquireButton setTitle:@"acquireToken" forState:UIControlStateNormal];
    [acquireButton addTarget:self action:@selector(acquireTokenInteractive:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* acquireSilentButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [acquireSilentButton setTitle:@"acquireTokenSilent" forState:UIControlStateNormal];
    [acquireSilentButton addTarget:self action:@selector(acquireTokenSilent:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView* acquireButtonsView = [self createTwoItemLayoutView:acquireButton item2:acquireSilentButton];
    UIVisualEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView* acquireBlurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    acquireBlurView.translatesAutoresizingMaskIntoConstraints = NO;
    [acquireBlurView.contentView addSubview:acquireButtonsView];
    
    // Constraint to center the acquire buttons in the blur view
    [acquireBlurView addConstraint:[NSLayoutConstraint constraintWithItem:acquireButtonsView
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:acquireBlurView
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0.0]];
    NSDictionary* views = @{ @"buttons" : acquireButtonsView };
    [acquireBlurView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[buttons]-6-|" options:0 metrics:nil views:views]];
    
    return acquireBlurView;
}


- (void)loadView
{
    CGRect screenFrame = UIScreen.mainScreen.bounds;
    UIView* mainView = [[UIView alloc] initWithFrame:screenFrame];
    
    UIView* settingsView = [self createSettingsAndResultView];
    [mainView addSubview:settingsView];
    
    UIView* acquireBlurView = [self createAcquireButtonsView];
    [mainView addSubview:acquireBlurView];
    
    self.view = mainView;
    
    NSDictionary* views = @{ @"settings" : settingsView, @"acquire" : acquireBlurView };
    // Set up constraints for the web overlay
    
    // Set up constraints to make the settings scroll view take up the whole screen
    [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[settings]|" options:0 metrics:nil views:views]];
    [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[settings(>=200)]" options:0 metrics:nil views:views]];
    _bottomConstraint2 = [NSLayoutConstraint constraintWithItem:settingsView
                                                      attribute:NSLayoutAttributeBottom
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self.bottomLayoutGuide
                                                      attribute:NSLayoutAttributeTop
                                                     multiplier:1.0
                                                       constant:0];
    [mainView addConstraint:_bottomConstraint2];
    
    
    // And more constraints to make the acquire buttons view float on top
    [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[acquire]|" options:0 metrics:nil views:views]];
    
    // This constraint is the one that gets adjusted when the keyboard hides or shows. It moves the acquire buttons to make sure
    // they remain in view above the keyboard
    _bottomConstraint = [NSLayoutConstraint constraintWithItem:acquireBlurView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.bottomLayoutGuide
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0];
    [mainView addConstraint:_bottomConstraint];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary* userInfo = aNotification.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    CGRect keyboardFrameEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrameEnd = [self.view convertRect:keyboardFrameEnd fromView:nil];
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        _bottomConstraint.constant = -keyboardFrameEnd.size.height + 49.0; // 49.0 is the height of a tab bar
        _bottomConstraint2.constant = -keyboardFrameEnd.size.height + 49.0;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    CGRect keyboardFrameEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrameEnd = [self.view convertRect:keyboardFrameEnd fromView:nil];
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        _bottomConstraint.constant = 0;
        _bottomConstraint2.constant = 0;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    (void)animated;
    MSALTestAppSettings* settings = [MSALTestAppSettings settings];
    NSString* defaultUser = settings.defaultUser;
    if (![NSString msalIsStringNilOrBlank:defaultUser])
    {
        _userIdField.text = defaultUser;
    }
    
    self.navigationController.navigationBarHidden = YES;
    _validateAuthority.selectedSegmentIndex = settings.validateAuthority ? 0 : 1;
    [_profileButton setTitle:[MSALTestAppSettings currentProfileTitle] forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

- (void)updateResultViewError:(NSError *)error
{
    NSString *resultText = [NSString stringWithFormat:@"%@", error];
    [_resultView setText:resultText];
    
    NSLog(@"%@", resultText);
}

- (void)updateResultView:(MSALResult *)result
{
    NSString* resultText = [NSString stringWithFormat:@"{\n\taccessToken = %@\n\texpiresOn = %@\n\ttenantId = %@\t\nuser = %@\t\nscopes = %@\n}",
                            result.accessToken, result.expiresOn, result.tenantId, result.user, result.scopes];
    
    [_resultView setText:resultText];
    
    NSLog(@"%@", resultText);
}

- (MSALUIBehavior)uiBehavior
{
    NSString* label = [_uiBehavior titleForSegmentAtIndex:_uiBehavior.selectedSegmentIndex];
    
    if ([label isEqualToString:@"Select"])
        return MSALSelectAccount;
    if ([label isEqualToString:@"Login"])
        return MSALForceLogin;
    if ([label isEqualToString:@"Consent"])
        return MSALForceConsent;
    
    @throw @"Do not recognize prompt behavior";
}

- (void)acquireTokenInteractive:(id)sender
{
    (void)sender;
    MSALTestAppSettings* settings = [MSALTestAppSettings settings];
    NSString* authority = [settings authority];
    NSString* clientId = [settings clientId];
    //NSURL* redirectUri = [settings redirectUri];
    
    //BOOL validateAuthority = _validateAuthority.selectedSegmentIndex == 0;
    
    NSError *error = nil;
    MSALPublicClientApplication *application =
    [[MSALPublicClientApplication alloc] initWithClientId:clientId authority:authority error:&error];
    if (!application)
    {
        NSString* resultText = [NSString stringWithFormat:@"Failed to create PublicClientApplication:\n%@", error];
        [_resultView setText:resultText];
        return;
    }
    
    __block BOOL fBlockHit = NO;
    
    [application acquireTokenForScopes:@[@"User.Read"]
                       completionBlock:^(MSALResult *result, NSError *error)
     {
         if (fBlockHit)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                message:@"Completion block was hit multiple times!"
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                 
                 [self presentViewController:alert animated:YES completion:nil];
             });
             
             return;
         }
         fBlockHit = YES;
         
         dispatch_async(dispatch_get_main_queue(), ^{
             if (result)
             {
                 [self updateResultView:result];
             }
             else
             {
                 [self updateResultViewError:error];
             }
             [[NSNotificationCenter defaultCenter] postNotificationName:MSALTestAppCacheChangeNotification object:self];
         });
     }];
}

- (IBAction)cancelAuth:(id)sender
{
    (void)sender;
    [MSALPublicClientApplication cancelCurrentWebAuthSession];
}

- (IBAction)acquireTokenSilent:(id)sender
{
    (void)sender;
    /*
    MSALTestAppSettings* settings = [MSALTestAppSettings settings];
    NSString* authority = [settings authority];
    NSString* clientId = [settings clientId];
    NSURL* redirectUri = [settings redirectUri];
    BOOL validateAuthority = _validateAuthority.selectedSegmentIndex == 0;
    */
    // TODO
}

- (IBAction)clearCache:(id)sender
{
    (void)sender;
    // TODO
    /*
    NSDictionary* query = [[ADKeychainTokenCache defaultKeychainCache] defaultKeychainQuery];
    OSStatus status = SecItemDelete((CFDictionaryRef)query);
    
    if (status == errSecSuccess || status == errSecItemNotFound)
    {
        _resultView.text = @"Successfully cleared cache.";
    }
    else
    {
        _resultView.text = [NSString stringWithFormat:@"Failed to clear cache, error = %d", (int)status];
    }*/
}

- (IBAction)changeProfile:(id)sender
{
    (void)sender;
    [self.navigationController pushViewController:[MSALTestAppProfileViewController sharedProfileViewController] animated:YES];
}

@end
