//
//  GameStateLayer.h
//  Clearis
//
//  Created by 881 on 10-3-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "GameDataManager.h"


@interface GameStateLayer : Layer 
{
	GameDataManager*	m_dataManager;
}

+ (id) layerWithDataManager:(GameDataManager*)manager;
- (id) initWithDataManager:(GameDataManager*)manager;
- (void) enterLayer;
- (void) levelLayer:(GameDataManager*)manager;

@end
