
#import "SFNViewController.h"

@interface SFNViewController ()

@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation SFNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.data = [NSMutableArray array];
    [self prepareForData];
    if (!self.data)
    {
        self.data = [@[@[@"s0r0", @"s0r1", @"s0r2"],
                       @[@"s1r0", @"s1r1", @"s1r2", @"s1r3", @"s1r4"],
                       @[@"s2r0", @"s2r1", @"s2r2", @"s2r3"]] mutableCopy];
    }
    
    NSArray *titles = @[@"工作地区", @"工作性质", @"擅长领域"];
    
    SFNDropMenu *dropMenu = [[SFNDropMenu alloc] initWithOrigin:CGPointMake(0, 64)
                                                         height:36
                                                     dataSource:self
                                                       delegate:self
                                                         titles:titles];
    
    [self.view addSubview:dropMenu];
}

- (void)prepareForData
{
    NSString *pathOfCity = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"plist"];
    NSString *pathOfProperty = [[NSBundle mainBundle] pathForResource:@"property" ofType:@"plist"];
    NSString *pathOfField = [[NSBundle mainBundle] pathForResource:@"field" ofType:@"plist"];
    
    NSArray *arrayOfCity = [[NSArray alloc] initWithContentsOfFile:pathOfCity];
    NSArray *arrayOfProperty = [[NSArray alloc] initWithContentsOfFile:pathOfProperty];
    NSArray *arrayOfField = [[NSArray alloc] initWithContentsOfFile:pathOfField];
    
    [self.data addObject:arrayOfCity];
    [self.data addObject:arrayOfProperty];
    [self.data addObject:arrayOfField];
}

#pragma mark - SFNDropMenu data source

- (NSInteger)numberOfSectionsInDropMenu:(SFNDropMenu *)dropMenu
{
    return self.data.count;
}

- (NSInteger)dropMenu:(SFNDropMenu *)dropMenu numberOfRowsInSection:(NSInteger)section
{
    return [self.data[section] count];
}

- (NSString *)dropMenu:(SFNDropMenu *)dropMenu titleForRowAtIndex:(NSInteger)index section:(NSInteger)section
{
    if (section == 0)
    {
        NSDictionary *dictionary = self.data[0][index];
        return [dictionary objectForKey:@"state"];
    }
    else
    {
        return self.data[section][index];
    }
}

#pragma mark - SFNDropMenu delegate

- (void)dropMenu:(SFNDropMenu *)dropMenu didSelectRowAtIndex:(NSInteger)index section:(NSInteger)section
{
    NSLog(@"%ld, %ld", (long)section, (long)index);
}

@end