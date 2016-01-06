//
//  GameNewLayer.h
//  Clearis
//
//  Created by 881 on 10-3-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "GameStateLayer.h"
#import "GameGradeLayer.h"



@interface GameNewLayer : GameStateLayer<UITextFieldDelegate, GameGradeDelegate>
{
	UITextField*		m_nameField;
	GameGradeLayer*		m_levelLayer;
	int					m_initLevel;
	bool				m_isLevelLocked;
}

- (id) initWithDataManager:(GameDataManager*)manager;

- (void) startCancel:(id)sender;
- (void) startStart:(id)sender;

@end
