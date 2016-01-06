//
//  GameOptionsLayer.m
//  Clearis
//
//  Created by 881 on 10-3-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameOptionsLayer.h"
#import "GameMenu.h"
#import "GameGradeLayer.h"
#import "GameAppDelegate.h"
#import "SimpleAudioEngine.h"


@implementation GameOptionsLayer



- (id) initWithDataManager:(GameDataManager*)manager
{
	[super initWithDataManager:manager];
	
	CGSize contentSize = self.contentSize;
	MenuItemImage* mi0 = [MenuItemImage itemFromNormalImage:@"ResetButton.png" 
											  selectedImage:@"ResetButton_p.png" 
													 target:self 
												   selector:@selector(startReset:)];
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
	
	m_isSoundOn = m_dataManager.isSoundOn;
	m_isMusicOn = m_dataManager.isMusicOn;
	m_soundVolume = m_dataManager.soundVolume;
	m_musicVolume = m_dataManager.musicVolume;
	
	return self;
}


- (void) startMenu:(id)sender
{
	[[GameAppDelegate instance] startMainMenu:true];
}


- (void) startReset:(id)sender
{
	m_dataManager.isSoundOn = m_isSoundOn;
	m_dataManager.isMusicOn = m_isMusicOn;
	m_dataManager.soundVolume = m_soundVolume;
	m_dataManager.musicVolume = m_musicVolume;
	
	SimpleAudioEngine* engin = [SimpleAudioEngine sharedEngine];
	engin.backgroundMusicVolume = [m_dataManager realMusicVolume];
	engin.effectsVolume = [m_dataManager realSoundVolume];
	
	m_musicLayer.grade = m_musicVolume;
	m_soundLayer.grade = m_soundVolume;
	m_musicLayer.selectedIndex = m_isSoundOn ? 0 : 1;
	m_soundLayer.selectedIndex = m_isMusicOn ? 0 : 1;
}

@end
