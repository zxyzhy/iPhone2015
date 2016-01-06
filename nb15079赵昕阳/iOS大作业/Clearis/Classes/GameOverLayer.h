//
//  GameOverLayer.h
//  Clearis
//
//  Created by 881 on 10-3-15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "GameStateLayer.h"


@interface GameOverLayer : GameStateLayer {

}


- (id) initWithDataManager:(GameDataManager*)manager;


- (void) startMenu:(id)sender;
- (void) startRetry:(id)sender;

@end
