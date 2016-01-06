//
//  GameHelpLayer.m
//  Clearis
//
//  Created by 881 on 10-3-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameHelpLayer.h"
#import "GameMenu.h"
#import "GameAppDelegate.h"
#import "GameInfoCell.h"


@implementation GameHelpLayer


- (id) initWithDataManager:(GameDataManager*)manager
{
	[super initWithDataManager:manager];
	
	Sprite* bg = [Sprite spriteWithFile:@"AboutBg.png"];
	bg.anchorPoint = ccp(0, 0);
	
	[self addChild:bg];
	
	MenuItemImage* mi1 = [MenuItemImage itemFromNormalImage:@"MainMenuButton2.png" 
											  selectedImage:@"MainMenuButton2_p.png" 
													 target:self 
												   selector:@selector(startMenu:)];
	GameMenu* menu1 = [GameMenu menuWithItems:mi1, nil];
	menu1.position = ccp(self.contentSize.width * 0.5, 40);
	[self addChild:menu1];
	menu1.isTouchEnabled = FALSE;
	
	m_infoArray = [[NSArray alloc] initWithObjects:
				   @"Powered by Cocos2d.", 
				   @"\'Clearis\' = \'Clear\' + \'Tetris\'", 
				   @"Any question, contact us.", 
				   @"Our E-mail: hjcapple@gmail.com", 
				   @"Thank you for your purchase.", 
				   @"If fun, please tell your friends.", 
				   @"This game is very simple. No help.",
				   @"Thank you again.", 
				   nil];
	
	m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 86, 300, 304)];
	m_tableView.backgroundColor = [UIColor clearColor];
	m_tableView.delegate = self;
	m_tableView.dataSource = self;
	m_tableView.separatorColor = [UIColor clearColor];
	
	return self;
}


- (void) levelLayer:(GameDataManager*)manager
{
	[super levelLayer:manager];
	[m_tableView removeFromSuperview];
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return 35;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString* identifier = @"GameInfoCellIdentifier";
	GameInfoCell* tableViewCell = (GameInfoCell*)[m_tableView dequeueReusableCellWithIdentifier:identifier];
	if (tableViewCell == nil)
	{ 
		NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"GameInfoCell" owner:nil options:nil];
		for (id currentObject in nib)
		{
			if ([currentObject isKindOfClass:[GameInfoCell class]])
			{
				tableViewCell = currentObject;
				break;
			}
		}
	}
	
	tableViewCell.userInteractionEnabled = NO;
	tableViewCell.m_info.backgroundColor = [UIColor clearColor];
	
	NSInteger idx = [indexPath row];
	NSString* info = [m_infoArray objectAtIndex:idx];
	NSString* infoText = [NSString stringWithFormat:@"%d. %@", idx+1, info];
	tableViewCell.m_info.text = infoText;
	
	if (idx % 2 == 0)
	{
		tableViewCell.m_info.textColor = [UIColor yellowColor];
	}
	else
	{
		tableViewCell.m_info.textColor = [UIColor whiteColor];
	}
	
	return tableViewCell;
}


- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return [m_infoArray count];
}


- (void) dealloc
{
	[m_infoArray release];
	[m_tableView release];
	[super dealloc];
}

@end
