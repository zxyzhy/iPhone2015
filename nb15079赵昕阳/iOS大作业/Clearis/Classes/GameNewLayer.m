//
//  GameNewLayer.m
//  Clearis
//
//  Created by 881 on 10-3-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameNewLayer.h"
#import "GameAppDelegate.h"
#import "GameGradeLayer.h"
#import "GameMenu.h"


#define kLevelLabelTag	1000


@implementation GameNewLayer


- (id) initWithDataManager:(GameDataManager*)manager
{
	[super initWithDataManager:manager];
		
	CGSize contentSize = self.contentSize;
	MenuItemImage* mi0 = [MenuItemImage itemFromNormalImage:@"StartButton.png" 
											  selectedImage:@"StartButton_p.png" 
													 target:self 
												   selector:@selector(startStart:)];
	GameMenu* menu0 = [GameMenu menuWithItems:mi0, nil];
	menu0.position = ccp(contentSize.width * 0.5, 115);
	[self addChild:menu0];
	menu0.isTouchEnabled = FALSE;
	
	MenuItemImage* mi1 = [MenuItemImage itemFromNormalImage:@"CancelButton.png" 
											  selectedImage:@"CancelButton_p.png" 
													 target:self 
												   selector:@selector(startCancel:)];
	GameMenu* menu1 = [GameMenu menuWithItems:mi1, nil];
	menu1.position = ccp(contentSize.width * 0.5, 45);
	[self addChild:menu1];
	menu1.isTouchEnabled = FALSE;
	
	if (manager.hasDataSaved)
	{
		Sprite* noteSp = [Sprite spriteWithFile:@"ClickStartNote.png"];
		[self addChild:noteSp];
		noteSp.position = ccp(contentSize.width * 0.5, 160);
	}
	
	Sprite* nameLabel = [Sprite spriteWithFile:@"NameText.png"];
	nameLabel.anchorPoint = ccp(0, 0);
	nameLabel.position = ccp(0, contentSize.height - 65);
	[self addChild:nameLabel];
	
	Sprite* inputNameFrame = [Sprite spriteWithFile:@"InputNameFrame.png"];
	inputNameFrame.anchorPoint = ccp(0, 1);
	inputNameFrame.position = ccp(0, contentSize.height - 65);
	[self addChild:inputNameFrame];
	
	m_levelLayer = [[GameGradeLayer alloc] initWithLabelName:@"LevelText.png" 
													 toggle0:@"Normal"
													 toggle1:@"Locked"
													delegate:self];
	m_levelLayer.anchorPoint = ccp(0.5, 0.5);
	m_levelLayer.position = ccp(160, contentSize.height - 205);
	[self addChild:m_levelLayer];
	m_levelLayer.grade = manager.initLevel;
	m_levelLayer.selectedIndex = m_dataManager.isLevelLocked ? 1 : 0;
	[m_levelLayer disableMenu];

	m_nameField = [[UITextField alloc] initWithFrame:CGRectMake(14, 75, 295, 60)];
	m_nameField.backgroundColor = [UIColor clearColor];
	m_nameField.font = [UIFont fontWithName:@"Marker Felt" size:30];
	m_nameField.returnKeyType = UIReturnKeyDone;
	m_nameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	m_nameField.autocorrectionType = UITextAutocorrectionTypeNo;
	m_nameField.keyboardType = UIKeyboardTypeAlphabet;
	m_nameField.textColor = [UIColor whiteColor];
	m_nameField.delegate = self;
	
	m_nameField.text = manager.playerName;
	
	m_initLevel = manager.initLevel;
	m_isLevelLocked = manager.isLevelLocked;

	return self;
}


- (void) enterLayer
{
	[super enterLayer];
	[m_levelLayer enableMenu];
	self.isTouchEnabled = YES;
	[m_dataManager.mainWindow addSubview:m_nameField];
}


- (void) levelLayer:(GameDataManager*)manager
{
	[super levelLayer:manager];
	[m_levelLayer disableMenu];
	[m_nameField resignFirstResponder];
	[m_nameField removeFromSuperview];
	self.isTouchEnabled = NO;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
	[m_nameField resignFirstResponder];
	NSString* name = [[m_nameField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([name length] == 0) 
	{
		m_nameField.text = m_dataManager.playerName;
	} 
	return YES;
}


- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[m_nameField resignFirstResponder];
	return kEventHandled;
}


- (void) startCancel:(id)sender
{
	[m_nameField resignFirstResponder];
	[m_nameField removeFromSuperview];
	[[GameAppDelegate instance] startMainMenu:true];
}


- (void) startStart:(id)sender
{
	[m_nameField resignFirstResponder];
	[m_nameField removeFromSuperview];
	m_dataManager.hasDataSaved = false;
	m_dataManager.playerName = m_nameField.text;
	m_dataManager.initLevel = m_initLevel;
	m_dataManager.isLevelLocked = m_isLevelLocked;
	m_dataManager.score = 0;
	[[GameAppDelegate instance] startStartNewGame:false];
}


- (void) dealloc
{
	[m_nameField release];
	[m_levelLayer release];
	[super dealloc];
}


- (void) changeLayer:(GameGradeLayer*)layer grade:(int)grade
{
	m_initLevel = grade;
}


- (void) changeLayer:(GameGradeLayer*)layer selectIdx:(int)idx
{
	if (idx == 0)
	{
		m_isLevelLocked = false;
	}
	else if (idx == 1)
	{
		m_isLevelLocked = true;
	}
}

@end
