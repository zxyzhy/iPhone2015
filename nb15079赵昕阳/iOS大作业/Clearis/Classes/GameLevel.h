//
//  GameLevel.h
//  Clearis
//
//  Created by 881 on 10-3-2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"


@interface GameLevel : Layer 
{
	AtlasSpriteManager*	m_manager;
	int					m_level;
}

@property (nonatomic, assign)	int	level;

- (id) initWithLevel:(int)level isLocked:(bool)isLocked;
+ (id) layerWithLevel:(int)level isLocked:(bool)isLocked;

@end
