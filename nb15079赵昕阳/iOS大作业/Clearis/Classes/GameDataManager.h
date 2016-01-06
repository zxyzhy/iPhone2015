//
//  GameDataManager.h
//  Clearis
//
//  Created by 881 on 10-3-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConstDef.h"


typedef enum
	{
		Game_MainMenu,
		Game_New,
		Game_Playing,
		Game_Pause,
		Game_Help,
		Game_Options,
		Game_Scores,
	} GameState;


typedef struct GamePlayingData_tag
{
	int m_version;
	int	m_initLevel;
	int	m_isLevelLocked;
	int	m_level;
	int m_scores;
	int	m_curKind;
	int m_curXIdx;
	int m_nextKind;
	int m_kindIdx[kXDirCellNum][kYDirCellNum];
} GamePlayingData;

bool GamePlayingData_Write(GamePlayingData* data, const char* fileName);
bool GamePlayingData_Read(GamePlayingData* data,  const char* fileName);
void GamePlayingData_Init(GamePlayingData* data);


@interface GameDataManager : NSObject 
{
	UIWindow*		m_mainWindow;
	GameState		m_gameState;
	NSString*		m_playerName;
	NSMutableArray*	m_playerNameListLocked;
	NSMutableArray*	m_scoreListLocked;
	NSMutableArray*	m_playerNameListNormal;
	NSMutableArray*	m_scoreListNormal;
	GamePlayingData	m_playingData;
	bool			m_hasDataSaved;
	bool			m_isLevelLocked;
	bool			m_isMusicOn;
	bool			m_isSoundOn;
	int				m_initLevel;
	int				m_soundVolume;
	int				m_musicVolume;
	int				m_score;
}

@property (nonatomic, assign)	UIWindow*		mainWindow;
@property (nonatomic, assign)	int				initLevel;
@property (nonatomic, assign)	int				soundVolume;
@property (nonatomic, assign)	int				musicVolume;
@property (nonatomic, assign)	bool			hasDataSaved;
@property (nonatomic, assign)	bool			isLevelLocked;
@property (nonatomic, assign)	bool			isSoundOn;
@property (nonatomic, assign)	bool			isMusicOn;
@property (nonatomic, assign)	int				score;
@property (nonatomic, copy)		NSString*		playerName;
@property (nonatomic, readonly)	NSMutableArray*	playerNameListLocked;
@property (nonatomic, readonly)	NSMutableArray* scoreListLocked;
@property (nonatomic, readonly)	NSMutableArray*	playerNameListNormal;
@property (nonatomic, readonly)	NSMutableArray* scoreListNormal;

- (id) init;

- (GamePlayingData*)	getPlayingData;
- (void) insertScore:(int) score player:(NSString*)name isLevelLocked:(bool)isLocked;
- (void) clearScoresIsLevelLocked:(bool)isLocked;
- (void) save;
- (void) load;

- (CGFloat) realSoundVolume;
- (CGFloat) realMusicVolume;

@end
