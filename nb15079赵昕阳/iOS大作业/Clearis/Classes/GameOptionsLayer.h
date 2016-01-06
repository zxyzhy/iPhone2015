//
//  GameOptionsLayer.h
//  Clearis
//
//  Created by 881 on 10-3-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "GameSettingLayer.h"


@interface GameOptionsLayer : GameSettingLayer
{
	bool	m_isSoundOn;
	bool	m_isMusicOn;
	int		m_soundVolume;
	int		m_musicVolume;
}


- (id) initWithDataManager:(GameDataManager*)manager;

- (void) startMenu:(id)sender;
- (void) startReset:(id)sender;

@end
