//
//  GameScoresCell.h
//  Clearis
//
//  Created by 881 on 10-3-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GameScoresCell : UITableViewCell 
{
	IBOutlet	UILabel*	m_name;
	IBOutlet	UILabel*	m_score;
}

@property (nonatomic, retain)	UILabel*	m_name;
@property (nonatomic, retain)	UILabel*	m_score;

@end
