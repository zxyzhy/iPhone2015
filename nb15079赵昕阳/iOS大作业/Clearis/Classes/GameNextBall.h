//
//  GameNextBall.h
//  Clearis
//
//  Created by 881 on 10-3-2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "ConstDef.h"


@interface GameNextBall : Layer 
{
	AtlasSpriteManager*	m_ballsManager;
	int		m_nextIdx;
}


- (void) genNextBall;
- (int)  getNextIdx;
- (void) setNextBall:(int) idx;

@end
