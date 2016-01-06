//
//  GameSettingLayer.m
//  Clearis
//
//  Created by 881 on 10-3-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameSettingLayer.h"
#import "GameMenu.h"
#import "GameAppDelegate.h"
#import "GameGradeLayer.h"
#import "SimpleAudioEngine.h"


@implementation GameSettingLayer


- (id) initWithDataManager:(GameDataManager*)manager
{
	[super initWithDataManager:manager];
	
	CGSize contentSize = self.contentSize;
		
	m_soundLayer = [[GameGradeLayer alloc] initWithLabelName:@"SoundText.png" 
													 toggle0:@"On"
													 toggle1:@"Off"
													delegate:self];
	m_soundLayer.anchorPoint = ccp(0.5, 0.5);
	m_soundLayer.position = ccp(160, contentSize.height - 75);
	[self addChild:m_soundLayer];
	[m_soundLayer disableMenu];
	m_soundLayer.grade = m_dataManager.soundVolume;
	m_soundLayer.selectedIndex = m_dataManager.isSoundOn ? 0 : 1;
	
	m_musicLayer = [[GameGradeLayer alloc] initWithLabelName:@"MusicText.png" 
													 toggle0:@"On"
													 toggle1:@"Off"
													delegate:self];
	m_musicLayer.anchorPoint = ccp(0.5, 0.5);
	m_musicLayer.position = ccp(160, contentSize.height - 205);
	[self addChild:m_musicLayer];
	[m_musicLayer disableMenu];
	m_musicLayer.grade = m_dataManager.musicVolume;
	m_musicLayer.selectedIndex = m_dataManager.isMusicOn ? 0 : 1;
	
	return self;
}


- (void) enterLayer
{
	[super enterLayer];
	[m_soundLayer enableMenu];
	[m_musicLayer enableMenu];
}


- (void) levelLayer:(GameDataManager*)manager
{
	[super levelLayer:manager];
	[m_soundLayer disableMenu];
	[m_musicLayer disableMenu];
}


- (void) changeLayer:(GameGradeLayer*)layer grade:(int)grade
{
	SimpleAudioEngine* engin = [SimpleAudioEngine sharedEngine];
	
	if (layer == m_soundLayer)
	{
		m_dataManager.soundVolume = grade;
		engin.effectsVolume = [m_dataManager realSoundVolume];		
	}
	else if (layer == m_musicLayer)
	{
		m_dataManager.musicVolume = grade;
		engin.backgroundMusicVolume = [m_dataManager realMusicVolume];
	}
}


- (void) changeLayer:(GameGradeLayer*)layer selectIdx:(int)idx
{
	SimpleAudioEngine* engin = [SimpleAudioEngine sharedEngine];
	if (layer == m_soundLayer)
	{
		m_dataManager.isSoundOn = (idx == 0);
		engin.effectsVolume = [m_dataManager realSoundVolume];
	}
	else if (layer == m_musicLayer)
	{
		m_dataManager.isMusicOn = (idx == 0);
		engin.backgroundMusicVolume = [m_dataManager realMusicVolume];
	}
}


- (void) dealloc
{
	[m_soundLayer release];
	[m_musicLayer release];
	[super dealloc];
}

@end
