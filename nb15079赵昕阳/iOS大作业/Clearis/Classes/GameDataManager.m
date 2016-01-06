//
//  GameDataManager.m
//  Clearis
//
//  Created by 881 on 10-3-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "GameDataManager.h"

bool GamePlayingData_Write(GamePlayingData* data, const char* fileName)
{
	FILE* out_file = fopen(fileName, "w");
	
	char magicNum[8] = "clearis";
	magicNum[7] = 0;
	
	fwrite(&magicNum[0], 8, 1, out_file);
	fwrite(data, sizeof(GamePlayingData), 1, out_file);

	fclose(out_file);
	return false;
}


bool GamePlayingData_Read(GamePlayingData* data,  const char* fileName)
{
	FILE* in_file = fopen(fileName, "r");
	
	char magicNum[8];
	magicNum[7] = 0;
	fread(magicNum, 8, 1, in_file);
	if (strcmp(magicNum, "clearis"))
	{
		fclose(in_file);
		return false;
	}
	
	fread(data, sizeof(GamePlayingData), 1, in_file);
	
	fclose(in_file);
	return true;
}

void GamePlayingData_Init(GamePlayingData* data)
{
	data->m_version = 1;
	data->m_level = 0;
	data->m_scores = 0;
	data->m_curKind = 0;
	data->m_curXIdx = 0;
	data->m_nextKind = 0;
	data->m_initLevel = 0;
	data->m_isLevelLocked = 0;
	for (int i = 0; i < kXDirCellNum; i++)
	{
		for (int j = 0; j < kYDirCellNum; j++)
		{
			data->m_kindIdx[i][j] = 0;
		}
	}
}


///////////////////////////////////////

@implementation GameDataManager

@synthesize mainWindow = m_mainWindow;
@synthesize initLevel = m_initLevel;
@synthesize hasDataSaved = m_hasDataSaved;
@synthesize score = m_score;
@synthesize playerName = m_playerName;
@synthesize playerNameListLocked = m_playerNameListLocked;
@synthesize scoreListLocked = m_scoreListLocked;
@synthesize playerNameListNormal = m_playerNameListNormal;
@synthesize scoreListNormal = m_scoreListNormal;
@synthesize soundVolume = m_soundVolume;
@synthesize musicVolume = m_musicVolume;
@synthesize isLevelLocked = m_isLevelLocked;
@synthesize isSoundOn = m_isSoundOn;
@synthesize isMusicOn = m_isMusicOn;


- (GamePlayingData*)	getPlayingData
{
	return &m_playingData;
}


- (id) getUserData:(NSString*) key
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void) storeUserData:(id)data forKey:(NSString*)key
{
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
}


- (CGFloat) realSoundVolume
{
	return m_isSoundOn ? (1.0 / 9.0) * m_soundVolume : 0;
}


- (CGFloat) realMusicVolume
{
	return m_isMusicOn ? (1.0 / 9.0) * m_musicVolume : 0;
}

- (id) init
{
	[super init];
	
	m_mainWindow = nil;
	m_hasDataSaved = false;
	m_isLevelLocked = false;
	m_isMusicOn = true;
	m_isSoundOn = true;
	m_initLevel = 0;
	m_musicVolume = 5;
	m_soundVolume = 5;
	m_score = 0;
	m_gameState = Game_MainMenu;
	m_playerName = [[NSString alloc] initWithString:@"MyFriend"];
	m_playerNameListLocked = [[NSMutableArray alloc] initWithCapacity:21];
	m_scoreListLocked = [[NSMutableArray alloc] initWithCapacity:21];
	m_playerNameListNormal = [[NSMutableArray alloc] initWithCapacity:21];
	m_scoreListNormal = [[NSMutableArray alloc] initWithCapacity:21];
	
	GamePlayingData_Init(&m_playingData);
	
	return self;
}


- (void) dealloc
{
	[m_playerName release];
	[m_playerNameListLocked release];
	[m_scoreListLocked release];
	[super dealloc];
}

- (void) save
{
	id tmpId = [NSNumber numberWithInt:1];
	[self storeUserData:tmpId forKey:@"Version"];
	
	tmpId = [NSNumber numberWithBool:m_hasDataSaved];
	[self storeUserData:tmpId forKey:@"HasDataSaved"];
	
	tmpId = [NSNumber numberWithBool:m_isLevelLocked];
	[self storeUserData:tmpId forKey:@"IsLevelLocked"];
	
	tmpId = [NSNumber numberWithBool:m_isSoundOn];
	[self storeUserData:tmpId forKey:@"IsSoundOn"];
	
	tmpId = [NSNumber numberWithBool:m_isMusicOn];
	[self storeUserData:tmpId forKey:@"IsMusicOn"];
	
	[self storeUserData:m_playerName forKey:@"PlayerName"];
	tmpId = [NSNumber numberWithInt:m_initLevel];
	[self storeUserData:tmpId forKey:@"InitLevel"];
	
	tmpId = [NSNumber numberWithInt:m_soundVolume];
	[self storeUserData:tmpId forKey:@"SoundVolume"];
	
	tmpId = [NSNumber numberWithInt:m_musicVolume];
	[self storeUserData:tmpId forKey:@"MusicVolume"];
	
	[self storeUserData:m_playerNameListLocked forKey:@"PlayerNameListLocked"];
	[self storeUserData:m_scoreListLocked forKey:@"ScoreListLocked"];
	
	[self storeUserData:m_playerNameListNormal forKey:@"PlayerNameListNormal"];
	[self storeUserData:m_scoreListNormal forKey:@"ScoreListNormal"];

	if (m_hasDataSaved)
	{
		tmpId = [NSString stringWithString:@"Clearis_DataSaved"];
		[self storeUserData:tmpId forKey:@"DataSavedFileName"];
		
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString* documentsDirectory = [paths objectAtIndex:0];
		NSString *filePath = [documentsDirectory stringByAppendingPathComponent:(NSString*)tmpId];
		GamePlayingData_Write(&m_playingData, [filePath UTF8String]);
	}
}


- (void) load
{
	id tmpId = [self getUserData:@"Version"];
	if (tmpId && [(NSNumber*)tmpId intValue] != 1)
	{
		return;
	}
	
	tmpId = [self getUserData:@"HasDataSaved"];
	if (tmpId)
	{
		m_hasDataSaved = [(NSNumber*)tmpId boolValue];
	}
	
	tmpId = [self getUserData:@"IsLevelLocked"];
	if (tmpId)
	{
		m_isLevelLocked = [(NSNumber*)tmpId boolValue];
	}
	
	tmpId = [self getUserData:@"IsSoundOn"];
	if (tmpId)
	{
		m_isSoundOn = [(NSNumber*)tmpId boolValue];
	}
	
	tmpId = [self getUserData:@"IsMusicOn"];
	if (tmpId)
	{
		m_isMusicOn = [(NSNumber*)tmpId boolValue];
	}
	
	tmpId = [self getUserData:@"InitLevel"];
	if (tmpId)
	{
		m_initLevel = [(NSNumber*)tmpId intValue];
	}
	
	tmpId = [self getUserData:@"MusicVolume"];
	if (tmpId)
	{
		m_musicVolume = [(NSNumber*)tmpId intValue];
	}
	
	tmpId = [self getUserData:@"SoundVolume"];
	if (tmpId)
	{
		m_soundVolume = [(NSNumber*)tmpId intValue];
	}
	
	tmpId = [self getUserData:@"PlayerName"];
	if (tmpId)
	{
		self.playerName = [(NSString*)tmpId copy];
	}
	if ([self.playerName length] == 0)
	{
		self.playerName = @"Player";
	}
	
	tmpId = [self getUserData:@"PlayerNameListLocked"];
	if (tmpId)
	{
		[m_playerNameListLocked release];
		m_playerNameListLocked = [[NSMutableArray alloc] initWithArray:(NSArray*)tmpId];
	}
	
	tmpId = [self getUserData:@"ScoreListLocked"];
	if (tmpId)
	{
		[m_scoreListLocked release];
		m_scoreListLocked = [[NSMutableArray alloc] initWithArray:(NSArray*)tmpId];
	}
	
	tmpId = [self getUserData:@"PlayerNameListNormal"];
	if (tmpId)
	{
		[m_playerNameListNormal release];
		m_playerNameListNormal = [[NSMutableArray alloc] initWithArray:(NSArray*)tmpId];
	}
	
	tmpId = [self getUserData:@"ScoreListNormal"];
	if (tmpId)
	{
		[m_scoreListNormal release];
		m_scoreListNormal = [[NSMutableArray alloc] initWithArray:(NSArray*)tmpId];
	}
	
	
	if (m_hasDataSaved)
	{
		tmpId = [self getUserData:@"DataSavedFileName"];
		if (tmpId)
		{
			NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString* documentsDirectory = [paths objectAtIndex:0];
			NSString *filePath = [documentsDirectory stringByAppendingPathComponent:(NSString*)tmpId];
			GamePlayingData_Read(&m_playingData, [filePath UTF8String]);
		}
	}
}


- (void) insertScore:(int) score 
			  player:(NSString*)name 
		   scoreList:(NSMutableArray*)socreList 
			nameList:(NSMutableArray*)nameList
{
	int count = [socreList count];
	int insertIdx = 0;
	
	for ( ; insertIdx < count; insertIdx++)
	{
		NSNumber* curScore = [socreList objectAtIndex:insertIdx];
		if (score >= [curScore intValue])
		{
			break;
		}
	}
	
	NSNumber* num = [[NSNumber alloc] initWithInt:score];
	[socreList insertObject:num atIndex:insertIdx];
	[num release];
	
	NSString* text = [[NSString alloc] initWithString:name];
	[nameList insertObject:text atIndex:insertIdx];
	[text release];
	
	if ([socreList count] > 20)
	{
		[socreList removeLastObject];
		[nameList removeLastObject];
	}	
}


- (void) insertScore:(int) score player:(NSString*)name isLevelLocked:(bool)isLocked
{
	if (isLocked)
	{
		[self insertScore:score player:name scoreList:m_scoreListLocked nameList:m_playerNameListLocked];
	}
	else
	{
		[self insertScore:score player:name scoreList:m_scoreListNormal nameList:m_playerNameListNormal];
	}
}

- (void) clearScoresIsLevelLocked:(bool)isLocked
{
	if (isLocked)
	{
		[m_scoreListLocked removeAllObjects];
		[m_playerNameListLocked removeAllObjects];
	}
	else
	{
		[m_scoreListNormal removeAllObjects];
		[m_playerNameListNormal removeAllObjects];
	}
}

@end
