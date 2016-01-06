//
//  GamePauseLayer.h
//  Clearis
//
//  Created by 881 on 10-3-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "GameSettingLayer.h"


@interface GamePauseLayer : GameSettingLayer
{
}

- (id) initWithDataManager:(GameDataManager*)manager;

- (void) startMenu:(id)sender;
- (void) startResume:(id)sender;

@end
