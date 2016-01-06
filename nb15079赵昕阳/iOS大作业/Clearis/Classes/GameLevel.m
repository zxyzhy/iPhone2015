//
//  GameLevel.m
//  Clearis
//
//  Created by 881 on 10-3-2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameLevel.h"
#import "ConstDef.h"


@implementation GameLevel


@synthesize level = m_level;

- (void) showLevel:(int) level 
{
	[m_manager removeAllChildrenWithCleanup:YES];
	
	char	strNum[64];
	sprintf(strNum, "%d", level);
	
	int len = strlen(strNum);
	len = len < 5 ? len : 5;
	int xpos = 5 + (5 - len) * kNumberSpriteWidth;
	
	for (int i = 0; i < len; i++)
	{
		CGRect rect = CGRectMake((strNum[i] - '0') * kNumberSpriteWidth, 0, kNumberSpriteWidth, kNumberSpriteHeight);
		AtlasSprite* sp = [AtlasSprite spriteWithRect:rect spriteManager:m_manager];
		sp.position = ccp(xpos, 5);
		sp.anchorPoint = ccp(0, 0);
		[m_manager addChild:sp];
		xpos += kNumberSpriteWidth;
	}
}



- (id) initWithLevel:(int)level isLocked:(bool)isLocked
{
	[super init];
	
	Sprite* bg = nil;
	if (isLocked)
	{
		bg = [Sprite spriteWithFile:@"LevelLock_bg.png"];
		
	}
	else
	{
		bg = [Sprite spriteWithFile:@"Level_bg.png"];
	}
		
	self.contentSize = bg.contentSize;
	bg.anchorPoint = ccp(0.0, 0.0);
	[self addChild:bg];
	self.relativeAnchorPoint = TRUE;
	
	Sprite* sp = [Sprite spriteWithFile:@"88888.png"];
	sp.anchorPoint = ccp(0, 0);
	sp.position = ccp(5, 5);
	[self addChild:sp];
	
	m_manager = [AtlasSpriteManager spriteManagerWithFile:@"MergeNumbers.png"];
	[self addChild:m_manager];
	
	m_level = level;
	[self showLevel:m_level];
	
	return self;
}


- (void) setLevel:(int)level
{
	m_level = level;
	[self showLevel:level];
}


+ (id) layerWithLevel:(int)level isLocked:(bool)isLocked
{
	return [[[GameLevel alloc] initWithLevel:level isLocked:isLocked] autorelease];
}

@end
