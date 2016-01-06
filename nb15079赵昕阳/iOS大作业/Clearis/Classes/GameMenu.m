//
//  GameMenu.m
//  Clearis
//
//  Created by 881 on 10-3-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameMenu.h"
#import "SimpleAudioEngine.h"


@implementation GameMenu


-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	BOOL res = [super ccTouchBegan:touch withEvent:event];
	if (state == kMenuStateTrackingTouch)
	{
		[[SimpleAudioEngine sharedEngine] playEffect:@"ButtonClick.wav"];
	}
	return res;
}

@end
