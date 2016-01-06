//
//  GameScoresLayer.h
//  Clearis
//
//  Created by 881 on 10-3-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "GameStateLayer.h"
#import "GameResetViewControler.h"


@interface GameScoresLayer : GameStateLayer<UITableViewDataSource, UITableViewDelegate>
{
	UITableView*			m_tableView;
	GameResetViewControler*	m_resetController;
	bool					m_showNormal;
}


- (id) initWithDataManager:(GameDataManager*)manager;

- (void) startMenu:(id)sender;
- (void) startReset:(id)sender;
- (void) startSelected:(id)sender;

- (void) startCancel:(id)sender;
- (void) startResetScores:(id)sender;

@end
