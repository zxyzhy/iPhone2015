//
//  GameResetViewControler.h
//  Clearis
//
//  Created by 881 on 10-3-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GameResetViewControler : UIViewController {
	id	m_target;
}

- (void) setTarget:(id) target;

- (IBAction) beganPressed:(id)sender;
- (IBAction) cancelPreesed:(id)sender;
- (IBAction) resetScoresPressed:(id)sender;

@end
