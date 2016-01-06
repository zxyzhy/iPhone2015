//
//  GameFloatingScores.h
//  Clearis
//
//  Created by 881 on 10-3-29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"


@interface GameFloatingScores : Layer<CocosNodeRGBA> 
{
	AtlasSpriteManager*		m_spManager;
}

- (id) initWithBaseScore:(int)score hitTime:(int)time colorIdx:(int)idx;
+ (id) layerWithBaseScore:(int)score hitTime:(int)time colorIdx:(int)idx;

-(void) setColor:(ccColor3B)color;
-(ccColor3B) color;
-(GLubyte) opacity;
-(void) setOpacity: (GLubyte) opacity;

@end
