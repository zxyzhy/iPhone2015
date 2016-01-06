//
//  GameScoresCell.m
//  Clearis
//
//  Created by 881 on 10-3-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameInfoCell.h"


@implementation GameInfoCell


@synthesize m_info;

- (void) dealloc
{
	[m_info release];
	[super dealloc];
}

@end
