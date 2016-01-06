//
//  GameLayer.m
//  Clearis
//
//  Created by 881 on 10-2-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GamePlayingLayer.h"
#import "global.h"
#import "GameAppDelegate.h"
#import "GameMenu.h"
#import "SimpleAudioEngine.h"

#define kCurCellTag			1001
#define kCurStripTag		1002
#define kCurShotStripTag	1003

#define kCurCellYPos	29


int CalIntervalWithLevel(int level)
{
	int interval[11] = { 10, 9, 8, 7, 6, 5, 4, 3, 2, 1.5 };
	return interval[level];
}


int CalLevelWithScores(int firstLevel, int score)
{
	int level = (score / 10000) + firstLevel;
	if (level > 9)
	{
		level = 9;
	}
	return level;
}


@implementation GamePlayingLayer


- (int) calXDirIdx:(CGPoint) pt
{
	int xPos = pt.x - kXDirOffset;
	int xIdx = xPos / kCellWidth;
	
	if (xIdx < 0)
	{
		xIdx = 0;
	}
	
	if (xIdx >= kXDirCellNum)
	{
		xIdx = kXDirCellNum - 1;
	}
	
	return xIdx;
}


- (void) enterLayer
{
	[super enterLayer];
	[self unLockGameInput];
	[m_gameBoard startTimer];
	[self schedule:@selector(step:) interval:CalIntervalWithLevel(m_gameLevel.level)];
}



- (void) levelLayer:(GameDataManager*)manager
{
	[super levelLayer:manager];
	[self lockGameInput];
	[m_gameBoard stopTimer];
	[self unschedule:@selector(step:)];
	
	manager.hasDataSaved = false;
	manager.score = m_gameScore.score;

	if (!m_isGameOver)
	{
		manager.hasDataSaved = true;
		GamePlayingData* data = [manager getPlayingData];

		data->m_version = 1;
		data->m_level = m_gameLevel.level;
		data->m_scores = m_gameScore.score;
		data->m_curKind = m_curKindIdx;
		data->m_nextKind = [m_gameNextBall getNextIdx];
		data->m_curXIdx = m_curXIdx;
		data->m_initLevel = m_initLevel;
		data->m_isLevelLocked = m_isLevelLocked;
		
		[m_gameBoard fillKindData:data];
	}
	else
	{
		[manager insertScore:manager.score player:manager.playerName isLevelLocked:m_isLevelLocked];
	}
}


- (id) initWithDataManager:(GameDataManager*)manager
{
	[super initWithDataManager:manager];
	
	GamePlayingData* playingData = [manager getPlayingData];
	int score = manager.score;
	int level = manager.initLevel;
	
	m_initLevel = manager.initLevel;
	m_isLevelLocked = manager.isLevelLocked;
	
	if (manager.hasDataSaved)
	{
		score = playingData->m_scores;
		level = playingData->m_level;
		m_initLevel = playingData->m_initLevel;
		m_isLevelLocked = playingData->m_isLevelLocked;
	}
	
	m_isGameOver = false;
	
	m_gameBoard = [[GameBoard alloc] initWithDataManager:manager];
	m_gameBoard.gamePlayingLayer = self;
	
	m_gameNextBall = [[GameNextBall alloc] init];
	m_gameLevel = [[GameLevel alloc] initWithLevel:level isLocked:m_isLevelLocked];
	m_gameScore = [[GameScore alloc] initWithScore:score];
	
	int xpos = 320 - m_gameNextBall.contentSize.width;
	int ypos = 480 - m_gameNextBall.contentSize.height;
	m_gameNextBall.anchorPoint = ccp(0.0, 0.0);
	m_gameNextBall.position = ccp(xpos, ypos);
	[self addChild:m_gameNextBall];
	
	ypos -= m_gameScore.contentSize.height + 10;
	m_gameScore.anchorPoint = ccp(0.0, 0.0);
	m_gameScore.position = ccp(xpos, ypos);
	[self addChild:m_gameScore];
	
	ypos -= m_gameLevel.contentSize.height + 10;
	m_gameLevel.anchorPoint = ccp(0.0, 0.0);
	m_gameLevel.position = ccp(xpos, ypos);
	[self addChild:m_gameLevel];
	
	MenuItemImage* mi0 = [MenuItemImage itemFromNormalImage:@"PauseButton.png" 
											  selectedImage:@"PauseButton_p.png" 
													 target:self 
												   selector:@selector(startPauseButton:)];
	m_pauseButton = [GameMenu menuWithItems:mi0, nil];
	m_pauseButton.position = ccp(320 - 20, 20);
	[self addChild:m_pauseButton];
	m_pauseButton.isTouchEnabled = FALSE;
	
	
	m_gameBoard.anchorPoint = ccp(0, 0);
	[self addChild:m_gameBoard];
	
	m_curXIdx = manager.hasDataSaved ? playingData->m_curXIdx : 0;
	m_curKindIdx = manager.hasDataSaved ? playingData->m_curKind : [m_gameNextBall getNextIdx];
	if (manager.hasDataSaved)
	{
		[m_gameNextBall setNextBall:playingData->m_nextKind];
	}
	
	[self changeCurrentBall:m_curKindIdx];

	
	[GameUtil playerBKMusic:@"GameBkMusic.mp3" volume:[m_dataManager realMusicVolume]];
	
	return self;	
}


- (void) startPauseButton:(id) sender
{
	[[GameAppDelegate instance] startGamePause:false];
}


-(void) step: (ccTime) delta
{
	[m_gameBoard genNewLine];
}

- (void) delloc
{
	[m_gameScore release];
	[m_gameLevel release];
	[m_gameNextBall release];
	[m_gameBoard release];
	[super dealloc];
}


- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	location = [[Director sharedDirector] convertToGL: location];
	
	int xIdx = [self calXDirIdx:location];
	if (m_curXIdx != xIdx)
	{
		m_curXIdx = xIdx;
		[self changeCurrentBall:m_curKindIdx];
	}
	
	return kEventHandled;
}


- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	location = [[Director sharedDirector] convertToGL: location];
	
	int xIdx = [self calXDirIdx:location];
	if (m_curXIdx != xIdx)
	{
		m_curXIdx = xIdx;
		[self changeCurrentBall:m_curKindIdx];
	}
	
	return kEventHandled;
}


- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	location = [[Director sharedDirector] convertToGL: location];
	
	if (![m_gameBoard addCellWillShot:m_curXIdx kindIdx:m_curKindIdx])
	{
		return kEventHandled;
	}
	

	m_curKindIdx = [m_gameNextBall getNextIdx];
	[m_gameNextBall genNextBall];
	[self changeCurrentBall:m_curKindIdx];
				 
	return kEventHandled;
}



- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	return [self ccTouchesEnded:touches withEvent:event];
}


- (void) lockGameInput
{
	self.isTouchEnabled = FALSE;
	m_pauseButton.isTouchEnabled = FALSE;
}


- (void) unLockGameInput
{
	self.isTouchEnabled = TRUE;
	m_pauseButton.isTouchEnabled = TRUE;
}


- (void) changeCurrentBall:(int) idx
{
	m_curKindIdx = idx;
	
	// 清除旧的sprite
	CocosNode* s1 = [self getChildByTag:kCurCellTag];
	[self removeChild:s1 cleanup:YES];

	CocosNode* s3 = [self getChildByTag:kCurShotStripTag];
	[self removeChild:s3 cleanup:YES];
	
	[m_gameBoard setStripInfoColorIdx:m_curKindIdx posIdx:m_curXIdx];
	
	GameCurBall* curBall = [GameCurBall layerWithBallIdx:m_curKindIdx xIdx:m_curXIdx];
	[self addChild:curBall z:0 tag:kCurCellTag];
}


- (void) beginGameOverAnimate
{
	m_isGameOver = true;
	[self lockGameInput];
}


- (void) endGameOverAnimate
{
	[[GameAppDelegate instance] startGameOver:false];
}


- (void) accumulateScores:(int) addedScore
{
	int score = m_gameScore.score;
	score += addedScore;
	
	m_gameScore.score = score;
	
	int level = m_gameLevel.level;
	int tmpLevel = CalLevelWithScores(m_initLevel, score);
	if (level != tmpLevel && !m_isLevelLocked)
	{
		m_gameLevel.level = tmpLevel;
		[self unschedule:@selector(step:)];
		[self schedule:@selector(step:) interval:CalIntervalWithLevel(tmpLevel)];
	}
}


@end
