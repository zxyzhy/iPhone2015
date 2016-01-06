//
//  MainMenu.m
//  Clearis
//
//  Created by 881 on 10-2-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameMenuLayer.h"
#import	"GameAppDelegate.h"
#import "GameMenu.h"
#import "SimpleAudioEngine.h"
#import "global.h"


#define kResumeButtonTag	1000


@implementation GameMenuLayer



- (id) initWithDataManagerWithAnimate:(GameDataManager*)manager
{
	[self initWithDataManager:manager];
	
	// elastic effect
	CGSize s = [[Director sharedDirector] winSize];
	NSArray* array = [self children];
	
	int i=0;
	for( CocosNode *child in array ) 
	{
		if ([child isKindOfClass:[Menu class]])
		{
			CGPoint dstPoint = child.position;
			int offset = s.width/2 + 50;
			if( i % 2 == 0)
				offset = -offset;
			child.position = ccp( dstPoint.x + offset, dstPoint.y);
			[child runAction: 
			 [EaseElasticOut actionWithAction:
			  [MoveTo actionWithDuration:2 position:dstPoint]
									   period: 0.35f]
			 ];
			i++;
		}
	}
	
	return self;	
}


- (id) initWithDataManager:(GameDataManager*)manager
{
	[super initWithDataManager:manager];
	
	CGSize contentSize = [self contentSize];
		
	Sprite* logoImage = [Sprite spriteWithFile:@"MenuLogo.png"];
	logoImage.position = ccp(contentSize.width * 0.5, contentSize.height - 50);
	[self addChild:logoImage];
	
	MenuItemImage* mi0 = [MenuItemImage itemFromNormalImage:@"MenuNew.png" 
											 selectedImage:@"MenuNew_p.png" 
													target:self 
												  selector:@selector(startNew:)];
	GameMenu* menu0 = [GameMenu menuWithItems:mi0, nil];
	menu0.position = ccp(contentSize.width * 0.5, contentSize.height - 130);
	menu0.isTouchEnabled = NO;
	[self addChild:menu0];
	
	const CGFloat divHeight = 72;
	const CGFloat menuXPos = contentSize.width * 0.5;
	MenuItemImage* mi1 = [MenuItemImage itemFromNormalImage:@"MenuResume.png" 
											  selectedImage:@"MenuResume_p.png" 
													 target:self 
												   selector:@selector(startResume:)];
	
	GameMenu* menu1 = [GameMenu menuWithItems:mi1, nil];
	menu1.position = ccp(menuXPos, menu0.position.y - divHeight);
	menu1.isTouchEnabled = NO;
	[self addChild:menu1 z:0 tag:kResumeButtonTag];
		
	if (!m_dataManager.hasDataSaved)
	{
		menu1.color = ccGRAY;
	}
	

	MenuItemImage* mi2 = [MenuItemImage itemFromNormalImage:@"MenuOptions.png" 
											  selectedImage:@"MenuOptions_p.png" 
													 target:self 
												   selector:@selector(startOptions:)];
	GameMenu* menu2 = [GameMenu menuWithItems:mi2, nil];
	menu2.position = ccp(menuXPos, menu1.position.y - divHeight);
	menu2.isTouchEnabled = NO;
	[self addChild:menu2];
	
	MenuItemImage* mi3 = [MenuItemImage itemFromNormalImage:@"MenuScores.png" 
											  selectedImage:@"MenuScores_p.png" 
													 target:self 
												   selector:@selector(startScores:)];
	GameMenu* menu3 = [GameMenu menuWithItems:mi3, nil];
	menu3.position = ccp(menuXPos, menu2.position.y - divHeight);
	menu3.isTouchEnabled = NO;
	[self addChild:menu3];
	
	MenuItemImage* mi4 = [MenuItemImage itemFromNormalImage:@"MenuHelp.png" 
											  selectedImage:@"MenuHelp_p.png" 
													 target:self 
												   selector:@selector(startHelp:)];
	GameMenu* menu4 = [GameMenu menuWithItems:mi4, nil];
	menu4.position = ccp(menuXPos, menu3.position.y - divHeight);
	menu4.isTouchEnabled = NO;
	[self addChild:menu4];
		
	[GameUtil playerBKMusic:@"MenuBkMusic.mp3" volume:[m_dataManager realMusicVolume]];
	
	return self;
}


- (void) enterLayer
{
	[super enterLayer];
	Menu* m = (Menu*)[self getChildByTag:kResumeButtonTag];
	if (!m_dataManager.hasDataSaved)
	{
		m.isTouchEnabled = NO;
	}
}


- (void) startNew:(id) sender
{
	[[GameAppDelegate instance] startGameNew:false];
}

- (void) startResume:(id) sender
{
	[[GameAppDelegate instance] startStartNewGame:false];
}

- (void) startOptions:(id) sender
{
	[[GameAppDelegate instance] startGameOptions:false];
}

- (void) startScores:(id) sender
{
	[[GameAppDelegate instance] startGameScores:false];
}

- (void) startHelp:(id) sender
{
	[[GameAppDelegate instance] startGameHelp:false];
}

@end
