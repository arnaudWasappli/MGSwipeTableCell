/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */

#import "DemoViewController.h"
#import "TestData.h"
#import "MGSwipeButton.h"

#define TEST_USE_MG_DELEGATE 1

@implementation DemoViewController
{
    NSMutableArray * tests;
    UIBarButtonItem * prevButton;
    UIImageView * background; //used for transparency test
    BOOL allowMultipleSwipe;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (buttonIndex == 1) {
        tests = [TestData data];
        [_collectionView reloadData];
    }
    else if (buttonIndex == 2) {
        if (background) {
            [background removeFromSuperview];
            background = nil;
            _collectionView.backgroundColor = [UIColor lightGrayColor];
        }
        else {
            background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.jpg"]];
            background.frame = self.view.bounds;
            background.contentMode = UIViewContentModeScaleToFill;
            background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.view insertSubview:background belowSubview:_collectionView];
            _collectionView.backgroundColor = [UIColor clearColor];
        }
        [_collectionView reloadData];
    }
    else if (buttonIndex == 3) {
        allowMultipleSwipe = !allowMultipleSwipe;
        [_collectionView reloadData];
    }
    else {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"autolayout_test" bundle:nil];
        DemoViewController *vc = [sb instantiateInitialViewController];
        vc.testingStoryboardCell = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void) actionClick: (id) sender
{
    
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"Select action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: nil];
    [sheet addButtonWithTitle:@"Reload test"];
    [sheet addButtonWithTitle:@"Transparency test"];
    [sheet addButtonWithTitle: allowMultipleSwipe ?  @"Single Swipe" : @"Multiple Swipe"];
    if (!_testingStoryboardCell) {
        [sheet addButtonWithTitle:@"Storyboard test"];
    }
    [sheet showInView:self.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tests = [TestData data];
    self.title = @"MGSwipeCell";
    
    if (!_testingStoryboardCell) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 10.0f;
        flowLayout.minimumInteritemSpacing = 0.0f;
        flowLayout.sectionInset = UIEdgeInsetsZero;
        flowLayout.itemSize = CGSizeMake(self.view.bounds.size.width, 155.0f);
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.backgroundColor = [UIColor lightGrayColor];
        [collectionView registerClass:[MGSwipeTableCell class] forCellWithReuseIdentifier:@"programmaticCell"];
        [self.view addSubview:collectionView];
        
        _collectionView = collectionView;
    }
    
    self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionClick:)];
}


-(NSArray *) createLeftButtons: (int) number
{
    NSMutableArray * result = [NSMutableArray array];
    UIColor * colors[3] = {[UIColor greenColor],
        [UIColor colorWithRed:0 green:0x99/255.0 blue:0xcc/255.0 alpha:1.0],
        [UIColor colorWithRed:0.59 green:0.29 blue:0.08 alpha:1.0]};
    UIImage * icons[3] = {[UIImage imageNamed:@"check.png"], [UIImage imageNamed:@"fav.png"], [UIImage imageNamed:@"menu.png"]};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:@"" icon:icons[i] backgroundColor:colors[i] padding:15 callback:^BOOL(MGSwipeTableCell * sender){
            NSLog(@"Convenience callback received (left).");
            return YES;
        }];
        [result addObject:button];
    }
    return result;
}


-(NSArray *) createRightButtons: (int) number
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[2] = {@"Delete", @"More"};
    UIColor * colors[2] = {[UIColor redColor], [UIColor lightGrayColor]};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
            NSLog(@"Convenience callback received (right).");
            BOOL autoHide = i != 0;
            return autoHide; //Don't autohide in delete button to improve delete expansion animation
        }];
        [result addObject:button];
    }
    return result;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return tests.count;
}

static NSString * collectionCellProgrammaticReuseIdentifier = @"programmaticCell";

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MGSwipeTableCell * cell;
    
    if (_testingStoryboardCell) {
        /**
         * Test using storyboard and prototype cell that uses autolayout
         **/
        cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"prototypeCell" forIndexPath:indexPath];
    }
    else {
        /**
         * Test using programmatically created cells
         **/
        cell = [_collectionView dequeueReusableCellWithReuseIdentifier:collectionCellProgrammaticReuseIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[MGSwipeTableCell alloc] initWithFrame:CGRectZero];
        }
    }
    
    TestData * data = [tests objectAtIndex:indexPath.row];
    
    //cell.textLabel.text = data.title;
    //cell.textLabel.font = [UIFont systemFontOfSize:16];
    //cell.detailTextLabel.text = data.detailTitle;
    cell.delegate = self;
    cell.allowsMultipleSwipe = allowMultipleSwipe;
    
    cell.backgroundColor = [UIColor whiteColor];
    
    if (background) { //transparency test
        cell.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.selectedBackgroundView.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.3];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.swipeBackgroundColor = [UIColor clearColor];
        //cell.textLabel.textColor = [UIColor yellowColor];
        //cell.detailTextLabel.textColor = [UIColor yellowColor];
    }

#if !TEST_USE_MG_DELEGATE
    cell.leftSwipeSettings.transition = data.transition;
    cell.rightSwipeSettings.transition = data.transition;
    cell.leftExpansion.buttonIndex = data.leftExpandableIndex;
    cell.leftExpansion.fillOnTrigger = NO;
    cell.rightExpansion.buttonIndex = data.rightExpandableIndex;
    cell.rightExpansion.fillOnTrigger = YES;
    cell.leftButtons = [self createLeftButtons:data.leftButtonsCount];
    cell.rightButtons = [self createRightButtons:data.rightButtonsCount];
#endif
    
    return cell;
}

#if TEST_USE_MG_DELEGATE
-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings;
{
    TestData * data = [tests objectAtIndex:[_collectionView indexPathForCell:cell].row];
    swipeSettings.transition = data.transition;
    
    if (direction == MGSwipeDirectionLeftToRight) {
        expansionSettings.buttonIndex = data.leftExpandableIndex;
        expansionSettings.fillOnTrigger = NO;
        return [self createLeftButtons:data.leftButtonsCount];
    }
    else {
        expansionSettings.buttonIndex = data.rightExpandableIndex;
        expansionSettings.fillOnTrigger = YES;
        return [self createRightButtons:data.rightButtonsCount];
    }
}
#endif

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion
{
    NSLog(@"Delegate: button tapped, %@ position, index %d, from Expansion: %@",
          direction == MGSwipeDirectionLeftToRight ? @"left" : @"right", (int)index, fromExpansion ? @"YES" : @"NO");
    
    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        //delete button
        NSIndexPath * path = [_collectionView indexPathForCell:cell];
        if (path) {
            [tests removeObjectAtIndex:path.row];
            [_collectionView deleteItemsAtIndexPaths:@[path]];
            return NO; //Don't autohide to improve delete expansion animation
        }
    }
    
    return YES;
}

@end
