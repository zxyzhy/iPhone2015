//
//  MainMenu.h
//  Clearis
//
//  Created by 881 on 10-2-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "GameStateLayer.h"

@interface GameMenuLayer : GameStateLayer {

}

- (id) initWithDataManager:(GameDataManager*)manager;
- (id) initWithDataManagerWithAnimate:(GameDataManager*)manager;

- (void) startNew:(id) sender;
- (void) startResume:(id) sender;
- (void) startOptions:(id) sender;
- (void) startScores:(id) sender;
- (void) startHelp:(id) sender;

@end
