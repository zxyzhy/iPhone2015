//
//  global.m
//  Clearis
//
//  Created by 881 on 10-3-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "global.h"
#import "GameAppDelegate.h"
#import "GamePlayingLayer.h"
#import "SimpleAudioEngine.h"


int	 ComputeScores(int num)
{
	assert(num >= 3);
	return 50 * num;
	int score = 150;
	num -= 3;
	
	int tmp = 50;
	for (int i = 0; i < num; i++)
	{
		score += tmp;
		tmp += 50;
	}
	
	return score;
}

////////////////////////

@implementation GameUtil

+ (void) enableMenu:(Layer*) layer
{
	NSArray* children = [layer children];
	for (CocosNode* node in children)
	{
		if ([node isKindOfClass:[Menu class]])
		{
			((Menu*)node).isTouchEnabled = YES;
		}
	}
}


+ (void) disableMenu:(Layer*) layer
{
	NSArray* children = [layer children];
	for (CocosNode* node in children)
	{
		if ([node isKindOfClass:[Menu class]])
		{
			((Menu*)node).isTouchEnabled = NO;
		}
	}
}


static NSString* lastBkMusicName = nil;

+ (void) playerBKMusic:(NSString*)fileName volume:(CGFloat)volume
{
	if (fileName == nil)
	{
		[lastBkMusicName release];
		lastBkMusicName = nil;
		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	}
	else
	{
		SimpleAudioEngine* engin = [SimpleAudioEngine sharedEngine];
		if (lastBkMusicName == nil)
		{
			[engin preloadBackgroundMusic:fileName];
			engin.backgroundMusicVolume = volume;
			[engin playBackgroundMusic:fileName];
		}
		else if (![lastBkMusicName isEqualToString:fileName])
		{
			[engin preloadBackgroundMusic:fileName];
			engin.backgroundMusicVolume = volume;
			[engin playBackgroundMusic:fileName];			
		}
		
		[lastBkMusicName release];
		lastBkMusicName = [[NSString alloc] initWithString:fileName];
	}
}

@end


