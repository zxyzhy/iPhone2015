//
//  GameGradeLayer.h
//  Clearis
//
//  Created by 881 on 10-3-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"


@class GameGradeLayer;

@protocol GameGradeDelegate
- (void) changeLayer:(GameGradeLayer*)layer grade:(int)grade;
- (void) changeLayer:(GameGradeLayer*)layer selectIdx:(int)idx;
@end




@class	GameGradeSubLayer;
@interface GameGradeLayer : Layer
{
	AtlasSpriteManager*		m_numberManager;
	GameGradeSubLayer*		m_gradeLayer;
	id<GameGradeDelegate>	m_delegate;
	MenuItemToggle*			m_menuItemToggle;
}

- (id) initWithLabelName:(NSString*) labelName toggle0:(NSString*)t0 toggle1:(NSString*)t1 delegate:(id<GameGradeDelegate>) delegate;
+ (id) layerWithLabelName:(NSString*) labelName toggle0:(NSString*)t0 toggle1:(NSString*)t1 delegate:(id<GameGradeDelegate>) delegate;

- (void) startAddButton:(id)sender;
- (void) startMinusButton:(id)sender;
- (void) startSelected:(id)sender;

- (void) enableMenu;
- (void) disableMenu;

@property (nonatomic, assign)   int	grade;
@property (nonatomic, assign)	int selectedIndex;

@end

