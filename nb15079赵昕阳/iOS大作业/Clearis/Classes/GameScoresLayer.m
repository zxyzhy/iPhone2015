//
//  GameScoresLayer.m
//  Clearis
//
//  Created by 881 on 10-3-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameScoresLayer.h"
#import "GameMenu.h"
#import "GameScoresCell.h"
#import "GameAppDelegate.h"
#import "global.h"


@implementation GameScoresLayer

- (id) initWithDataManager:(GameDataManager*)manager
{
	[super initWithDataManager:manager];
		
	CGSize contentSize = self.contentSize;
	MenuItemImage* mi1 = [MenuItemImage itemFromNormalImage:@"ShortMenuButton.png" 
											  selectedImage:@"ShortMenuButton_p.png" 
													 target:self 
												   selector:@selector(startMenu:)];
	GameMenu* menu1 = [GameMenu menuWithItems:mi1, nil];
	menu1.position = ccp(80, 40);
	[self addChild:menu1];
	menu1.isTouchEnabled = FALSE;
	
	MenuItemImage* mi2 = [MenuItemImage itemFromNormalImage:@"ShortResetButton.png" 
											  selectedImage:@"ShortResetButton_p.png" 
													 target:self 
												   selector:@selector(startReset:)];
	GameMenu* menu2 = [GameMenu menuWithItems:mi2, nil];
	menu2.position = ccp(contentSize.width - 80, 40);
	[self addChild:menu2];
	menu2.isTouchEnabled = FALSE;
	
	Sprite* frame = [Sprite spriteWithFile:@"GameScoresFrame.png"];
	frame.position = ccp(160, 275);
	[self addChild:frame];
		
	[MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:30];
	MenuItemToggle* menuItemToggle = [MenuItemToggle itemWithTarget:self selector:@selector(startSelected:) items:
						[MenuItemFont itemFromString:@"Normal"],
						[MenuItemFont itemFromString:@"Locked"],
						nil];
	GameMenu* menu3 = [GameMenu menuWithItems:menuItemToggle, nil];
	[self addChild:menu3];
	menu3.color = ccc3(255, 255, 0);
	menu3.position = ccp(170, 448);
	menu3.isTouchEnabled = FALSE;
	
	if (m_dataManager.isLevelLocked)
	{
		m_showNormal = false;
		menuItemToggle.selectedIndex = 1;
	}
	else
	{
		m_showNormal = true;
		menuItemToggle.selectedIndex = 0;
	}
	
	CGFloat ypos = (self.contentSize.height - 275) - 370 * 0.5;
	const int adjust = 70;
	m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, ypos + adjust, 300, 370 - adjust)];
	m_tableView.backgroundColor = [UIColor clearColor];
	m_tableView.delegate = self;
	m_tableView.dataSource = self;
	m_tableView.separatorColor = [UIColor clearColor];
	
	m_resetController = [[GameResetViewControler alloc] initWithNibName:@"GameResetViewControler" 
																 bundle:[NSBundle mainBundle]];
	[m_resetController setTarget:self];
	
	
	return self;
}


- (void) levelLayer:(GameDataManager*)manager
{
	[super levelLayer:manager];
	[m_tableView removeFromSuperview];
	[m_resetController.view removeFromSuperview];
}


- (void) enterLayer
{
	[super enterLayer];
	[m_dataManager.mainWindow addSubview:m_tableView];
}

- (void) startMenu:(id)sender
{
	[[GameAppDelegate instance] startMainMenu:true];
}


- (void)hideAnimateEnd:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	m_tableView.userInteractionEnabled = TRUE;
	[GameUtil enableMenu:self];
	
	[m_resetController.view removeFromSuperview];
}


- (void) startCancel:(id)sender
{	
	UIView* view = m_resetController.view;
	CGRect rect = view.frame;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDidStopSelector:@selector(hideAnimateEnd:finished:context:)];
	[UIView setAnimationDelegate:self];
	
	rect.origin.y += rect.size.height;
	view.frame = rect;
	
	[UIView commitAnimations];
}


- (void) startResetScores:(id)sender
{
	[m_dataManager clearScoresIsLevelLocked:!m_showNormal];
	[m_tableView reloadData];
	
	UIView* view = m_resetController.view;
	CGRect rect = view.frame;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDidStopSelector:@selector(hideAnimateEnd:finished:context:)];
	[UIView setAnimationDelegate:self];
	
	rect.origin.y += rect.size.height;
	view.frame = rect;
	
	[UIView commitAnimations];
}


- (void) startReset:(id)sender
{
	m_tableView.userInteractionEnabled = FALSE;
	[GameUtil disableMenu:self];
	
	UIView* view = m_resetController.view;
	if (view.superview == nil)
	{
		[m_dataManager.mainWindow addSubview:view];
	}
	
	CGRect rect = view.frame;
	view.backgroundColor = [UIColor clearColor];
	rect = CGRectMake(0, m_dataManager.mainWindow.frame.size.height, rect.size.width, rect.size.height);
	view.frame = rect;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	rect.origin.y -= rect.size.height;
	view.frame = rect;
	
	[UIView commitAnimations];
}


- (void) startSelected:(id)sender
{
	MenuItemToggle* menuItemToggle = (MenuItemToggle*)sender;
	if (menuItemToggle.selectedIndex == 0)
	{
		m_showNormal = true;
	}
	else
	{
		m_showNormal = false;
	}
	
	[m_tableView reloadData];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return 35;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString* identifier = @"GameScoresCellIdentifier";
	GameScoresCell* tableViewCell = (GameScoresCell*)[m_tableView dequeueReusableCellWithIdentifier:identifier];
	if (tableViewCell == nil)
	{ 
		NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"GameScoresCell" owner:nil options:nil];
		for (id currentObject in nib)
		{
			if ([currentObject isKindOfClass:[GameScoresCell class]])
			{
				tableViewCell = currentObject;
				break;
			}
		}
	}
	
	NSArray* scoreList = m_showNormal ? m_dataManager.scoreListNormal : m_dataManager.scoreListLocked;
	NSArray* playerNameList = m_showNormal ? m_dataManager.playerNameListNormal : m_dataManager.playerNameListLocked;
	
	tableViewCell.userInteractionEnabled = NO;
	tableViewCell.m_name.backgroundColor = [UIColor clearColor];
	tableViewCell.m_score.backgroundColor = [UIColor clearColor];
	
	NSInteger idx = [indexPath row];
	NSString* name = [playerNameList objectAtIndex:idx];
	NSString* nameText = [NSString stringWithFormat:@"%d. %@", idx+1, name];
	tableViewCell.m_name.text = nameText;
	
	NSNumber* scoreNum = [scoreList objectAtIndex:idx];
	NSString* score = [NSString stringWithFormat:@"%d", [scoreNum intValue]];
	tableViewCell.m_score.text = score;
	
	return tableViewCell;
}


- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	NSArray* array1 = m_showNormal ? m_dataManager.scoreListNormal : m_dataManager.scoreListLocked;
	NSArray* array2 = m_showNormal ? m_dataManager.playerNameListNormal : m_dataManager.playerNameListLocked;
	
	int counter1 = [array1 count];
	int counter2 = [array2 count];
	
	return counter1 < counter2 ? counter1 : counter2;
}


- (void) dealloc
{
	[m_resetController release];
	[m_tableView release];
	[super dealloc];
}



@end
