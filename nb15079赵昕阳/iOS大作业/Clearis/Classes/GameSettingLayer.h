//
//  GameSettingLayer.h
//  Clearis
//
//  Created by 881 on 10-3-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "GameStateLayer.h"
#import "GameGradeLayer.h"


@interface GameSettingLayer : GameStateLayer<GameGradeDelegate>
{
	GameGradeLayer*	m_soundLayer;
	GameGradeLayer*	m_musicLayer;
}

- (id) initWithDataManager:(GameDataManager*)manager;

@end
