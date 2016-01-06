//
//  GameHelpLayer.h
//  Clearis
//
//  Created by 881 on 10-3-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "GameStateLayer.h"


@interface GameHelpLayer : GameStateLayer<UITableViewDataSource, UITableViewDelegate> 
{
	UITableView*			m_tableView;
	NSArray*				m_infoArray;
}


- (id) initWithDataManager:(GameDataManager*)manager;

- (void) startMenu:(id)sender;


@end
