//
//  GamePauseLayer.m
//  Clearis
//
//  Created by 881 on 10-3-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GamePauseLayer.h"
#import "GameMenu.h"
#import "GameAppDelegate.h"
#import "GameGradeLayer.h"
#import "SimpleAudioEngine.h"


@implementation GamePauseLayer



- (id) initWithDataManager:(GameDataManager*)manager
{
	[super initWithDataManager:manager];
	
	CGSize contentSize = self.contentSize;
	MenuItemImage* mi0 = [MenuItemImage itemFromNormalImage:@"ResumeButton.png" 
											  selectedImage:@"ResumeButton_p.png" 
													 target:self 
												   selector:@selector(startResume:)];
	GameMenu* menu0 = [GameMenu menuWithItems:mi0, nil];
	menu0.position = ccp(contentSize.width * 0.5, 115);
	[self addChild:menu0];
	menu0.isTouchEnabled = FALSE;
	
	MenuItemImage* mi1 = [MenuItemImage itemFromNormalImage:@"MainMenuButton.png" 
											  selectedImage:@"MainMenuButton_p.png" 
													 target:self 
												   selector:@selector(startMenu:)];
	GameMenu* menu1 = [GameMenu menuWithItems:mi1, nil];
	menu1.position = ccp(contentSize.width * 0.5, 45);
	[self addChild:menu1];
	menu1.isTouchEnabled = FALSE;
		
	return self;
}


- (void) startMenu:(id)sender
{
	[[GameAppDelegate instance] startMainMenu:true];
}


- (void) startResume:(id)sender
{
	[[GameAppDelegate instance] startStartNewGame:true];
}

@end
