//
//  GameCurBall.m
//  Clearis
//
//  Created by 881 on 10-3-7.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameCurBall.h"
#import "ConstDef.h"
#import "global.h"

#define	kCurBallSpriteTag	1000
#define kCurCellYPos	29

@implementation GameCurBall


+ (id) layerWithBallIdx:(int)idx xIdx:(int)xIdx
{
	return [[[GameCurBall alloc] initWithBallIdx:idx xIdx:xIdx] autorelease];
}

- (id) initWithBallIdx:(int)idx xIdx:(int)xIdx
{
	[super init];
	
	m_stripsManager = [[AtlasSpriteManager alloc] initWithFile:@"stripes.png" capacity:10];
	m_ballsManager = [[AtlasSpriteManager alloc] initWithFile:@"Balls.png" capacity:10];
	
	[self addChild:m_stripsManager];
	[self addChild:m_ballsManager];
		
	CGRect rect1 = CGRectMake(0, kStripeHeight * idx, kStripeWidth, kStripeHeight);
	AtlasSprite* sprite = [AtlasSprite spriteWithRect:rect1 spriteManager:m_stripsManager];
	sprite.anchorPoint = ccp(0, 0.5);
	sprite.position = ccp(0, kCurCellYPos);
	[m_stripsManager addChild:sprite];
	
	// for test	
	CGRect rect2 = CGRectMake(kCellWidth * idx, 0, kCellWidth, kCellWidth);
	AtlasSprite *sprite2 = [AtlasSprite spriteWithRect:rect2  spriteManager:m_ballsManager];
	sprite2.anchorPoint = ccp(0.0, 0.5);
	sprite2.position = ccp(kXDirOffset + xIdx * kCellWidth, kCurCellYPos);
	[m_ballsManager addChild:sprite2 z:0 tag:kCurBallSpriteTag];	
	
	return self;
}


- (void) deleteCurBall
{
	AtlasSprite* sprite = (AtlasSprite*)[m_ballsManager getChildByTag:kCurBallSpriteTag];
	[m_ballsManager removeChild:sprite cleanup:YES];
}


- (void) dealloc
{
	[m_stripsManager release];
	[m_ballsManager release];
	[super dealloc];
}

@end
