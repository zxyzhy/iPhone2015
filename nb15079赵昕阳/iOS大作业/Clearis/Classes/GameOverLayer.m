//
//  GameOverLayer.m
//  Clearis
//
//  Created by 881 on 10-3-15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameOverLayer.h"
#import "GameAppDelegate.h"
#import "GameMenu.h"
#import "GameNumberLayer.h"


@implementation GameOverLayer


- (id) initWithDataManager:(GameDataManager*)manager
{
	[super initWithDataManager:manager];
	
	CGSize contentSize = self.contentSize;
	
	Sprite* gameoverSp = [Sprite spriteWithFile:@"GameOverPic.png"];
	gameoverSp.position = ccp(160, contentSize.height - 40);
	[self addChild:gameoverSp];
	
	
	Sprite* gameOverFrame = [Sprite spriteWithFile:@"GameOverFrame.png"];
	gameOverFrame.anchorPoint = ccp(0.5, 0.5);
	gameOverFrame.position = ccp(160, contentSize.height - 190);
	[self addChild:gameOverFrame];
	
	int ypos = contentSize.height - 120;
	Sprite* helloSp = [Sprite spriteWithFile:@"HelloText.png"];
	helloSp.position = ccp(160, ypos);
	[self addChild:helloSp];
	
	ypos -= 50;
	Label* nameLabel = [Label labelWithString:manager.playerName fontName:@"Marker Felt" fontSize:30];
	nameLabel.position = ccp(160, ypos);
	nameLabel.color = ccRED;
	[self addChild:nameLabel];
	
	ypos -= 50;
	Sprite* youScoreSp = [Sprite spriteWithFile:@"YourScoreText.png"];
	youScoreSp.position = ccp(160, ypos);
	[self addChild:youScoreSp];
	
	ypos -= 50;
	GameNumberLayer* numberLayer = [GameNumberLayer layerWithNumber:m_dataManager.score];
	numberLayer.anchorPoint = ccp(0.5, 0.5);
	numberLayer.position = ccp(160, ypos + 10);
	[self addChild:numberLayer];
	
	MenuItemImage* mi0 = [MenuItemImage itemFromNormalImage:@"RetryButton.png" 
											  selectedImage:@"RetryButton_p.png" 
													 target:self 
												   selector:@selector(startRetry:)];
	GameMenu* menu0 = [GameMenu menuWithItems:mi0, nil];
	menu0.position = ccp(contentSize.width * 0.5, 115);
	[self addChild:menu0];
	menu0.isTouchEnabled = FALSE;
	
	MenuItemImage* mi1 = [MenuItemImage itemFromNormalImage:@"MainMenuButton.png" 
											  selectedImage:@"MainMenuButton_p.png" 
													 target:self 
												   selector:@selector(startMenu:)];
	GameMenu* menu1 = [GameMenu menuWithItems:mi1, nil];
	menu1.position = ccp(contentSize.width * 0.5, 45);
	[self addChild:menu1];
	menu1.isTouchEnabled = FALSE;
	
	
	return self;
}


- (void) startMenu:(id)sender
{
	[[GameAppDelegate instance] startMainMenu:true];
}

- (void) startRetry:(id)sender
{
	m_dataManager.score = 0;
	m_dataManager.hasDataSaved = false;
	[[GameAppDelegate instance] startStartNewGame:false];
}


@end
