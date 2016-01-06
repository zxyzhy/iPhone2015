//
//  GameResetViewControler.m
//  Clearis
//
//  Created by 881 on 10-3-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameResetViewControler.h"
#import "SimpleAudioEngine.h"
#import "GameScoresLayer.h"


@implementation GameResetViewControler


- (IBAction) beganPressed:(id)sender
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"ButtonClick.wav"];
}


- (IBAction) cancelPreesed:(id)sender
{
	GameScoresLayer* layer = (GameScoresLayer*)m_target;
	[layer startCancel:sender];
}

- (IBAction) resetScoresPressed:(id)sender
{
	GameScoresLayer* layer = (GameScoresLayer*)m_target;
	[layer startResetScores:sender];
}

- (void) setTarget:(id) target
{
	m_target = target;
}

@end
