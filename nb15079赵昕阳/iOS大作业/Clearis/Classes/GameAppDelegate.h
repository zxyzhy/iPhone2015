//
//  ClearisAppDelegate.h
//  Clearis
//
//  Created by 881 on 10-2-20.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "GameStateLayer.h"
#import "GameDataManager.h"


@interface GameAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	GameDataManager*	m_dataManager;
	GameStateLayer*		m_currentLayer;
	Scene*		m_currentScene;
}

@property (nonatomic, retain) UIWindow *window;

+ (GameAppDelegate*) instance;


- (void) startGamePause:(bool)flag;
- (void) startStartNewGame:(bool)flag;
- (void) startGameScores:(bool)flag;
- (void) startGameOptions:(bool)flag;
- (void) startGameHelp:(bool)flag;
- (void) startMainMenu:(bool)flag;
- (void) startGameNew:(bool)flag;
- (void) startGameOver:(bool)flag;

- (GameStateLayer*) getCurrentLayer;

@end
