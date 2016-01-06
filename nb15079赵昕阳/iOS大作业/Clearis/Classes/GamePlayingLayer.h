//
//  GameLayer.h
//  Clearis
//
//  Created by 881 on 10-2-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "GameBoard.h"
#import "GameNextBall.h"
#import "GameLevel.h"
#import "GameScore.h"
#import "GameCurBall.h"
#import "GameStateLayer.h"


@interface GamePlayingLayer: GameStateLayer
{
	GameScore*			m_gameScore;
	GameNextBall*		m_gameNextBall;
	GameBoard*			m_gameBoard;
	GameLevel*			m_gameLevel;
	Menu*				m_pauseButton;
	int					m_boradXPos;
	int					m_curKindIdx;
	int					m_curXIdx;
	int					m_initLevel;
	bool				m_isGameOver;
	bool				m_isLevelLocked;
}

- (id) initWithDataManager:(GameDataManager*)manager;

- (void) startPauseButton:(id) sender;
- (void) changeCurrentBall:(int) idx;

- (void) accumulateScores:(int) addedScore;

- (void) lockGameInput;
- (void) unLockGameInput;

- (void) beginGameOverAnimate;
- (void) endGameOverAnimate;

@end
