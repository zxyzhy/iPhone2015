//
//  GameBoard.h
//  Clearis
//
//  Created by 881 on 10-2-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "ConstDef.h"
#import "GameDataManager.h"


typedef struct
{
	int				m_kindIdx;
	AtlasSprite*	m_sprite;
	bool			m_needToDel;
} GameCell;

typedef struct
{
	int		m_xIdx;
	int		m_yIdx;
} GameCellPosition;


inline static GameCellPosition Pos_Make(int xIdx, int yIdx)
{
	GameCellPosition pos = { xIdx, yIdx };
	return pos;
}


inline static void GameCell_Reset(GameCell* cell)
{
	cell->m_kindIdx = kKindBlankIndex;
	cell->m_sprite = nil;
	cell->m_needToDel = false;
}

inline static bool GameCell_IsBlankCell(GameCell* cell)
{
	if (cell->m_kindIdx == kKindBlankIndex)
	{
		assert(cell->m_sprite == nil);
		return true;
	}
	return false;
}


typedef enum
	{
		State_Removing,
		State_FallingDown,
		State_GeningNewLine,
		State_GameOverAnimate,
		State_GameOver,
		State_Nothing,
	} GameBoardState;

//////////////////////////////////////

@class GamePlayingLayer;
@interface GameBoard : Layer 
{
	GameCell			m_cells[kXDirCellNum][kYDirCellNum];	// 注意这里的x, y顺序
	AtlasSpriteManager*	m_ballsManager;
	AtlasSpriteManager*	m_stripeManager;
	CGFloat				m_stripTimeCounter;
	CGFloat				m_removeTimeCounter;
	NSMutableArray*		m_shottingBalls;
	int					m_shottingBallCounter[kXDirCellNum];
	NSMutableArray*		m_fallingDwonBalls;
	GameBoardState		m_gameBoardState;
	GamePlayingLayer*	m_gamePlayingLayer;
	int					m_chainTime;
	int					m_stripColorIdx;
	int					m_stripPosIdx;
	int					m_stripBottomPos;
}

@property (nonatomic, assign)	GamePlayingLayer* gamePlayingLayer;


- (void) stopTimer;
- (void) startTimer;

- (void) setStripInfoColorIdx:(int)idx0 posIdx:(int)idx1;

- (id) initWithDataManager:(GameDataManager*)manager;
- (void) fillKindData:(GamePlayingData*) data;

- (int) lastBlankIndex:(int) xIdx;
- (void) addNewCellxIdx:(int) xIdx yIdx:(int)yIdx kindIdx:(int)kindIdx;
- (void) removeCellxIdx:(int) xIdx yIdx:(int)yIdx;
- (void) genNewLine;
- (void) removePositionArray;

- (bool) addCellWillShot:(int) xIdx kindIdx:(int)kindIdx;
- (void) clearResoucre;
- (void) updateShotStrip:(ccTime)t;
- (void) playScoresAnimateBaseScore:(int) score chainTime:(int)time;

@end
