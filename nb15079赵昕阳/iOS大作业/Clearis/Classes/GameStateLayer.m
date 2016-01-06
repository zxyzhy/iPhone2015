//
//  GameStateLayer.m
//  Clearis
//
//  Created by 881 on 10-3-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameStateLayer.h"
#import "global.h"

@implementation GameStateLayer


+ (id) layerWithDataManager:(GameDataManager*)manager
{
	return [[[self alloc] initWithDataManager:manager] autorelease];
}


- (id) initWithDataManager:(GameDataManager*)manager
{
	[super init];
	m_dataManager = manager;
	return self;
}


- (void) enterLayer
{
	[GameUtil enableMenu:self];
}


- (void) levelLayer:(GameDataManager*)manager
{
	[GameUtil disableMenu:self];
}

@end
