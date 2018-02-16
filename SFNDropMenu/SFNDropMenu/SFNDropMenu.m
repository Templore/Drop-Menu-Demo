

/**
 *  Project: SFNDropMenu version 1.0
 *  Created by Siksfonine on 2015.02.16
 *  Copyright (c) 2015 Siksfonine. All rights reserved.
 *
 *  SFNDropMenu.m
 */

#import "SFNDropMenu.h"

#define SECTION_TITLE_FONT 13.0f
#define ANIMATE_DURATION .49f

typedef NS_ENUM(NSInteger, SFNDropMenuState)
{
    SFNDropMenuStateShut,
    SFNDropMenuStateOpen
};

@interface SFNDropMenu ()

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGRect screen;
@property (nonatomic, assign) CGSize screenSize;
@property (nonatomic, assign) CGRect dropMenuFrame;
@property (nonatomic, assign) CGFloat widthOfSectionTableView;

@property (nonatomic, assign) SFNDropMenuState state;

@property (nonatomic, assign) NSInteger currentSection;
@property (nonatomic, assign) NSInteger numberOfSection;
@property (nonatomic, assign) NSInteger numberOfRows;

@property (nonatomic, strong) UIView *sectionsView;
@property (nonatomic, strong) UITableView *sectionTableView;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) NSArray *titles;

@end

@implementation SFNDropMenu

- (instancetype)initWithOrigin:(CGPoint)origin
                        height:(CGFloat)height
                    dataSource:(id)dataSource
                      delegate:(id)delegate
                        titles:(NSArray *)titles
{
    self.dataSource = dataSource;
    self.delegate = delegate;
    
    self.titles = [NSArray array];
    self.titles = titles;
    
    self.height = height;
    self.currentSection = -1;
    self.state = SFNDropMenuStateShut;
    
    self.screen = [UIScreen mainScreen].bounds;
    self.screenSize = self.screen.size;
    
    self.dropMenuFrame = CGRectMake(origin.x, origin.y, self.screenSize.width, self.height);
    self = [super initWithFrame:self.dropMenuFrame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInDropMenu:)])
        {
            self.numberOfSection = [self.dataSource numberOfSectionsInDropMenu:self];
        }
        else
        {
            self = nil;
        }
        
        if (self.numberOfSection != 0)
        {
            [self initSectionsView];
            
            [self addTapGestureRecognizer];
        }
    }
    
    return self;
}

#pragma mark - Sections view

- (void)initSectionsView
{
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger runTime = [self.userDefaults integerForKey:@"runTime"];
    
    CGRect frameOfSectionsView = CGRectMake(0, 0, self.frame.size.width, self.height);
    self.sectionsView = [[UIView alloc] initWithFrame:frameOfSectionsView];
    self.sectionsView.backgroundColor = [UIColor whiteColor];
    
    CGFloat widthOfSection = self.frame.size.width / self.numberOfSection;
    for (int i = 0; i < self.numberOfSection; i++)
    {
        UIButton *section = [[UIButton alloc] initWithFrame:CGRectMake(i * widthOfSection, 0, widthOfSection, self.height)];
        section.tag = i;
        
        [section setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [section.titleLabel setFont:[UIFont systemFontOfSize:SECTION_TITLE_FONT]];
        [section addTarget:self action:@selector(sectionAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([self.dataSource respondsToSelector:@selector(dropMenu:titleForRowAtIndex:section:)])
        {
            NSInteger index = [self.userDefaults integerForKey:[NSString stringWithFormat:@"%d", i]];
            NSString *title = @"- -";
            
            if (runTime == 0 || index == -1)
            {
                if (self.titles)
                {
                    title = [self.titles objectAtIndex:i];
                }
                
                [section setTitle:title forState:UIControlStateNormal];
                [self.userDefaults setInteger:-1 forKey:[NSString stringWithFormat:@"%d", i]];
                [self.userDefaults synchronize];
            }
            else
            {
                title = [self.dataSource dropMenu:self titleForRowAtIndex:index section:i];
                [section setTitle:title forState:UIControlStateNormal];
            }
        }
        
        [self.sectionsView addSubview:section];
    }
    
    [self addSubview:self.sectionsView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 1, self.screenSize.width, .5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:line];
    
    [self.userDefaults setInteger:++runTime forKey:@"runTime"];
    [self.userDefaults synchronize];
}

- (void)sectionAction:(UIButton *)sender
{
    self.widthOfSectionTableView = self.frame.size.width / self.numberOfSection;
    CGRect frame = CGRectZero;
    if (sender.tag == 2)
    {
        frame = CGRectMake(0, self.height, self.frame.size.width, 0);
    }
    else
    {
        frame = CGRectMake(sender.tag * self.widthOfSectionTableView, self.height, self.widthOfSectionTableView, 0);
    }
    
    if (!self.sectionTableView)
    {
        self.sectionTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        self.sectionTableView.dataSource = self;
        self.sectionTableView.delegate = self;
        self.sectionTableView.backgroundColor = [UIColor whiteColor];
        self.sectionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    if ([self.dataSource respondsToSelector:@selector(dropMenu:numberOfRowsInSection:)])
    {
        self.numberOfRows = [self.dataSource dropMenu:self numberOfRowsInSection:sender.tag];
    }
    
    /* Separator between cells */
    for (int i = 0; i < self.numberOfRows - 1; i++)
    {
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, (i + 1) * 44, self.screenSize.width, .5)];
        
        if (sender.tag == 0)
        {
            separator.backgroundColor = [UIColor whiteColor];
        }
        else
        {
            separator.backgroundColor = [UIColor lightGrayColor];
        }
        
        [self.sectionTableView addSubview:separator];
    }
    
    CGFloat height = self.screenSize.height - self.dropMenuFrame.origin.y - self.sectionsView.frame.size.height - 50;
    if (self.numberOfRows * 44 >= height)
    {
        frame.size.height = height;
        self.sectionTableView.scrollEnabled = YES;
        self.sectionTableView.showsVerticalScrollIndicator = NO;
    }
    else
    {
        frame.size.height = self.numberOfRows * 44;
        self.sectionTableView.scrollEnabled = NO;
    }
    
    if (self.currentSection != sender.tag && self.state == SFNDropMenuStateShut)
    {
        /* Show the section table view */
        self.frame = CGRectMake(0, self.dropMenuFrame.origin.y, self.dropMenuFrame.size.width, self.screenSize.height - self.dropMenuFrame.origin.y);
        
        self.currentSection = sender.tag;
        
        [UIView animateWithDuration:ANIMATE_DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
            [self.sectionTableView setFrame:frame];
            
            [UIView animateWithDuration:ANIMATE_DURATION animations:^{
                
                self.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
                
            }];
                             
            [self.sectionTableView reloadData];
            
            [self addSubview:self.sectionTableView];
            
        } completion:^(BOOL finished) {
            
            self.state = SFNDropMenuStateOpen;
            
        }];
    }
    else if (self.currentSection != sender.tag && self.state == SFNDropMenuStateOpen)
    {
        /* Reload the section table view */
        self.currentSection = sender.tag;
        
        [UIView animateWithDuration:ANIMATE_DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
            [self.sectionTableView setFrame:frame];
            [self.sectionTableView reloadData];
            
        } completion:^(BOOL finished) {
            
        }];
    }
    else if (self.currentSection == sender.tag && self.state == SFNDropMenuStateOpen)
    {
        /* Shut the section table view */
        self.currentSection = -1;
        
        [UIView animateWithDuration:ANIMATE_DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            if (sender.tag == 2)
            {
                [self.sectionTableView setFrame:CGRectMake(0, self.height, self.frame.size.width, 0)];
            }
            else
            {
                [self.sectionTableView setFrame:CGRectMake(sender.tag * self.widthOfSectionTableView, self.height,
                                                           self.widthOfSectionTableView, 0)];
            }
                             
            [UIView animateWithDuration:ANIMATE_DURATION animations:^{
                
                self.backgroundColor = [UIColor clearColor];
                                 
            }];
            
        } completion:^(BOOL finished) {
            
            self.state = SFNDropMenuStateShut;
            self.frame = self.dropMenuFrame;
            
            [self.sectionTableView removeFromSuperview];
            self.sectionTableView = nil;
        }];
    }
}

#pragma mark - Tap gesture recognizer

- (void)addTapGestureRecognizer
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

/* !mportant */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    /* Tap gesture of section table view cell will be ignored */
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) return NO;
    
    return  YES;
}

- (void)tapAction:(UITapGestureRecognizer *)recognizer
{
    [UIView animateWithDuration:ANIMATE_DURATION
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
    
    if (self.currentSection == 2)
    {
        [self.sectionTableView setFrame:CGRectMake(0, self.height, self.frame.size.width, 0)];
    }
    else
    {
        [self.sectionTableView setFrame:CGRectMake(self.currentSection * self.widthOfSectionTableView, self.height,
                                                   self.widthOfSectionTableView, 0)];
    }
    
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
                                 
        self.backgroundColor = [UIColor clearColor];
                                 
    }];
            
    } completion:^(BOOL finished) {
            
        [self.sectionTableView removeFromSuperview];
        
        self.sectionTableView = nil;
        self.currentSection = -1;
        
        self.frame = self.dropMenuFrame;
        self.state = SFNDropMenuStateShut;
            
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *IDENTIFIER = @"Cell";
    [self.sectionTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:IDENTIFIER];
    UITableViewCell *cell = [self.sectionTableView dequeueReusableCellWithIdentifier:IDENTIFIER forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IDENTIFIER];
    }
    
    if ([self.dataSource respondsToSelector:@selector(dropMenu:titleForRowAtIndex:section:)])
    {
        cell.textLabel.text = [self.dataSource dropMenu:self titleForRowAtIndex:indexPath.row section:self.currentSection];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:SECTION_TITLE_FONT];
    
    if (self.currentSection == 0)
    {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor whiteColor];
    }
    else if (self.currentSection == 2)
    {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* Update section title */
    if ([self.delegate respondsToSelector:@selector(dropMenu:didSelectRowAtIndex:section:)])
    {
        NSString *title = [self.dataSource dropMenu:self titleForRowAtIndex:indexPath.row section:self.currentSection];
        UIButton *section = (UIButton *)[self viewWithTag:self.currentSection];
        [section setTitle:title forState:UIControlStateNormal]; /*!!!!!Bug report, NO.001 */
        
        [self.delegate dropMenu:self didSelectRowAtIndex:indexPath.row section:self.currentSection];
        
        [self.userDefaults setInteger:indexPath.row forKey:[NSString stringWithFormat:@"%ld", (long)self.currentSection]];
        [self.userDefaults synchronize];
    }

    /* Shut the section table view */
    [UIView animateWithDuration:ANIMATE_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        if (self.currentSection == 2)
        {
            [self.sectionTableView setFrame:CGRectMake(0, self.height, self.frame.size.width, 0)];
        }
        else
        {
            [self.sectionTableView setFrame:CGRectMake(self.currentSection * self.widthOfSectionTableView, self.height,
                                                       self.widthOfSectionTableView, 0)];
        }
        
        [UIView animateWithDuration:ANIMATE_DURATION animations:^{
            
            self.backgroundColor = [UIColor clearColor];
            
        }];
        
    } completion:^(BOOL finished) {
        
        [self.sectionTableView removeFromSuperview];
        self.sectionTableView = nil;
        self.currentSection = -1;
        
        self.frame = self.dropMenuFrame;
        self.state = SFNDropMenuStateShut;
        
    }];
}

@end