//
//  GameScore.m
//  Clearis
//
//  Created by 881 on 10-3-2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameScore.h"
#import "ConstDef.h"


#define	k88888Sprite0Tag	1000
#define k88888Sprite1Tag	1001


@implementation GameScore

@synthesize score = m_score;

- (void) showScore:(int) num
{
	[m_manager removeAllChildrenWithCleanup:YES];
	[self removeChild:[self getChildByTag:k88888Sprite0Tag] cleanup:YES];
	[self removeChild:[self getChildByTag:k88888Sprite1Tag] cleanup:YES];
	
	char	strNum[64];
	sprintf(strNum, "%d", num);
	
	int len = strlen(strNum);
	if (len > 5)
	{
		Sprite* sp0 = [Sprite spriteWithFile:@"88888.png"];
		Sprite* sp1 = [Sprite spriteWithFile:@"88888.png"];
		[self addChild:sp0 z:0 tag:k88888Sprite0Tag];
		sp0.anchorPoint = ccp(0, 0);
		sp0.position = ccp(5, 5);
		
		[self addChild:sp1 z:0 tag:k88888Sprite1Tag];
		sp1.anchorPoint = ccp(0, 0);
		sp1.position = ccp(5, 5 + kNumberSpriteHeight);
		
		int xpos = 5 + kNumberSpriteWidth * 4;
		int ypos = 5;
		
		int idx = len - 1;
		for (int i = 0; i < 5; i++, idx--)
		{
			CGRect rect = CGRectMake((strNum[idx] - '0') * kNumberSpriteWidth, 0, kNumberSpriteWidth, kNumberSpriteHeight);
			AtlasSprite* sp = [AtlasSprite spriteWithRect:rect spriteManager:m_manager];
			sp.position = ccp(xpos, ypos);
			sp.anchorPoint = ccp(0, 0);
			[m_manager addChild:sp];
			xpos -= kNumberSpriteWidth;
		}
		
		int counter = len - 5;
		counter = counter < 5 ? counter : 5;
		xpos = 5 + kNumberSpriteWidth * 4;
		ypos = 5 + kNumberSpriteHeight;
		for (int i = 0; i < counter; i++, idx--)
		{
			CGRect rect = CGRectMake((strNum[idx] - '0') * kNumberSpriteWidth, 0, kNumberSpriteWidth, kNumberSpriteHeight);
			AtlasSprite* sp = [AtlasSprite spriteWithRect:rect spriteManager:m_manager];
			sp.position = ccp(xpos, ypos);
			sp.anchorPoint = ccp(0, 0);
			[m_manager addChild:sp];
			xpos -= kNumberSpriteWidth;
		}
	}
	else
	{
		int ypos = 5 + kNumberSpriteHeight * 0.5;
		int xpos = 5 + kNumberSpriteWidth * 4;
		
		Sprite* sp0 = [Sprite spriteWithFile:@"88888.png"];
		[self addChild:sp0 z:0 tag:k88888Sprite0Tag];
		sp0.anchorPoint = ccp(0, 0);
		sp0.position = ccp(5, ypos);
		
		for (int idx = len - 1; idx >= 0; idx--)
		{
			CGRect rect = CGRectMake((strNum[idx] - '0') * kNumberSpriteWidth, 0, kNumberSpriteWidth, kNumberSpriteHeight);
			AtlasSprite* sp = [AtlasSprite spriteWithRect:rect spriteManager:m_manager];
			sp.position = ccp(xpos, ypos);
			sp.anchorPoint = ccp(0, 0);
			[m_manager addChild:sp];
			xpos -= kNumberSpriteWidth;
		}	
	}
}

- (id) initWithScore:(int)score
{
	[super init];
	
	Sprite* bg = [Sprite spriteWithFile:@"Score_bg.png"];
	self.contentSize = bg.contentSize;
	bg.anchorPoint = ccp(0.0, 0.0);
	
	[self addChild:bg];
	self.relativeAnchorPoint = TRUE;
	
	m_manager = [AtlasSpriteManager spriteManagerWithFile:@"MergeNumbers.png"];
	[self addChild:m_manager z:1];
	
	m_score = score;
	[self showScore:score];
	
	return self;
}


- (void) setScore:(int) score
{
	m_score = score;
	[self showScore:m_score];
}


@end
