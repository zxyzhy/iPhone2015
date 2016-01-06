//
//  GameNextBall.m
//  Clearis
//
//  Created by 881 on 10-3-2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameNextBall.h"


#define kNextSpriteTag		1000
#define kNextBallColorTag	1001


@implementation GameNextBall

- (AtlasSprite*) getSpriteWithIdx:(int) idx
{
	assert(idx >= 0 && idx < kKindMaxNumber);
	CGRect rect = CGRectMake(kCellWidth * idx, 0, kCellWidth, kCellWidth);
	return [AtlasSprite spriteWithRect:rect spriteManager:m_ballsManager];
}


- (id) init
{
	[super init];
	
	m_ballsManager = [[AtlasSpriteManager alloc] initWithFile:@"Balls.png" capacity:10];
	
	Sprite* bg = [Sprite spriteWithFile:@"Next_bg.png"];
	self.contentSize = bg.contentSize;
	bg.anchorPoint = ccp(0.0, 0.0);
	
	[self addChild:bg];
	[self addChild:m_ballsManager];
	self.relativeAnchorPoint = TRUE;
	
	srand(time(0));
	m_nextIdx = rand() % kKindMaxNumber;
	
	[self genNextBall];
	
	return self;
}



- (void) dealloc
{
	[m_ballsManager release];
	[super dealloc];
}


- (void) genNextBall
{
	m_nextIdx = rand() % kKindMaxNumber;
	[self setNextBall:m_nextIdx];
}


- (void) setNextBall:(int) idx
{
	m_nextIdx = idx;
		
	[m_ballsManager removeChildByTag:kNextSpriteTag cleanup:YES];
	
	AtlasSprite* nextSprite = [self getSpriteWithIdx:m_nextIdx];
	
	nextSprite.position = ccp(5 + 45, 22.5 + 5);
	
	[m_ballsManager addChild:nextSprite z:0 tag:kNextSpriteTag];
}


- (int)  getNextIdx
{
	return m_nextIdx;
}

@end
