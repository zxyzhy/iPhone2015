//
//  GameBoard.m
//  Clearis
//
//  Created by 881 on 10-2-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameBoard.h"
#import "global.h"
#import "SimpleAudioEngine.h"
#import "ConstDef.h"
#import "GamePlayingLayer.h"
#import "GameFloatingScores.h"
#import <vector>


#define kRemovingAnimateTime		0.15
#define kFallingAnimateTime			0.2
#define kGeningNewLineAnimateTime	0.2
#define kShottingAnimateTime		0.2
#define kRemovingCounterTime		0.8



typedef struct BallFallingDownInfo_tag
	{
		CGFloat	m_leftDist;
		CGFloat m_delta;
	} BallFallingDownInfo;

inline static BallFallingDownInfo* New_BallFallingDownInfo(CGFloat leftDist, CGFloat delta)
{
	BallFallingDownInfo* info = (BallFallingDownInfo*)malloc(sizeof(BallFallingDownInfo));
	info->m_leftDist = leftDist;
	info->m_delta = delta;
	return info;
}


typedef std::vector<GameCellPosition>	CellPositionArray;
static CellPositionArray	s_needCheckArray;
static CellPositionArray	s_needRemoveArray;
static bool					s_needGeningNewLine;
static bool					s_needGameOver;
static int					s_needFallingDownArray[kXDirCellNum];


static inline bool AddToArray(GameCellPosition pos, CellPositionArray& array)
{
	for (int i = 0; i < (int)array.size(); i++)
	{
		if (pos.m_xIdx == array[i].m_xIdx && pos.m_yIdx == array[i].m_yIdx)
		{
			return false;
		}
	}
	
	array.push_back(pos);
	return true;	
}


static inline bool AddToCheckArray(GameCellPosition pos)
{
	return AddToArray(pos, s_needCheckArray);
}


static inline CGFloat GetXPos(int xIdx)
{
	assert(xIdx >= 0 && xIdx < kXDirCellNum);
	return (xIdx + 0.5)* kCellWidth + kXDirOffset;
}


static inline CGFloat GetYPos(int yIdx)
{
	return (480 - kYDirOffset - (yIdx + 0.5) * kCellWidth);
}

static inline CGPoint GetPostion(int xIdx, int yIdx)
{
	return ccp(GetXPos(xIdx), GetYPos(yIdx));
}



@implementation GameBoard

@synthesize gamePlayingLayer = m_gamePlayingLayer;

- (int) findLastYIdxBlank:(int) xIdx
{
	assert(xIdx >= 0 && xIdx < kXDirCellNum);
	for (int idx = kYDirCellNum; idx > 0; idx--)
	{
		if (!GameCell_IsBlankCell(&m_cells[xIdx][idx-1]))
		{
			return idx;
		}
	}
	return 0;
}


- (id) initWithDataManager:(GameDataManager*)manager
{
	[super init];
	
	Sprite* bg = [Sprite spriteWithFile:@"Board_bg.png"];
	self.contentSize = bg.contentSize;
	bg.anchorPoint = ccp(0.0, 0.0);
	
	[self addChild:bg];
	self.relativeAnchorPoint = TRUE;
	
	m_stripeManager = [[AtlasSpriteManager alloc] initWithFile:@"ShotStripes.png" capacity:10];
	[self addChild:m_stripeManager];
	
	m_ballsManager = [[AtlasSpriteManager alloc] initWithFile:@"Balls.png" capacity:10];
	[self addChild:m_ballsManager];
	
	// 初始化
	for (int i = 0; i < kXDirCellNum; i++)
	{
		for (int j = 0; j < kYDirCellNum; j++)
		{
			GameCell_Reset(&m_cells[i][j]);
		}
	}
	
	if (manager.hasDataSaved)
	{
		GamePlayingData* data = [manager getPlayingData];
		for (int i = 0; i < kXDirCellNum; i++)
		{
			for (int j = 0; j < kYDirCellNum; j++)
			{
				int kind = data->m_kindIdx[i][j];
				if (kind != kKindBlankIndex)
				{
					[self addNewCellxIdx:i yIdx:j kindIdx:kind];
				}
			}
		}
	}
	else
	{
		for (int i = 0; i < kXDirCellNum; i++)
		{
			[self addNewCellxIdx:i yIdx:0 kindIdx:rand() % kKindMaxNumber];
			[self addNewCellxIdx:i yIdx:1 kindIdx:rand() % kKindMaxNumber];
		}		
	}
	
	
	for (int i = 0; i < kXDirCellNum; i++)
	{
		m_shottingBallCounter[i] = 0;
		s_needFallingDownArray[i] = -1;
	}
	s_needGameOver = false;
	s_needGeningNewLine = false;

	
	m_shottingBalls = [[NSMutableArray alloc] init];
	m_fallingDwonBalls = [[NSMutableArray alloc] init];

	m_gameBoardState = State_Nothing;
	
	m_stripColorIdx = 0;
	m_stripPosIdx = 0;
	m_stripBottomPos = 470;
	m_stripTimeCounter = 0.0;
	m_removeTimeCounter = 0.0;
	m_chainTime = 1;
	m_gamePlayingLayer = nil;
	
	return self;
}


- (void) stopTimer
{
	[self unschedule:@selector(timeStep:)];
}

- (void) startTimer
{
	[self schedule:@selector(timeStep:)];
}





// 此函数检查(xIdx, yIdx)中的格子, 看看可不可以跟它周围的格子进行消除
- (void) addNeedToRemoveXIdx:(int) xIdx yIdx:(int)yIdx array:(CellPositionArray*)array
{
	assert(xIdx >= 0 && xIdx < kXDirCellNum);
	assert(yIdx >= 0 && yIdx < kYDirCellNum);
	
	CellPositionArray& refArray = *array;
	if (GameCell_IsBlankCell(&m_cells[xIdx][yIdx]))
	{
		return;
	}
	
	for (int i = 0; i < (int)refArray.size(); i++)
	{
		if (refArray[i].m_xIdx == xIdx && refArray[i].m_yIdx == yIdx)
		{
			return;
		}
	}
	
	// 向左右扫描, 将相同类型的cell放到数组中
	CellPositionArray xDirArray;
	for (int i = xIdx - 1; i >= 0; i--)
	{
		if (m_cells[xIdx][yIdx].m_kindIdx == m_cells[i][yIdx].m_kindIdx)
		{
			GameCellPosition pos = { i, yIdx };
			xDirArray.push_back(pos);
		}
		else
		{
			break;
		}
	}
	
	for (int i = xIdx+1; i < kXDirCellNum; i++)
	{
		if (m_cells[xIdx][yIdx].m_kindIdx == m_cells[i][yIdx].m_kindIdx)
		{
			GameCellPosition pos = { i, yIdx };
			xDirArray.push_back(pos);
		}
		else
		{
			break;
		}
	}
	
	// 向上下扫描, 将相同类型的cell放到数组中
	CellPositionArray yDirArray;
	for (int i = yIdx - 1; i >= 0; i--)
	{
		if (m_cells[xIdx][yIdx].m_kindIdx == m_cells[xIdx][i].m_kindIdx)
		{
			GameCellPosition pos = { xIdx, i };
			yDirArray.push_back(pos);
		}
		else
		{
			break;
		}
	}
	
	for (int i = yIdx+1; i < kYDirCellNum; i++)
	{
		if (m_cells[xIdx][yIdx].m_kindIdx == m_cells[xIdx][i].m_kindIdx)
		{
			GameCellPosition pos = { xIdx, i };
			yDirArray.push_back(pos);
		}
		else
		{
			break;
		}
	}
	
	// 左对角线扫描
	CellPositionArray leftCornerArray;
	for (int i = xIdx - 1, j = yIdx - 1; i >= 0 && j >= 0; i--, j--)
	{
		if (m_cells[xIdx][yIdx].m_kindIdx == m_cells[i][j].m_kindIdx)
		{
			GameCellPosition pos = { i, j};
			leftCornerArray.push_back(pos);
		}
		else
		{
			break;
		}
	}
	
	for (int i = xIdx + 1, j = yIdx + 1; i < kXDirCellNum && j < kYDirCellNum; i++, j++)
	{
		if (m_cells[xIdx][yIdx].m_kindIdx == m_cells[i][j].m_kindIdx)
		{
			GameCellPosition pos = { i, j};
			leftCornerArray.push_back(pos);
		}
		else
		{
			break;
		}
	}
	
	// 右对角线扫描
	CellPositionArray rightCornerArray;
	for (int i = xIdx - 1, j = yIdx + 1; i >= 0 && j < kYDirCellNum; i--, j++)
	{
		if (m_cells[xIdx][yIdx].m_kindIdx == m_cells[i][j].m_kindIdx)
		{
			GameCellPosition pos = { i, j};
			rightCornerArray.push_back(pos);
		}
		else
		{
			break;
		}
	}
	
	for (int i = xIdx + 1, j = yIdx - 1; i < kXDirCellNum && j >= 0; i++, j--)
	{
		if (m_cells[xIdx][yIdx].m_kindIdx == m_cells[i][j].m_kindIdx)
		{
			GameCellPosition pos = { i, j};
			rightCornerArray.push_back(pos);
		}
		else
		{
			break;
		}
	}

	bool needAtCurr = false;
	if (xDirArray.size() >= 2)
	{
		for (int i = 0; i < (int)xDirArray.size(); i++)
		{
			AddToArray(xDirArray[i], refArray);
		}
		needAtCurr = true;
	}
	
	if (yDirArray.size() >= 2)
	{
		for (int i = 0; i < (int)yDirArray.size(); i++)
		{
			AddToArray(yDirArray[i], refArray);
		}
		needAtCurr = true;
	}
	
	if (leftCornerArray.size() >= 2)
	{
		for (int i = 0; i < (int)leftCornerArray.size(); i++)
		{
			AddToArray(leftCornerArray[i], refArray);
		}
		needAtCurr = true;
	}
	
	if (rightCornerArray.size() >= 2)
	{
		for (int i = 0; i < (int)rightCornerArray.size(); i++)
		{
			AddToArray(rightCornerArray[i], refArray);
		}
		needAtCurr = true;
	}
	
	if (needAtCurr)
	{
		AddToArray(Pos_Make(xIdx, yIdx), refArray);
	}
}


- (void) topToDownOnlyOneXIdx:(int)xIdx yIdx:(int)yIdx
{
	assert(xIdx >= 0 && xIdx < kXDirCellNum);
	assert(yIdx >= 0 && yIdx < kYDirCellNum);
	
	[self removeCellxIdx:xIdx yIdx:yIdx];
	
	for (int i = yIdx; i > 0; i--)
	{
		m_cells[xIdx][i] = m_cells[xIdx][i-1];
		
		AtlasSprite* sprite = m_cells[xIdx][i].m_sprite;
		if (sprite != nil)
		{
			CGPoint lastPos = GetPostion(xIdx, i);
			CGPoint curPos = sprite.position;
			
			CGFloat leftDist = curPos.y - lastPos.y;
			CGFloat delta = leftDist / kGeningNewLineAnimateTime;
			
			assert(sprite.userData == nil);
			sprite.userData = (void*)New_BallFallingDownInfo(leftDist, delta);
			
			[m_fallingDwonBalls addObject:sprite];
		}
	}
	
	s_needFallingDownArray[xIdx] = yIdx;
	GameCell_Reset(&m_cells[xIdx][0]);
}





- (bool) downToTopXIdx:(int)xIdx
{
	assert(xIdx >= 0 && xIdx < kXDirCellNum);
	
	int holeCounter = 0;
	bool result = false;
	
	s_needFallingDownArray[xIdx] = -1;
	for (int i = 0; i < kYDirCellNum; i++)
	{
		if (GameCell_IsBlankCell(&m_cells[xIdx][i]))
		{
			holeCounter++;
		}
		else if (holeCounter != 0)
		{
			assert(i - holeCounter >= 0);
			assert(GameCell_IsBlankCell(&m_cells[xIdx][i - holeCounter]));
			
			m_cells[xIdx][i - holeCounter] = m_cells[xIdx][i];
			AtlasSprite* sprite = m_cells[xIdx][i - holeCounter].m_sprite;
			CGPoint lastPos = GetPostion(xIdx, i - holeCounter);
			CGPoint curPos = sprite.position;
			
			CGFloat leftDist = lastPos.y - curPos.y;
			CGFloat delta = leftDist / kFallingAnimateTime;
			
			assert(sprite.userData == nil);
			sprite.userData = (void*)New_BallFallingDownInfo(leftDist, delta);
			
			[m_fallingDwonBalls addObject:sprite];
			s_needFallingDownArray[xIdx] = i - holeCounter;
			GameCell_Reset(&m_cells[xIdx][i]);
		}
	}
	
	return result;
}


- (void) removePositionArray
{	
	int addedScores = ComputeScores(s_needRemoveArray.size());
	[m_gamePlayingLayer accumulateScores:addedScores * m_chainTime];
	[self playScoresAnimateBaseScore:addedScores chainTime:m_chainTime];
	
	bool needToCheckFallingDown[kXDirCellNum];
	for (int i = 0; i < kXDirCellNum; i++)
	{
		needToCheckFallingDown[i] = false;
	}
	
	for (int i = 0; i < (int)s_needRemoveArray.size(); i++)
	{
		int xIdx = s_needRemoveArray[i].m_xIdx;
		int yIdx = s_needRemoveArray[i].m_yIdx;
		[self removeCellxIdx:xIdx yIdx:yIdx];
		needToCheckFallingDown[xIdx] = true;
	}
		
	s_needRemoveArray.clear();
	
	for (int i = 0; i < kXDirCellNum; i++)
	{
		if (needToCheckFallingDown[i])
		{
			[self downToTopXIdx:i];
		}
	}
}


- (bool) checkNeedGenNewLine
{
	if (!s_needGeningNewLine)
	{
		return false;
	}
	
	s_needGeningNewLine = false;
	
	int newKinds[kXDirCellNum];
	for (int i = 0; i < kXDirCellNum; i++)
	{
		newKinds[i] = rand() % kKindMaxNumber;
	}
	
	int idxes[kXDirCellNum];
	for (int i = 0; i < kXDirCellNum; i++)
	{
		idxes[i] = [self findLastYIdxBlank:i];
		idxes[i] = std::min(idxes[i], kYDirCellNum - 1);
	}
	
	for (int i = 0; i < kXDirCellNum; i++)
	{
		[self topToDownOnlyOneXIdx:i yIdx:idxes[i]];
		[self addNewCellxIdx:i yIdx:0 kindIdx:newKinds[i]];
		
		AtlasSprite* sprite = m_cells[i][0].m_sprite;
		CGPoint lastPos = GetPostion(i, 0);
		CGPoint curPos = GetPostion(i, -1);
		
		sprite.position = curPos;
		
		CGFloat leftDist = curPos.y - lastPos.y;
		CGFloat delta = leftDist / kGeningNewLineAnimateTime;
		
		assert(sprite.userData == nil);
		sprite.userData = (void*)New_BallFallingDownInfo(leftDist, delta);
		
		[m_fallingDwonBalls addObject:sprite];
	}	
	
		
	return true;
}


- (bool) checkNeedToRemove
{
	if (s_needCheckArray.empty())
	{
		return false;
	}
	
	for (int i = 0; i < (int)s_needCheckArray.size(); i++)
	{
		GameCellPosition pos = s_needCheckArray[i];
		[self addNeedToRemoveXIdx:pos.m_xIdx yIdx:pos.m_yIdx array:&s_needRemoveArray];	
	}
	
	s_needCheckArray.clear();
	
	if (s_needRemoveArray.size() < 3)
	{
		s_needRemoveArray.clear();
		return false;
	}
	
	return true;
}


static int		g_gameOverXIdx = 0;
static int		g_gameOverYIdx = kYDirCellNum - 1;
static CGFloat	g_totalTime	= 0;


- (void) dealWithGameOver
{
//	[[SimpleAudioEngine sharedEngine] playEffect:@"GameOver.wav"];
	g_gameOverXIdx = 0;
	g_gameOverYIdx = kYDirCellNum - 1;
	g_totalTime = 0;
	m_gameBoardState = State_GameOverAnimate;
	[self clearResoucre];
}


- (void) genNewLine
{
	// 检查是否已经不可以下落, 就返回false, 表示game over
	for (int i = 0; i < kXDirCellNum; i++)
	{
		if (!GameCell_IsBlankCell(&m_cells[i][kYDirCellNum - 1]))
		{
			s_needGameOver = true;
			break;
		}
	}
	s_needGeningNewLine = true;
}


- (int) lastBlankIndex:(int) xIdx
{
	assert(xIdx >= 0 && xIdx < kXDirCellNum);
	
	int lastIdx = kYDirCellNum - 1;
	for ( ; lastIdx >= 0; lastIdx--)
	{
		if (!GameCell_IsBlankCell(&m_cells[xIdx][lastIdx]))
		{
			break;
		}
	}
	
	lastIdx++;
	return lastIdx;
}


// 在(xIdx, yIdx)坐标位置, 放置一个灰度球, 用于game over情况
- (void) addGreyCellxIdx:(int) xIdx yIdx:(int)yIdx
{
	assert(xIdx >= 0 && xIdx < kXDirCellNum);
	assert(yIdx >= 0 && yIdx < kYDirCellNum);
	
	if (!GameCell_IsBlankCell(&m_cells[xIdx][yIdx]))
	{
		[self removeCellxIdx:xIdx yIdx:yIdx];
	}
	
	assert(GameCell_IsBlankCell(&m_cells[xIdx][yIdx]));
	
	CGRect rect = CGRectMake(kCellWidth * kKindGreyIndex, 0, kCellWidth, kCellWidth);
	AtlasSprite *sprite = [AtlasSprite spriteWithRect:rect  spriteManager:m_ballsManager];
	[m_ballsManager addChild:sprite];
	sprite.position = GetPostion(xIdx, yIdx);
	
	GameCell* cell = &m_cells[xIdx][yIdx];
	cell->m_sprite = sprite;
	cell->m_kindIdx = kKindGreyIndex;	
}



- (void) addNewCellxIdx:(int) xIdx yIdx:(int)yIdx kindIdx:(int)kindIdx
{
	assert(xIdx >= 0 && xIdx < kXDirCellNum);
	assert(yIdx >= 0 && yIdx < kYDirCellNum);
	assert(kindIdx >= 0 && kindIdx < kKindMaxNumber);
	assert(GameCell_IsBlankCell(&m_cells[xIdx][yIdx]));
	
	CGRect rect = CGRectMake(kCellWidth * kindIdx, 0, kCellWidth, kCellWidth);
	AtlasSprite *sprite = [AtlasSprite spriteWithRect:rect  spriteManager:m_ballsManager];
	[m_ballsManager addChild:sprite];
	sprite.position = GetPostion(xIdx, yIdx);
	
	GameCell* cell = &m_cells[xIdx][yIdx];
	cell->m_sprite = sprite;
	cell->m_kindIdx = kindIdx;	
}


- (void) removeCellxIdx:(int) xIdx yIdx:(int)yIdx
{
	assert(xIdx >= 0 && xIdx < kXDirCellNum);
	assert(yIdx >= 0 && yIdx < kYDirCellNum);
	
	GameCell* cell = &m_cells[xIdx][yIdx];
	if (GameCell_IsBlankCell(cell))
	{
		return;
	}
	
	[m_ballsManager removeChild:cell->m_sprite cleanup:YES];
	GameCell_Reset(cell);
}


- (void) clearResoucre
{
	for (AtlasSprite* sp in m_shottingBalls)
	{
		[m_ballsManager removeChild:sp cleanup:YES];
		free(sp.userData);
		sp.userData = nil;
	}
	[m_shottingBalls removeAllObjects];
	
	for (AtlasSprite* sp in m_fallingDwonBalls)
	{
		free(sp.userData);
		sp.userData = nil;
	}
	[m_fallingDwonBalls removeAllObjects];
}

- (void) dealloc
{
	[self clearResoucre];
	[m_fallingDwonBalls release];
	[m_shottingBalls release];
	[m_ballsManager release];
	[super dealloc];
}




- (bool) gameOverAnimate:(ccTime) t
{
	if (g_gameOverYIdx < 0)
	{
		return false;
	}
	
	g_totalTime += t;
	if (g_totalTime > 0.07)
	{
		for (g_gameOverXIdx = 0; g_gameOverXIdx < kXDirCellNum; g_gameOverXIdx++)
		{
			[self addGreyCellxIdx:g_gameOverXIdx yIdx:g_gameOverYIdx];
		}
		g_gameOverXIdx = 0;
		g_gameOverYIdx--;
		g_totalTime = g_totalTime - 0.07;
	}
	return true;
}



- (void) fillKindData:(GamePlayingData*) data
{
	for (int i = 0; i < kXDirCellNum; i++)
	{
		for (int j = 0; j < kYDirCellNum; j++)
		{
			data->m_kindIdx[i][j] = m_cells[i][j].m_kindIdx;
		}
	}
}


typedef struct BallInfo_tag
	{
		int	m_xIdx;
		int	m_kindIdx;
	} BallInfo;


static inline BallInfo* New_BallInfo(int xIdx, int kindIdx)
{
	BallInfo* info = (BallInfo*)malloc(sizeof(BallInfo));
	info->m_xIdx = xIdx;
	info->m_kindIdx = kindIdx;
	return info;
}


static inline void Free_BallInfo(BallInfo* info)
{
	free(info);
}



- (bool) removingAnimate:(ccTime) t
{
	if (s_needRemoveArray.empty())
	{
		return false;
	}
	
	bool result = true;
	CGFloat deltaScale = (0.05 - 1.0) / kRemovingAnimateTime;
	for (int i = 0; i < (int)s_needRemoveArray.size(); i++)
	{
		GameCellPosition pos = s_needRemoveArray[i];
		AtlasSprite* sp = m_cells[pos.m_xIdx][pos.m_yIdx].m_sprite;
		CGFloat scale = sp.scale;
		scale += deltaScale * t;
		sp.scale = scale;
		if (sp.scale < 0.05)
		{
			result = false;
		}
		
	}
	return result;
}


- (void) clearFallingDownInfo
{
	for (AtlasSprite* sprite in m_fallingDwonBalls)
	{
		BallFallingDownInfo* info = (BallFallingDownInfo*)sprite.userData;
		CGPoint pt = sprite.position;
		sprite.position = ccp(pt.x, pt.y + info->m_leftDist);
		free(sprite.userData);
		sprite.userData = nil;
	}
	
	[m_fallingDwonBalls removeAllObjects];
	for (int i = 0; i < kXDirCellNum; i++)
	{
		if (s_needFallingDownArray[i] != -1)
		{
			for (int j = 0; j < kYDirCellNum; j++)
			{
				AddToCheckArray(Pos_Make(i, j));
			}
		}
		s_needFallingDownArray[i] = -1;
	}
}


- (bool) fallDownAnimate:(ccTime) t
{
	if ([m_fallingDwonBalls count] == 0)
	{
		return false;
	}
	
	bool result = true;
	for (AtlasSprite* sprite in m_fallingDwonBalls)
	{
		CGPoint pt = sprite.position;
		BallFallingDownInfo* info = (BallFallingDownInfo*)sprite.userData;
		
		CGFloat ypos = info->m_delta * t;
		info->m_leftDist -= ypos;
		
		sprite.position = ccp(pt.x, pt.y + ypos);
		
		if (info->m_leftDist < 0)
		{
			result = false;
		}
	}
	
	return result;
}



- (void) clearGeningNewLineInfo
{
	for (AtlasSprite* sprite in m_fallingDwonBalls)
	{
		BallFallingDownInfo* info = (BallFallingDownInfo*)sprite.userData;
		CGPoint pt = sprite.position;
		sprite.position = ccp(pt.x, pt.y - info->m_leftDist);
		free(sprite.userData);
		sprite.userData = nil;
	}
	
	[m_fallingDwonBalls removeAllObjects];
	for (int i = 0; i < kXDirCellNum; i++)
	{
		s_needFallingDownArray[i] = -1;
		AddToCheckArray(Pos_Make(i, 0));
	}
}


- (bool) geningNewLineAnimate:(ccTime) t
{
	if ([m_fallingDwonBalls count] == 0)
	{
		return false;
	}
	
	bool result = true;
	for (AtlasSprite* sprite in m_fallingDwonBalls)
	{
		CGPoint pt = sprite.position;
		BallFallingDownInfo* info = (BallFallingDownInfo*)sprite.userData;
		
		CGFloat ypos = info->m_delta * t;
		info->m_leftDist -= ypos;
		
		sprite.position = ccp(pt.x, pt.y - ypos);
		
		if (info->m_leftDist < 0)
		{
			result = false;
		}
	}
	
	return result;
}


- (CGPoint) calRemovingPostion
{
	assert(!s_needRemoveArray.empty());
	CGFloat xPos = 0;
	CGFloat yPos = 0;
	
	for (int i = 0; i < (int)s_needRemoveArray.size(); i++)
	{
		GameCellPosition cellPos = s_needRemoveArray[i];
		AtlasSprite* sp = m_cells[cellPos.m_xIdx][cellPos.m_yIdx].m_sprite;
		CGPoint pos = sp.position;
		
		xPos += pos.x;
		yPos += pos.y;
	}
	
	xPos /= s_needRemoveArray.size();
	yPos /= s_needRemoveArray.size();
	
	return CGPointMake(xPos, yPos);
}


- (void) afterScoresAnimate:(CocosNode*)node
{
	[self removeChild:node cleanup:YES];
}


- (void) playScoresAnimateBaseScore:(int) score chainTime:(int)time
{
	CGPoint pos = [self calRemovingPostion];
	
	int colorIdx = 0;
	if (!s_needRemoveArray.empty())
	{
		GameCellPosition cellPos = s_needRemoveArray[0];
		colorIdx = m_cells[cellPos.m_xIdx][cellPos.m_yIdx].m_kindIdx;
		if (colorIdx < 0 || colorIdx >= kKindMaxNumber)
		{
			colorIdx = 0;
		}
	}

	GameFloatingScores* label = [GameFloatingScores layerWithBaseScore:score hitTime:time colorIdx:colorIdx];
	label.position = pos;
	[self addChild:label];

	[label setOpacity:0];
	
	[label runAction:[Sequence actions:
					  [Spawn actions:[MoveBy actionWithDuration:0.1 position:ccp(0, 2.5)], [FadeIn actionWithDuration:0.1], nil],
					  [MoveBy actionWithDuration:0.6 position:ccp(0, 15)],
					  [Spawn actions:[MoveBy actionWithDuration:0.3 position:ccp(0, 7.5)], [FadeOut actionWithDuration:0.3], nil],
					  [CallFuncN actionWithTarget:self selector:@selector(afterScoresAnimate:)], nil]];
}


- (void) timeStep:(ccTime) t
{	
	AtlasSprite* arrivedSprite = nil;
		
	for (AtlasSprite* sprite in m_shottingBalls)
	{
		CGPoint pt = sprite.position;
		sprite.position = ccp(pt.x, pt.y + 480.0 / kShottingAnimateTime * t);
		
		BallInfo* info = (BallInfo*)sprite.userData;
		
		int xIdx = info->m_xIdx;
		int lastYpos = GetYPos([self findLastYIdxBlank:xIdx]);
		
		if (m_gameBoardState == State_FallingDown && s_needFallingDownArray[xIdx] != -1)
		{
			AtlasSprite* tmp = m_cells[xIdx][s_needFallingDownArray[xIdx]].m_sprite;
			lastYpos = tmp.position.y - kCellWidth;
		}
				
		if (sprite.position.y > lastYpos)
		{
			arrivedSprite = sprite;
			break;
		}
	}
	
	if (arrivedSprite != nil)
	{
		BallInfo* info = (BallInfo*)arrivedSprite.userData;
		
		arrivedSprite.userData = nil;
		
		int counter = [m_shottingBalls count];
		[m_shottingBalls removeObject:arrivedSprite];
		assert(counter == (int)[m_shottingBalls count] + 1);
		
		[m_ballsManager removeChild:arrivedSprite cleanup:YES];
		m_shottingBallCounter[info->m_xIdx]--;
		assert(m_shottingBallCounter[info->m_xIdx] >= 0);
		
		int xIdx = info->m_xIdx;
		int yIdx = [self findLastYIdxBlank:xIdx];
		int kindIdx = info->m_kindIdx;
		Free_BallInfo(info);
		
		if (yIdx < kYDirCellNum)
		{
			[[SimpleAudioEngine sharedEngine] playEffect:@"BallHit.wav"];
			[self addNewCellxIdx:xIdx yIdx:yIdx kindIdx:kindIdx];
			
			AtlasSprite* sp = m_cells[xIdx][yIdx].m_sprite;
			CGPoint pos = sp.position;
			sp.position = ccp(pos.x, GetYPos(yIdx));
			
			AddToCheckArray(Pos_Make(xIdx, yIdx));
			
			if (m_gameBoardState == State_FallingDown || m_gameBoardState == State_GeningNewLine)
			{
				if (s_needFallingDownArray[xIdx] != -1)
				{
					AtlasSprite* tmp = m_cells[xIdx][s_needFallingDownArray[xIdx]].m_sprite;
					sp.position = ccp(tmp.position.x, tmp.position.y - kCellWidth);
					
					BallFallingDownInfo* info = (BallFallingDownInfo*)tmp.userData;
					assert(info != nil);
					
					[m_fallingDwonBalls addObject:sp];
					sp.userData = New_BallFallingDownInfo(info->m_leftDist, info->m_delta);
					
					s_needFallingDownArray[xIdx] = yIdx;
				}
			}
		}
		else
		{
			
		}
	}
	
	m_removeTimeCounter += t;
	switch (m_gameBoardState)
	{
		case State_Nothing:
			if ([self checkNeedToRemove])
			{
				m_gameBoardState = State_Removing;
			}
			else if ([self checkNeedGenNewLine])
			{
				m_gameBoardState = State_GeningNewLine;
			}
			else if (s_needGameOver)
			{
				[m_gamePlayingLayer beginGameOverAnimate];
				g_gameOverXIdx = 0;
				g_gameOverYIdx = kYDirCellNum - 1;
				g_totalTime = 0;
				m_gameBoardState = State_GameOverAnimate;
				[self clearResoucre];
			}
			break;
			
		case State_GeningNewLine:
			if (![self geningNewLineAnimate:t])
			{
				[self clearGeningNewLineInfo];
				m_gameBoardState = State_Nothing;
				if (s_needGameOver)
				{
					[m_gamePlayingLayer beginGameOverAnimate];
					g_gameOverXIdx = 0;
					g_gameOverYIdx = kYDirCellNum - 1;
					g_totalTime = 0;
					m_gameBoardState = State_GameOverAnimate;
					[self clearResoucre];
				}
			}
			break;
			
		case State_Removing:
			if (![self removingAnimate:t])
			{
				if (!s_needRemoveArray.empty())
				{
					[[SimpleAudioEngine sharedEngine] playEffect:@"Clear.wav"];
					
					if (m_removeTimeCounter < kRemovingCounterTime)
					{
						m_chainTime++;
						m_removeTimeCounter = 0.0;
					}
					else
					{
						m_chainTime = 1;
						m_removeTimeCounter = 0.0;
					}
					[self removePositionArray];
				}
				
				m_gameBoardState = State_Nothing;
				if ([m_fallingDwonBalls count] != 0)
				{
					m_gameBoardState = State_FallingDown;
				}
			}
			break;
			
		case State_FallingDown:
			if (![self fallDownAnimate:t])
			{
				[[SimpleAudioEngine sharedEngine] playEffect:@"FallDown.wav"];
				[self clearFallingDownInfo];
				m_gameBoardState = State_Nothing;
			}
			break;
			
		case State_GameOverAnimate:
			if (![self gameOverAnimate:t])
			{
				[m_gamePlayingLayer endGameOverAnimate];
			}
			break;
			
		case State_GameOver:
			break;
	}
	
	[self updateShotStrip:t];
}


- (void) updateShotStrip:(ccTime)t
{
	m_stripTimeCounter += t;
	if (m_stripTimeCounter > 0.05)
	{
		m_stripTimeCounter = m_stripTimeCounter - 0.05;
		m_stripBottomPos += 1;
		if (m_stripBottomPos == 470 + 25)
		{
			m_stripBottomPos = 470;
		}
	}
	
	[m_stripeManager removeAllChildrenWithCleanup:YES];
	int yIdx = [self findLastYIdxBlank:m_stripPosIdx];
	CGFloat yPos = GetYPos(yIdx);
	if (m_gameBoardState == State_FallingDown || m_gameBoardState == State_GeningNewLine)
	{
		if (s_needFallingDownArray[m_stripPosIdx] != -1)
		{
			AtlasSprite* tmp = m_cells[m_stripPosIdx][s_needFallingDownArray[m_stripPosIdx]].m_sprite;
			yPos = tmp.position.y - kCellWidth;
		}
	}
	
	for (AtlasSprite* sp in m_shottingBalls)
	{
		BallInfo* info = (BallInfo*)sp.userData;
		if (info->m_xIdx == m_stripPosIdx)
		{
			yPos = sp.position.y - kCellWidth;
		}
	}
	
	CGFloat length = yPos - GetYPos(kYDirCellNum) + 20 + kCellWidth * 0.5;
	
	assert(m_stripBottomPos - length >= 0);
	CGRect rect = CGRectMake(kShotStripWidth * m_stripColorIdx, m_stripBottomPos - length, kShotStripWidth, length);
	AtlasSprite* sp = [AtlasSprite spriteWithRect:rect spriteManager:m_stripeManager];
	[m_stripeManager addChild:sp];
	
	sp.anchorPoint = ccp(0.5, 0);
	sp.position = ccp(kXDirOffset + kCellWidth * (m_stripPosIdx + 0.5), GetYPos(kYDirCellNum) - 20);	
}


- (bool) addCellWillShot:(int) xIdx kindIdx:(int)kindIdx
{
	assert(xIdx >= 0 && xIdx < kXDirCellNum);
		
	if ([self findLastYIdxBlank:xIdx] + m_shottingBallCounter[xIdx] >= kYDirCellNum)
	{
		return false;
	}
	
	m_shottingBallCounter[xIdx]++;
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"Shot.wav"];
	
	CGRect rect = CGRectMake(kCellWidth * kindIdx, 0, kCellWidth, kCellWidth);
	AtlasSprite *sprite = [AtlasSprite spriteWithRect:rect  spriteManager:m_ballsManager];
	assert(sprite.userData == nil);
	
	[m_ballsManager addChild:sprite];	
	
	CGFloat xpos = (xIdx + 0.5) * kCellWidth + kXDirOffset;
	CGFloat ypos = 29;
	sprite.position = ccp(xpos, ypos);
	sprite.userData = (void*)New_BallInfo(xIdx, kindIdx);
	assert(sprite.userData != nil);
	
	[m_shottingBalls addObject:sprite];
	return true;
}


- (void) setStripInfoColorIdx:(int)idx0 posIdx:(int)idx1
{
	m_stripPosIdx = idx1;
	m_stripColorIdx = idx0;
}

@end
