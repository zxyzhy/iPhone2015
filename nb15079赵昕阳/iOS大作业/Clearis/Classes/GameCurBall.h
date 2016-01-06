//
//  GameCurBall.h
//  Clearis
//
//  Created by 881 on 10-3-7.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"


@interface GameCurBall : Layer 
{
	AtlasSpriteManager*	m_ballsManager;
	AtlasSpriteManager*	m_stripsManager;
}

+ (id) layerWithBallIdx:(int)idx xIdx:(int)xIdx;
- (id) initWithBallIdx:(int)idx xIdx:(int)xIdx;

- (void) deleteCurBall;

@end
