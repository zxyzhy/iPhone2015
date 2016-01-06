//
//  GameFloatingScores.m
//  Clearis
//
//  Created by 881 on 10-3-29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameFloatingScores.h"


#define kFloatingNumberHeight	20

static int s_numbersWidth[11] =    { 14, 7, 14, 15, 15, 14, 14, 15, 14,  14,  19 };
static int s_numbersBeginPos[11] = { 0, 14, 21, 35, 50, 65, 79, 93, 108, 122, 136 };

@implementation GameFloatingScores

- (id) initWithBaseScore:(int)score hitTime:(int)time colorIdx:(int)idx
{
	[super init];
	
	m_spManager = [AtlasSpriteManager spriteManagerWithFile:@"HitNumbers.png"];
	[self addChild:m_spManager];
	
	unsigned char numIdxes[64];
	char buf[32];
	sprintf(buf, "%d", score);
	int len = strlen(buf);
	int totalNumIdx = 0;
	
	for (int i = 0; i < len; i++)
	{
		numIdxes[totalNumIdx++] = buf[i] - '0';
	}
	
	numIdxes[totalNumIdx++] = 10;
	sprintf(buf, "%d", time);
	len = strlen(buf);
	
	for (int i = 0; i < len; i++)
	{
		numIdxes[totalNumIdx++] = buf[i] - '0';
	}
	
	int totalWidth = 0;
	for (int i = 0; i < totalNumIdx; i++)
	{
		int numIdx = numIdxes[i];
		int xpos = s_numbersBeginPos[numIdx];
		
		CGRect rect = CGRectMake(xpos, kFloatingNumberHeight * idx, s_numbersWidth[numIdx], kFloatingNumberHeight);
		AtlasSprite* sp = [AtlasSprite spriteWithRect:rect spriteManager:m_spManager];
		sp.anchorPoint = ccp(0, 0);
		sp.position = ccp(totalWidth, 0);
		[m_spManager addChild:sp];
		
		totalWidth += s_numbersWidth[numIdx];
	}

	self.contentSize = CGSizeMake(totalWidth, kFloatingNumberHeight);
	self.relativeAnchorPoint = YES;
	
	return self;
}


+ (id) layerWithBaseScore:(int)score hitTime:(int)time colorIdx:(int)idx
{
	return [[[self alloc] initWithBaseScore:score hitTime:time colorIdx:idx] autorelease];
}


-(void) setColor:(ccColor3B)color
{
}

-(ccColor3B) color
{
	return ccc3(255, 255, 255);
}


-(GLubyte) opacity
{
	return 255;
}

-(void) setOpacity: (GLubyte) opacity
{
	NSArray* array = [m_spManager children];
	for (CocosNode* node in array)
	{
		AtlasSprite* sp = (AtlasSprite*)node;
		[sp setOpacity:opacity];
	}
}

@end
