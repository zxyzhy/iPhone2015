//
//  GameNumberLayer.h
//  Clearis
//
//  Created by 881 on 10-3-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"


@interface GameNumberLayer : Layer {
}

- (id) initWithNumber:(int)number;
+ (id) layerWithNumber:(int)number;

@end
