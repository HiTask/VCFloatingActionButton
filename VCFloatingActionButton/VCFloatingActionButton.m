//
//  VCFloatingActionButton.m
//  starttrial
//
//  Created by Giridhar on 25/03/15.
//  Copyright (c) 2015 Giridhar. All rights reserved.
//

#import "VCFloatingActionButton.h"
#import "floatTableViewCell.h"

#define SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height

CGFloat animationTime = 0.55;
CGFloat rowHeight = 60.f;
NSInteger noOfRows = 0;
NSInteger tappedRow;
CGFloat previousOffset;
CGFloat buttonToScreenHeight;
@implementation VCFloatingActionButton

@synthesize windowView;
//@synthesize hideWhileScrolling;
@synthesize delegate;

@synthesize bgScroller;

-(id)initWithFrame:(CGRect)frame normalImage:(UIImage*)passiveImage andPressedImage:(UIImage*)activeImage withScrollview:(UIScrollView*)scrView
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initial params
        _mainButtonColor = [UIColor colorWithRed:0.000 green:0.502 blue:1.000 alpha:1.000];
        _secondaryButtonRatio = 0.75;
        _secondaryButtonsColor = [UIColor colorWithWhite:0.902 alpha:1.000];
        
        windowView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        windowView.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _mainWindow = [UIApplication sharedApplication].keyWindow;
        _buttonView = [[UIView alloc]initWithFrame:frame];
        _buttonView.backgroundColor = [UIColor clearColor];
        _buttonView.userInteractionEnabled = YES;
        _buttonView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        _buttonView.layer.masksToBounds = NO;
        _buttonView.layer.backgroundColor = self.mainButtonColor.CGColor;
        _buttonView.layer.cornerRadius = frame.size.height / 2;
        _buttonView.layer.shadowColor = [UIColor blackColor].CGColor;
        _buttonView.layer.shadowOpacity = 1.0;
        _buttonView.layer.shadowRadius = 7.0;
        _buttonView.layer.shadowOffset = CGSizeMake(0, 4);
        
        buttonToScreenHeight = SCREEN_HEIGHT - CGRectGetMaxY(self.frame);
        
        _menuTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - (SCREEN_HEIGHT - CGRectGetMaxY(self.frame)) )];
        _menuTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _menuTable.scrollEnabled = NO;
        
        _menuTable.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, CGRectGetHeight(frame))];
        
        _menuTable.delegate = self;
        _menuTable.dataSource = self;
        _menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _menuTable.backgroundColor = [UIColor clearColor];
        _menuTable.transform = CGAffineTransformMakeRotation(-M_PI); //Rotate the table
        
        previousOffset = scrView.contentOffset.y;
        
        bgScroller = scrView;

        _pressedImage = activeImage;
        _normalImage = passiveImage;
        [self setupButton];
        
        
    }
    return self;
}


-(void)setHideWhileScrolling:(BOOL)hideWhileScrolling
{
    if (bgScroller!=nil)
    {
        _hideWhileScrolling = hideWhileScrolling;
        if (!hideWhileScrolling)
        {
            [bgScroller removeObserver:self forKeyPath:@"contentOffset"];
        }
        else
        {
            [bgScroller addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}



-(void) setupButton
{
    _isMenuVisible = false;
    self.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *buttonTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:buttonTap];
    
    
    UITapGestureRecognizer *buttonTap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    
    [_buttonView addGestureRecognizer:buttonTap3];
    
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *vsview = [[UIVisualEffectView alloc]initWithEffect:blur];
    

    _bgView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    _bgView.alpha = 0;
    _bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _bgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *buttonTap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];

    buttonTap2.cancelsTouchesInView = NO;
    vsview.frame = _bgView.bounds;
    _bgView = vsview;
    [_bgView addGestureRecognizer:buttonTap2];
    
    
    _normalImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    _normalImageView.userInteractionEnabled = YES;
    _normalImageView.contentMode = UIViewContentModeCenter;
    
    _normalImageView.backgroundColor = [UIColor clearColor];
    _normalImageView.layer.masksToBounds = NO;
    _normalImageView.layer.backgroundColor = self.mainButtonColor.CGColor;
    _normalImageView.layer.cornerRadius = _normalImageView.frame.size.height / 2;
    _normalImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _normalImageView.layer.shadowOpacity = 1.0;
    _normalImageView.layer.shadowRadius = 7.0;
    _normalImageView.layer.shadowOffset = CGSizeMake(0, 4);
    
    _pressedImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    _pressedImageView.contentMode = UIViewContentModeCenter;
    _pressedImageView.userInteractionEnabled = YES;
    
    
    _normalImageView.image = _normalImage;
    _pressedImageView.image = _pressedImage;
    
    
    [_bgView addSubview:_menuTable];
    
    [_buttonView addSubview:_pressedImageView];
    [_buttonView addSubview:_normalImageView];
    [self addSubview:_normalImageView];

}

- (void)setMainButtonColor:(UIColor *)mainButtonColor {
    _mainButtonColor = mainButtonColor;
    _buttonView.layer.backgroundColor = mainButtonColor.CGColor;
    _normalImageView.layer.backgroundColor = mainButtonColor.CGColor;
}

-(void)handleTap:(id)sender //Show Menu
{

    
    if (_isMenuVisible)
    {
        
        [self dismissMenu:nil];
    }
    else
    {
        [windowView addSubview:_bgView];
        _bgView.translatesAutoresizingMaskIntoConstraints = NO;
        windowView.translatesAutoresizingMaskIntoConstraints = NO;
        [windowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[v]-0-|" options:0 metrics:nil views:@{@"v":_bgView}]];
        [windowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[v]-0-|" options:0 metrics:nil views:@{@"v":_bgView}]];
        
        [windowView addSubview:_buttonView];
        
        [_mainWindow addSubview:windowView];
        
        [_mainWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[v]-0-|" options:0 metrics:nil views:@{@"v":windowView}]];
        [_mainWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[v]-0-|" options:0 metrics:nil views:@{@"v":windowView}]];
        [self showMenu:nil];
    }
    _isMenuVisible  = !_isMenuVisible;
    
    
}




#pragma mark -- Animations
#pragma mark ---- button tap Animations

-(void) showMenu:(id)sender
{
    
    self.pressedImageView.transform = CGAffineTransformMakeRotation(M_PI);
    self.pressedImageView.alpha = 0.0; //0.3
    [UIView animateWithDuration:animationTime/2 animations:^
     {
         self.bgView.alpha = 1;
         
        
         self.normalImageView.transform = CGAffineTransformMakeRotation(-M_PI);
         self.normalImageView.alpha = 0.0; //0.7

         
         self.pressedImageView.transform = CGAffineTransformIdentity;
         self.pressedImageView.alpha = 1;
         noOfRows = _labelArray.count;
         [_menuTable reloadData];

     }
         completion:^(BOOL finished)
     {
     }];

}

-(void) dismissMenu:(id) sender

{
    [UIView animateWithDuration:animationTime/2 animations:^
     {
         self.bgView.alpha = 0;
         self.pressedImageView.alpha = 0.f;
         self.pressedImageView.transform = CGAffineTransformMakeRotation(-M_PI);
         self.normalImageView.transform = CGAffineTransformMakeRotation(0);
         self.normalImageView.alpha = 1.f;
     } completion:^(BOOL finished)
     {
         noOfRows = 0;
         [_bgView removeFromSuperview];
         [windowView removeFromSuperview];
         [_mainWindow removeFromSuperview];
         
     }];
}

#pragma mark ---- Scroll animations

-(void) showMenuDuringScroll:(BOOL) shouldShow
{
    if (_hideWhileScrolling)
    {
        
        if (!shouldShow)
        {
            [UIView animateWithDuration:animationTime animations:^
             {
                 self.transform = CGAffineTransformMakeTranslation(0, buttonToScreenHeight*6);
             } completion:nil];
        }
        else
        {
            [UIView animateWithDuration:animationTime/2 animations:^
             {
                 self.transform = CGAffineTransformIdentity;
             } completion:nil];
        }
        
    }
}


-(void) addRows
{
    NSMutableArray *ip = [[NSMutableArray alloc]init];
    for (int i = 0; i< noOfRows; i++)
    {
        [ip addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [_menuTable insertRowsAtIndexPaths:ip withRowAnimation:UITableViewRowAnimationFade];
}




#pragma mark -- Observer for scrolling
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"])
    {
        
        NSLog(@"%f",bgScroller.contentOffset.y);
       
        CGFloat diff = previousOffset - bgScroller.contentOffset.y;
        
        if (ABS(diff) > 15)
        {
            if (bgScroller.contentOffset.y > 0)
            {
                [self showMenuDuringScroll:(previousOffset > bgScroller.contentOffset.y)];
                previousOffset = bgScroller.contentOffset.y;
            }
            else
            {
                [self showMenuDuringScroll:YES];
            }
            
            
        }

    }
}


#pragma mark -- Tableview methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return noOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(floatTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    
    //KeyFrame animation
    
//    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position.y"];
//    anim.fromValue = @((indexPath.row+1)*CGRectGetHeight(cell.imgView.frame)*-1);
//    anim.toValue   = @(cell.frame.origin.y);
//    anim.duration  = animationTime/2;
//    anim.timingFunction = [CAMediaTimingFunction  functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    [cell.layer addAnimation:anim forKey:@"position.y"];
    
    
    
    
    double delay = (indexPath.row*indexPath.row) * 0.004;  //Quadratic time function for progressive delay


    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.95, 0.95);
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(0,-(indexPath.row+1)*CGRectGetHeight(cell.imgView.frame));
    cell.transform = CGAffineTransformConcat(scaleTransform, translationTransform);
    cell.alpha = 0.f;
    
    [UIView animateWithDuration:animationTime/2 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        
        cell.transform = CGAffineTransformIdentity;
        cell.alpha = 1.f;
        
    } completion:^(BOOL finished)
    {
        
    }];
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"cell";
    floatTableViewCell *cell = [_menuTable dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        [_menuTable registerNib:[UINib nibWithNibName:@"floatTableViewCell" bundle:nil]forCellReuseIdentifier:identifier];
        cell = [_menuTable dequeueReusableCellWithIdentifier:identifier];
    }
    
    cell.imgView.image = [UIImage imageNamed:[_imageArray objectAtIndex:indexPath.row]];
    cell.imgViewHeightConstraint.constant = _normalImageView.frame.size.height * self.secondaryButtonRatio;
    cell.imgViewWidthConstraint.constant = _normalImageView.frame.size.width * self.secondaryButtonRatio;
    cell.imgView.backgroundColor = [UIColor clearColor];
    cell.imgView.layer.backgroundColor = self.secondaryButtonsColor.CGColor;
    cell.imgView.contentMode = UIViewContentModeCenter;
    cell.imgView.layer.masksToBounds = NO;
    cell.imgView.layer.cornerRadius = cell.imgViewHeightConstraint.constant / 2;
    cell.imgView.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.imgView.layer.shadowOpacity = 0.7;
    cell.imgView.layer.shadowRadius = 7.0;
    cell.imgView.layer.shadowOffset = CGSizeMake(0, 4);
    
    cell.title.text    = [_labelArray objectAtIndex:indexPath.row];
    if (self.buttonsRowsFont) {
        cell.title.font = self.buttonsRowsFont;
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"selected CEll: %tu",indexPath.row);
    [delegate didSelectMenuOptionAtIndex:indexPath.row];
    
}

@end
