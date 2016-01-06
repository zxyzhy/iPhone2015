//
//  global.h
//  Clearis
//
//  Created by 881 on 10-3-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#ifndef _GLOBAL_H_
#define _GLOBAL_H_


#import "Layer.h"


#ifdef __cplusplus

extern "C" 
{
	int	 ComputeScores(int num);
}

#else
int	 ComputeScores(int num);

#endif


@interface GameUtil : NSObject
{
}

+ (void) enableMenu:(Layer*) layer;
+ (void) disableMenu:(Layer*) layer;
+ (void) playerBKMusic:(NSString*)fileName volume:(CGFloat)volume;

@end


#endif
