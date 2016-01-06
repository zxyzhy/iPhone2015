//
//  GameGradeLayer.m
//  Clearis
//
//  Created by 881 on 10-3-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameGradeLayer.h"
#import "GameMenu.h"
#import "ConstDef.h"
#import "global.h"


#define kGradeColorWidth		214
#define kGradeColorHeight		31
#define kGradeColorSpriteTag	1000
#define kNumberSpriteTag		1001


@interface GameGradeSubLayer : Layer 
{
	AtlasSpriteManager*		m_spriteManager;
	int						m_grade;
}

@property (nonatomic, assign)	int	grade;

- (id) initWithMenuTargetr:(id)menuTarget;

@end




@implementation GameGradeSubLayer

@synthesize grade = m_grade;


- (id) initWithMenuTargetr:(id)menuTarget
{
	[super init];
	
	Sprite* gradeFrame = [Sprite spriteWithFile:@"GradeFrame.png"];
	[self addChild:gradeFrame];
	
	MenuItemImage* mi0 = [MenuItemImage itemFromNormalImage:@"AddButton.png" 
											  selectedImage:@"AddButton_p.png" 
													 target:menuTarget 
												   selector:@selector(startAddButton:)];
	GameMenu* menu0 = [GameMenu menuWithItems:mi0, nil];
	[self addChild:menu0];
	
	MenuItemImage* mi1 = [MenuItemImage itemFromNormalImage:@"MinusButton.png" 
											  selectedImage:@"MinusButton_p.png" 
													 target:menuTarget 
												   selector:@selector(startMinusButton:)];
	GameMenu* menu1 = [GameMenu menuWithItems:mi1, nil];
	[self addChild:menu1];
	
	CGFloat height = gradeFrame.contentSize.height;
	height = height > mi0.contentSize.height ? height : mi0.contentSize.height;
	height = height > mi1.contentSize.height ? height : mi1.contentSize.height;
	
	self.contentSize = CGSizeMake(320, height);
	self.relativeAnchorPoint = YES;
	
	gradeFrame.position = ccp(160, self.contentSize.height * 0.5);
	menu0.position = ccp(self.contentSize.width - mi0.contentSize.width * 0.5 - 2, self.contentSize.height * 0.5);
	menu1.position = ccp(mi1.contentSize.height * 0.5 + 2, self.contentSize.height * 0.5 - 6);
		
	m_spriteManager = [AtlasSpriteManager spriteManagerWithFile:@"GradeColor.png"];
	[self addChild:m_spriteManager];
	
	m_grade = 9;
	self.grade = m_grade;
	
	return self;
}


- (CGRect) colorRectWidthGrade:(int)grade
{
	const CGFloat eachWidth = kGradeColorWidth / 9.0;
	return CGRectMake(0, 0, grade * eachWidth, kGradeColorHeight);
}


- (void) setGrade:(int)grade
{
	assert(grade >= 0 && grade <= 9);
	[m_spriteManager removeChildByTag:kGradeColorSpriteTag cleanup:YES];	
	m_grade = grade;
	
	if (grade != 0)
	{
		CGRect rect = [self colorRectWidthGrade:m_grade];
		AtlasSprite* sp = [AtlasSprite spriteWithRect:rect spriteManager:m_spriteManager];
		
		sp.anchorPoint = ccp(0, 0);
		sp.position = ccp(160 - kGradeColorWidth * 0.5, self.contentSize.height * 0.5 - kGradeColorHeight * 0.5);
		
		[m_spriteManager addChild:sp z:0 tag:kGradeColorSpriteTag];
	}
}

@end



@implementation GameGradeLayer

//@synthesize grade;

- (int) grade
{
	return m_gradeLayer.grade;
}


- (void) setGrade:(int)grade
{
	m_gradeLayer.grade = grade;
	
	[m_numberManager removeChild:(AtlasSprite*)[m_numberManager getChildByTag:kNumberSpriteTag] cleanup:YES];
	
	CGRect rect = CGRectMake(kNumberSpriteWidth * grade, 0, kNumberSpriteWidth, kNumberSpriteHeight);
	AtlasSprite* sp = [AtlasSprite spriteWithRect:rect spriteManager:m_numberManager];
	sp.anchorPoint = ccp(0, 0.5);
	sp.position = ccp(kTextLabelSpriteWidth + 15, self.contentSize.height - kTextLabelSpriteHeight * 0.5 - 5);
	
	[m_numberManager addChild:sp z:0 tag:kNumberSpriteTag];
}


- (int) selectedIndex
{
	return m_menuItemToggle.selectedIndex;
}

- (void) setSelectedIndex:(int)idx
{
	m_menuItemToggle.selectedIndex = idx;
}

+ (id) layerWithLabelName:(NSString*) labelName toggle0:(NSString*)t0 toggle1:(NSString*)t1 
				 delegate:(id<GameGradeDelegate>) delegate
{
	return [[[self alloc] initWithLabelName:labelName toggle0:t0 toggle1:t1 delegate:delegate] autorelease];
}


- (id) initWithLabelName:(NSString*) labelName toggle0:(NSString*)t0 toggle1:(NSString*)t1
				delegate:(id<GameGradeDelegate>) delegate
{
	[super init];
	
	m_delegate = delegate;
	
	Sprite* levelLabel = [Sprite spriteWithFile:labelName];	
	GameGradeSubLayer* layer = [[[GameGradeSubLayer alloc] initWithMenuTargetr:self] autorelease];
	m_gradeLayer = layer;
	
	CGFloat height = levelLabel.contentSize.height + layer.contentSize.height;
	self.contentSize = CGSizeMake(layer.contentSize.width, height);
	self.relativeAnchorPoint = YES;
	
	layer.anchorPoint = ccp(0, 0);
	
	levelLabel.anchorPoint = ccp(0, 1);
	levelLabel.position = ccp(0, height - 5);
	
	[MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:30];
	m_menuItemToggle = [MenuItemToggle itemWithTarget:self selector:@selector(startSelected:) items:
						   [MenuItemFont itemFromString:t0],
						   [MenuItemFont itemFromString:t1],
						   nil];
	GameMenu* menu2 = [GameMenu menuWithItems:m_menuItemToggle, nil];
	[self addChild:menu2];
	menu2.color = ccc3(255, 255, 0);
	menu2.position = ccp(220, 61);
	
	[self addChild:layer];
	[self addChild:levelLabel];
	
	m_numberManager = [AtlasSpriteManager spriteManagerWithFile:@"MergeNumbers.png"];
	[self addChild:m_numberManager];
	
	self.grade = 9;
	
	return self;
}



- (void) startSelected:(id)sender
{
	MenuItemToggle* menuItem = (MenuItemToggle*)sender;
	if (m_delegate)
	{
		[m_delegate changeLayer:self selectIdx:menuItem.selectedIndex];
	}
}



- (void) startAddButton:(id)sender
{
	int grade = m_gradeLayer.grade;
	if (grade < 9)
	{
		grade++;
		self.grade = grade;
		
		if (m_delegate)
		{
			[m_delegate changeLayer:self grade:grade];
		}
	}
}


- (void) startMinusButton:(id)sender
{
	int grade = m_gradeLayer.grade;
	if (grade > 0)
	{
		grade--;
		self.grade = grade;
		
		if (m_delegate)
		{
			[m_delegate changeLayer:self grade:grade];
		}
	}
}


- (void) enableMenu
{
	[GameUtil enableMenu:m_gradeLayer];
	[GameUtil enableMenu:self];
}


- (void) disableMenu
{
	[GameUtil disableMenu:m_gradeLayer];
	[GameUtil disableMenu:self];
}


@end
