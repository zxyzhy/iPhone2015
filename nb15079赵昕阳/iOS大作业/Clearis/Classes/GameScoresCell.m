//
//  GameScoresCell.m
//  Clearis
//
//  Created by 881 on 10-3-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameScoresCell.h"


@implementation GameScoresCell


@synthesize m_name;
@synthesize m_score;

- (void) dealloc
{
	[m_name release];
	[m_score release];
	[super dealloc];
}

@end
