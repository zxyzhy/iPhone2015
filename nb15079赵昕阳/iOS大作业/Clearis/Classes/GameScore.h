//
//  GameScore.h
//  Clearis
//
//  Created by 881 on 10-3-2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"


@interface GameScore : Layer 
{
	AtlasSpriteManager*	m_manager;
	int					m_score;
}


@property (nonatomic, assign) int	score;

- (id) initWithScore:(int)score;


@end
