//
//  GameNumberLayer.m
//  Clearis
//
//  Created by 881 on 10-3-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameNumberLayer.h"
#import "ConstDef.h"


@implementation GameNumberLayer


- (id) initWithNumber:(int)number
{
	[super init];
	
	char buf[24];
	sprintf(buf, "%d", number);
	
	int len = strlen(buf);
	CGSize layerSize = CGSizeMake(kNumberSpriteWidth * len, kNumberSpriteHeight);
	self.contentSize = layerSize;
	self.relativeAnchorPoint = YES;
	
	AtlasSpriteManager* spriteManager = [AtlasSpriteManager spriteManagerWithFile:@"MergeNumbers.png"];
	[self addChild:spriteManager];
	
	for (int i = 0; i < len; i++)
	{
		CGRect rect = CGRectMake((buf[i] - '0') * kNumberSpriteWidth, 0, kNumberSpriteWidth, kNumberSpriteHeight);
		AtlasSprite* sp = [AtlasSprite spriteWithRect:rect spriteManager:spriteManager];
		sp.anchorPoint = ccp(0, 0);
		sp.position = ccp(i * kNumberSpriteWidth, 0);
		[spriteManager addChild:sp];
	}
	
	return self;
}


+ (id) layerWithNumber:(int)number
{
	return [[[self alloc] initWithNumber:number] autorelease];
}

@end
